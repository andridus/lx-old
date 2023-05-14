module lexer

import token

pub struct Lexer {
	input []u8
pub mut:
	lines      int = 1
	pos        int
	pos_inline int
	total      int
	tokens     []token.Token
}

pub fn new(input string) Lexer {
	mut bytes := input.bytes()
	bytes << 0
	mut l := Lexer{
		input: bytes
		total: input.len
	}
	return l
}

pub fn (mut l Lexer) generate_one_token() token.Token {
	return l.parse_token()
}

pub fn (mut l Lexer) generate_tokens() {
	for l.pos < l.total {
		tok := l.parse_token()
		if tok.kind !in [.newline, .ignore] {
			l.tokens << tok
		}
	}
	if l.tokens.len > 0 {
		l.tokens << l.new_token_eof()
	}
}

//// private functions
fn has_next_char(i int, total int) bool {
	return i < total
}

fn (l Lexer) peek_next_char() u8 {
	pos := l.pos + 1
	return l.input[pos]
}

fn (mut l Lexer) match_next_char(u u8) bool {
	if has_next_char(l.pos, l.total) && u == l.peek_next_char() {
		l.advance(1)
		return true
	} else {
		return false
	}
}

fn (l Lexer) match_next_char_ignore_space(u u8) (bool, int) {
	mut pos := l.pos + 1
	mut ls := 1
	for has_next_char(pos, l.total) && l.input[pos] == 32 {
		pos++
		ls++
	}
	if has_next_char(pos, l.total) && u == l.input[pos] {
		return true, ls
	} else {
		return false, 0
	}
}

fn (l Lexer) match_next_space_or_nil() bool {
	pos := l.pos + 1
	return has_next_char(pos, l.total) && 32 == l.input[pos]
}

fn (mut l Lexer) advance(qtd int) {
	l.pos += qtd
	l.pos_inline += qtd
}

fn (mut l Lexer) skip_space() token.Token {
	l.advance(1)
	return l.parse_token()
}

fn (mut l Lexer) parse_token() token.Token {
	if l.pos == l.total {
		return l.new_token_eof()
	}
	u := l.input[l.pos]
	return match u {
		32 {
			l.skip_space()
		}
		`#` {
			if l.match_next_char(`{`) {
				l.match_else()
			} else {
				l.get_token_comment(u)
			}
		}
		`@` {
			if l.match_next_char(`d`) {
				if l.match_next_char(`o`) {
					if l.match_next_char(`c`) {
						pass, qtd := l.match_next_char_ignore_space(`"`)
						if pass {
							l.advance(qtd)
							l.get_text_delim(token.Kind.doc, '"""', '"""')
						} else {
							l.match_else()
						}
					} else {
						l.match_else()
					}
				} else {
					l.match_else()
				}
			} else if l.match_next_char(`m`) {
				if l.match_next_char(`o`) {
					if l.match_next_char(`d`) {
						if l.match_next_char(`u`) {
							if l.match_next_char(`l`) {
								if l.match_next_char(`e`) {
									if l.match_next_char(`d`) {
										if l.match_next_char(`o`) {
											if l.match_next_char(`c`) {
												pass, qtd := l.match_next_char_ignore_space(`"`)
												if pass {
													l.advance(qtd)
													l.get_text_delim(token.Kind.moduledoc,
														'"""', '"""')
												} else {
													l.match_else()
												}
											} else {
												l.match_else()
											}
										} else {
											l.match_else()
										}
									} else {
										l.match_else()
									}
								} else {
									l.match_else()
								}
							} else {
								l.match_else()
							}
						} else {
							l.match_else()
						}
					} else {
						l.match_else()
					}
				} else {
					l.match_else()
				}
			} else {
				l.new_token('@', .arrob, 1)
			}
		}
		`"` {
			if l.match_next_char(`"`) {
				if l.match_next_char(`"`) {
					l.advance(-2) // return to first occurence of \"
					l.get_text_delim(token.Kind.multistring, '"""', '"""')
				} else {
					l.match_else()
				}
			} else {
				// l.advance(-2) // return to first occurence of \"
				l.get_text_delim(token.Kind.str, '"', '"')
			}
		}
		`=` {
			if l.match_next_char(`=`) {
				if l.match_next_char(`=`) {
					l.new_token('===', .eq, 3)
				} else {
					l.new_token('==', .eq, 2)
				}
			} else if l.match_next_char(`>`) {
				l.new_token('=>', .arrow, 2)
			} else if l.match_next_char(`~`) {
				l.new_token('=~', .eq, 2)
			} else {
				l.new_token('=', .assign, 1)
			}
		}
		`!` {
			if l.match_next_char(`=`) {
				if l.match_next_char(`=`) {
					l.new_token('!==', .ne, 3)
				} else {
					l.new_token('!=', .ne, 2)
				}
			} else {
				l.new_token('!', .bang, 1)
			}
		}
		`&` {
			if l.match_next_char(`&`) {
				if l.match_next_char(`&`) {
					l.new_token('&&&', .and, 3)
				} else {
					l.new_token('&&', .and, 2)
				}
			} else {
				l.new_token('&', .capture, 1)
			}
		}
		`~` {
			ch, pass := l.get_next_alpha()
			if pass {
				l.new_token('~${ch}', .sigil, 2)
			} else {
				l.new_token('~', .bit_not, 1)
			}
		}
		`|` {
			if l.match_next_char(`|`) {
				if l.match_next_char(`|`) {
					l.new_token('|||', .logical_or, 3)
				} else {
					l.new_token('||', .logical_or, 2)
				}
			} else {
				l.new_token('|', .pipe, 1)
			}
		}
		`+` {
			if l.match_next_char(`+`) {
				if l.match_next_char(`+`) {
					l.new_token('+++', .plus_concat, 3)
				} else {
					l.new_token('++', .plus_concat, 2)
				}
			} else {
				l.new_token('+', .plus, 1)
			}
		}
		`-` {
			if l.match_next_char(`-`) {
				if l.match_next_char(`-`) {
					l.new_token('---', .minus_concat, 3)
				} else {
					l.new_token('--', .minus_concat, 2)
				}
			} else {
				l.new_token('-', .minus, 1)
			}
		}
		`<` {
			if l.match_next_char(`-`) {
				l.new_token('<-', .left_arrow, 2)
			} else if l.match_next_char(`=`) {
				l.new_token('<=', .le, 2)
			} else if l.match_next_char(`>`) {
				l.new_token('<>', .string_concat, 2)
			} else {
				l.new_token('<', .lt, 1)
			}
		}
		`>` {
			if l.match_next_char(`=`) {
				l.new_token('>=', .ge, 2)
			} else {
				l.new_token('>', .gt, 1)
			}
		}
		`.` {
			if l.match_next_char(`.`) {
				l.new_token('..', .range, 2)
			} else {
				l.new_token('.', .dot, 1)
			}
		}
		`:` {
			if l.match_next_char(`:`) {
				l.new_token('::', .typedef, 2)
			} else {
				l.new_token(':', .typedef, 1)
			}
		}
		`*` {
			l.new_token('*', .mul, 1)
		}
		`,` {
			l.new_token(',', .comma, 1)
		}
		`/` {
			l.new_token(',', .div, 1)
		}
		`(` {
			l.new_token('(', .lpar, 1)
		}
		`)` {
			l.new_token(')', .rpar, 1)
		}
		`{` {
			l.new_token('{', .lcbr, 1)
		}
		`}` {
			l.new_token('}', .rcbr, 1)
		}
		`[` {
			l.new_token('[', .rsbr, 1)
		}
		`]` {
			l.new_token(']', .rsbr, 1)
		}
		10 {
			l.new_token_new_line()
		}
		else {
			l.match_else()
		}
	}
}

