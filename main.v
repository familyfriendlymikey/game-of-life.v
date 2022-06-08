import rand
import os
import strings

const rows = 40
const cols = 140
const alive = `*`
const dead = ` `

type Board = []bool

struct Game {
mut:
	board Board = create_board_random()
	board_alt Board = create_board()
}

fn create_board() Board {
	return Board([]bool{len: (rows + 2) * (cols + 2), init: false})
}

fn idx(i int, j int) int {
	return (i + 1) * (cols + 2) + (j + 1)
}

[direct_array_access]
fn create_board_random() Board {
	mut board := create_board()
	for i in 0 .. rows {
		for j in 0 .. cols {
			board[idx(i, j)] = rand.f32() < 0.5
		}
	}
	return board
}

[direct_array_access]
fn (g Game) print_board() {
	mut s := strings.new_builder(rows * cols)
	mut index := 0
	for i in 0 .. rows {
		for j in 0 .. cols {
			index = idx(i, j)
			if g.board[index] != g.board_alt[index] {
				s.write_string("\x1b[${i + 1};${j + 1}H")
				if g.board[index] {
					s.write_rune(alive)
				} else {
					s.write_rune(dead)
				}
			}
		}
	}
	C.write(1, s.data, s.len)
}

[direct_array_access]
fn (g Game) count_neighbors(i int, j int) int {
	return
	int(g.board[idx(i - 1, j - 1)]) +
	int(g.board[idx(i - 1, j)]) +
	int(g.board[idx(i - 1, j + 1)]) +
	int(g.board[idx(i, j - 1)]) +
	int(g.board[idx(i, j + 1)]) +
	int(g.board[idx(i + 1, j - 1)]) +
	int(g.board[idx(i + 1, j)]) +
	int(g.board[idx(i + 1, j + 1)])
}

[direct_array_access]
fn (mut g Game) tick() {
	mut nc := 0
	for i in 0 .. rows {
		for j in 0 .. cols {
			nc = g.count_neighbors(i, j)
			g.board_alt[idx(i, j)] = (g.board[idx(i, j)] && nc == 2) || (nc == 3)
		}
	}
	g.board, g.board_alt = g.board_alt, g.board
}

fn clear_screen() { print("\x1b[2J") }
fn hide_cursor() { print("\x1b[?25l") }
fn show_cursor() { print("\x1b[?25h") }
fn smcup() { print("\x1b[?1049h") }
fn rmcup() { print("\x1b[?1049l") }
fn place_cursor() { print("\x1b[1;1H") }

fn cleanup_term(_ os.Signal) {
	place_cursor()
	clear_screen()
	rmcup()
	show_cursor()
	flush_stdout()
	exit(0)
}

fn prep_term() {
	smcup()
	place_cursor()
	clear_screen()
	hide_cursor()
	flush_stdout()
}

fn main(){
	os.signal_opt(os.Signal.int, cleanup_term)?
	prep_term()
	mut game := Game{}
	for _ in 1 .. 10000 {
		game.tick()
		game.print_board()
	}
	cleanup_term(os.Signal.int)
}
