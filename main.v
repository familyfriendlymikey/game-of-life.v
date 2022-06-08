import rand
import os

const rows = 40
const cols = 140

type Board = []bool

fn create_board(rows int, cols int) Board {
	return Board([]bool{len: (rows + 2) * (cols + 2), init: false})
}

fn idx(i int, j int) int {
	return (i + 1) * (cols + 2) + (j + 1)
}

[direct_array_access]
fn print_board(b Board, pb Board, mut buf []u8) {
	mut s := ""
	buf.clear()
	for i in 0 .. rows {
		for j in 0 .. cols {
			if b[idx(i, j)] != pb[idx(i, j)] {
				s = "\x1b[${i + 1};${j + 1}H"
				unsafe { buf.push_many(s.str, s.len) }
				if b[idx(i, j)] {
					buf << `*`
				} else {
					buf << ` `
				}
			}
		}
	}
	C.write(1, buf.data, buf.len)
}

[direct_array_access]
fn randomize_board(mut b Board) Board {
	for i in 0 .. rows {
		for j in 0 .. cols {
			b[idx(i, j)] = rand.f32() < 0.5
		}
	}
	return b
}

[direct_array_access]
fn count_neighbors(b Board, i int, j int) int {
	return
	int(b[idx(i - 1, j - 1)]) +
	int(b[idx(i - 1, j)]) +
	int(b[idx(i - 1, j + 1)]) +
	int(b[idx(i, j - 1)]) +
	int(b[idx(i, j + 1)]) +
	int(b[idx(i + 1, j - 1)]) +
	int(b[idx(i + 1, j)]) +
	int(b[idx(i + 1, j + 1)])
}

[direct_array_access]
fn tick(b Board, mut nb Board) Board {
	mut nc := 0
	for i in 0 .. rows {
		for j in 0 .. cols {
			nc = count_neighbors(b, i, j)
			nb[idx(i, j)] = (b[idx(i, j)] && nc == 2) || (nc == 3)
		}
	}
	return nb
}

fn clear_screen() { print("\x1b[2J") }
fn hide_cursor() { print("\x1b[?25l") }
fn show_cursor() { print("\x1b[?25h") }
fn smcup() { print("\x1b[?1049h") }
fn rmcup() { print("\x1b[?1049l") }
fn place_cursor_top_left() { print("\x1b[1;1H") }

fn cleanup_term(lol os.Signal) {
	place_cursor_top_left()
	clear_screen()
	rmcup()
	show_cursor()
	exit(0)
}

fn prep_term() {
	smcup()
	place_cursor_top_left()
	clear_screen()
	hide_cursor()
}

fn main(){
	os.signal_opt(os.Signal.int, cleanup_term)?
	mut board := create_board(rows, cols)
	mut next_board := create_board(rows, cols)
	board = randomize_board(mut board)
	prep_term()
	mut buf := []u8{}
	for _ in 1 .. 10000 {
		tick(board, mut next_board)
		board, next_board = next_board, board
		print_board(board, next_board, mut buf)
	}
	cleanup_term(os.Signal.int)
}