fn (mut l Lexer) new_token_new_line() token.Token {
	l.advance(1)
	l.lines++
	l.pos_inline = 0
	return token.Token{
		kind: .newline
		lit: '\\n'
		line_nr: l.lines - 1
		pos: l.pos
	}
}

fn (mut l Lexer) new_token_eof() token.Token {
	return token.Token{
		kind: .eof
		lit: '\0'
		line_nr: l.lines
		pos: l.pos_inline
	}
}

fn (mut l Lexer) new_token(lit string, kind token.Kind, forward int) token.Token {
	l.advance(forward)
	mut value := token.LiteralValue{}
	if kind == .integer {
		value = token.LiteralValue{
			ival: lit.int()
		}
	} else if kind == .float {
		println(lit)
		value = token.LiteralValue{
			fval: lit.f32()
		}
	} else if kind == .float {
		value = token.LiteralValue{
			sval: lit
		}
	}
	return token.Token{
		kind: kind
		lit: lit
		line_nr: l.lines
		pos: l.pos_inline
		value: value
	}
}

fn (mut l Lexer) match_else() token.Token {
	s := l.input[l.pos]
	return l.get_token_word(s) or { l.get_token_integer(s) or { l.new_token('[i]', .ignore, 1) } }
}

fn (mut l Lexer) get_token_word(cch u8) !token.Token {
	term, is_capital := l.get_word(cch)
	if term.len > 0 {
		if is_capital {
			return l.new_token(term, token.Kind.modl, term.len)
		} else {
			return l.new_token(term, token.key_to_token(term), term.len)
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
		return l.new_token(l.input[start_pos..(l.pos - delim_end.len)].bytestr(), kind,
			0)
	} else {
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
	mut pos := l.pos + 1
	start_pos := pos
	for is_letter(current_ch) && pos < l.total {
		current_ch = l.input[pos]
		pos += 1
	}
	return l.input[start_pos..pos].bytestr(), is_first_capital
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

fn is_letter(a u8) bool {
	return (a >= `a` && a <= `z`) || (a >= `A` && a <= `Z`) || a == `_`
}

fn is_capital(a u8) bool {
	return a >= `A` && a <= `Z`
}

fn is_digit(a rune) bool {
	return a >= `0` && a <= `9`
}
