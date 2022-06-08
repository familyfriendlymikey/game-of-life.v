import rand
import os
import strings

const rows = 40
const cols = 140

fn create_board(rows int, cols int) [][]bool {
	return [][]bool{len: rows + 2, init: []bool{len: cols + 2, init: false}}
}

[direct_array_access]
fn print_board(board [][]bool) {
	mut s := strings.new_builder((rows + 2) * (cols + 2))
	for row in board {
		for cell in row {
			if cell {
				s.write_string("*")
			} else {
				s.write_string(" ")
			}
		}
		s.write_string("\n")
	}
	print(s)
}

[direct_array_access]
fn randomize_board(mut board [][]bool) [][]bool {
	for i in 1 .. rows + 1 {
		for j in 1 .. cols + 1 {
			board[i][j] = rand.f32() < 0.5
		}
	}
	return board
}

[direct_array_access]
fn count_neighbors(board [][]bool, i int, j int) int {
	return
	int(board[i - 1][j - 1]) +
	int(board[i - 1][j]) +
	int(board[i - 1][j + 1]) +
	int(board[i][j - 1]) +
	int(board[i][j + 1]) +
	int(board[i + 1][j - 1]) +
	int(board[i + 1][j]) +
	int(board[i + 1][j + 1])
}

[direct_array_access]
fn tick(board [][]bool) [][]bool {
	mut next_board := create_board(rows, cols)
	mut nc := 0
	for i in 1 .. rows + 1 {
		for j in 1 .. cols + 1 {
			nc = count_neighbors(board, i, j)
			next_board[i][j] = (board[i][j] && nc == 2) || (nc == 3)
		}
	}
	return next_board
}

fn clear_screen() { print("\x1b[2J") }
fn hide_cursor() { print("\x1b[?25l") }
fn show_cursor() { print("\x1b[?25h") }
fn smcup() { print("\x1b[?1049h") }
fn rmcup() { print("\x1b[?1049l") }
fn place_cursor() { print("\x1b[1;1H") }

fn cleanup_term(lol os.Signal) {
	place_cursor()
	clear_screen()
	rmcup()
	show_cursor()
	exit(0)
}

fn prep_term() {
	smcup()
	place_cursor()
	clear_screen()
	hide_cursor()
}

fn main(){
	os.signal_opt(os.Signal.int, cleanup_term)?
	mut board := create_board(rows, cols)
	board = randomize_board(mut board)
	prep_term()
	for _ in 1 .. 10000 {
		board = tick(board)
		place_cursor()
		print_board(board)
	}
	cleanup_term(os.Signal.int)
}
