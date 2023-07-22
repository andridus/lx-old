module lexer

import compiler_v.color

pub fn (l Lexer) get_in_out(lin int, lout int, str string) (int, int) {
	if lout >= lin {
		a := l.input[lin..lout].bytestr()
		first_of_line := seek_len_until_lb_before(l.input, lin)
		mut initial_char := a.index(str) or { 0 }
		initial_char += lin - first_of_line
		return initial_char, initial_char + str.len
	} else {
		return 0, 0
	}
}

pub fn (l Lexer) get_code_between_line_breaks(color0 int, from int, current_in int, current_out int, line_breaks int, current_line int) string {
	mut lb_before := seek_lb_before(l.input, from)
	lb_after := seek_lb_after(l.input, from)
	mut lines := []string{}
	// lines << color.fg(color.dark_gray, 1, '----------')
	mut curr_line := current_line - 1
	for i0 := lb_before; i0 <= lb_after; i0++ {
		if l.input[i0] == 10 && i0 != lb_before {
			i0++
			if curr_line == current_line {
				code := color.fg(color.white, 1, remove_break_line(l.input[lb_before..i0]).bytestr())
				lines << color.fg(color.white, 1, '${curr_line} | ') + code
				mut space := []u8{}
				for c := 0; c < current_out; c++ {
					if c <= current_in && c + 1 > current_in {
						space << 94
					} else if c > current_in {
						space << 126
					} else {
						space << 32
					}
				}
				lines << color.fg(color.red, 0, '- |${space.bytestr()}')
			} else {
				str := '${curr_line} | ' + remove_break_line(l.input[lb_before..i0]).bytestr()
				lines << color.fg(color.white, 0, '${str}')
			}
			lb_before = i0
			curr_line++
		}
	}
	lines << color.fg(color.dark_gray, 1, '-+---------')
	return lines.join('\n')
}

fn remove_break_line(arr []u8) []u8 {
	mut new_arr := []u8{}
	for i in arr {
		if i != 10 {
			if i == 9 {
				new_arr << 32
			} else {
				new_arr << i
			}
		}
	}
	return new_arr
}

fn seek_len_until_lb_before(arr []u8, i0 int) int {
	mut ret_int := 0
	for i := i0; i > 0; i-- {
		ret_int = i
		if arr[i] == 10 {
			break
		}
	}
	return ret_int
}

fn seek_lb_before(arr []u8, i0 int) int {
	mut total := 2
	for i := i0; i > 0; i-- {
		if arr[i] == 10 {
			if total == 0 {
				return i
			} else {
				total--
			}
		}
	}
	return 0
}

fn seek_lb_after(arr []u8, i0 int) int {
	mut total := 2
	for i := i0; i < arr.len; i++ {
		if arr[i] == 10 {
			if total == 0 {
				return i
			} else {
				total--
			}
		}
	}
	return i0
}
