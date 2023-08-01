module lexer

import compiler_v.token

fn (mut l Lexer) get_token_atom(bt u8) token.Token {
	l.pos++
	mut current := l.input[l.pos]
	mut pos := l.pos
	if current == `'` || current == `"` {
		pos++
		start_pos := pos
		current = l.input[pos]
		for current != `'` && current != `"` && pos < l.total {
			current = l.input[pos]
			pos++
		}
		str := l.input[start_pos..pos - 1].bytestr()

		return l.new_token(str, token.Kind.atom, str.len + 2)
	} else if is_letter(current) {
		term, _ := l.get_word(current)
		return l.new_token(term, token.Kind.atom, term.len)
	} else {
		if pos < l.total {
			if l.input[pos] == 32 {
				return l.new_token(':', token.Kind.colon_space, 1)
			}
		}
		return l.new_token(':', token.Kind.colon, 1)
	}
}

fn (mut l Lexer) get_token_word(cch u8) !token.Token {
	term, is_capital := l.get_word(cch)
	if term.len > 0 {
		if is_capital {
			return l.new_token(term, token.Kind.modl, term.len)
		} else {
			if l.pos + term.len + 1 < l.total && l.input[l.pos + term.len] == `:`
				&& l.input[l.pos + term.len + 1] == 32 {
				return l.new_token(term, token.Kind.key_keyword, term.len + 1)
			} else {
				return l.new_token(term, token.key_to_token(term), term.len)
			}
		}
	} else {
		return error('not have a word')
	}
}

fn (mut l Lexer) get_token_integer(cch u8) !token.Token {
	term, kind := l.get_number(cch)
	if term.len > 0 {
		return l.new_token(term, kind, term.len)
	} else {
		return error('not have a integer')
	}
}

fn (mut l Lexer) get_token_comment(bt u8) token.Token {
	mut current := bt
	mut pos := l.pos
	start_pos := pos
	for (current != 10 && pos < l.total) {
		current = l.input[pos]
		pos++
	}
	str := l.input[start_pos..pos - 1].bytestr()
	return l.new_token(str, token.Kind.line_comment, str.len)
}

fn (mut l Lexer) get_text_delim(kind token.Kind, delim_start string, delim_end string) token.Token {
	if l.input[l.pos..(l.pos + delim_start.len)] == delim_start.bytes() {
		l.pos += delim_start.len
		start_pos := l.pos
		mut current := l.input[l.pos]
		for (l.pos < l.total) {
			mut m := 0
			if current == delim_end[0] {
				mut x := 1
				for x < delim_end.len {
					if delim_end[x] == l.input[l.pos + x - 1] {
						m++
					}
					x++
				}
				if m == delim_end.len - 1 {
					break
				}
			}
			current = l.input[l.pos]
			l.pos++
		}
		str := l.input[start_pos..(l.pos - delim_end.len)].bytestr().trim(' ').replace('\n',
			'\\n')
		return l.new_token(str, kind, 0)
	} else {
		println('ignore ${l.input[l.pos]}')
		return l.new_token('', .ignore, 1)
	}
}

fn (l Lexer) get_next_alpha() (string, bool) {
	if has_next_char(1, l.total) {
		current_ch := l.input[l.pos + 1]
		if is_letter(current_ch) {
			return current_ch.ascii_str(), true
		}
	}
	return '', false
}

fn (l Lexer) get_word(cch u8) (string, bool) {
	is_first_capital := is_capital(cch)
	mut current_ch := cch
	mut pos := l.pos
	start_pos := pos
	if current_ch == cch && is_letter(current_ch) {
		for is_alpha(current_ch) && pos < l.total {
			pos += 1
			current_ch = l.input[pos]
		}
		return l.input[start_pos..pos].bytestr(), is_first_capital
	}
	return '', false
}

fn (mut l Lexer) get_number(cch u8) (string, token.Kind) {
	mut current_ch := cch
	mut pos := l.pos
	start_pos := pos
	mut typ := token.Kind.integer
	for (is_digit(current_ch) && pos <= l.total)
		|| (pos > start_pos && current_ch in [`.`, `_`] && pos <= l.total) {
		if current_ch == `.` {
			typ = .float
		}
		current_ch = l.input[pos]
		pos += 1
	}
	if pos > start_pos {
		str := l.input[start_pos..pos - 1].bytestr()
		return str.replace('_', ''), typ
	} else {
		return '', typ
	}
}
