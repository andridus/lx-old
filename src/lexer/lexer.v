module lexer
import token
pub struct Lexer {
	input []u8
	pub mut:
		lines int = 1
		pos int
		pos_inline int
		total int
		tokens []token.Token
}

pub fn new(input string) Lexer {
	mut bytes := input.bytes()
	bytes << 0
	mut l := Lexer {
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
		if tok.typ !=._ignore {
			l.tokens << tok
		}
	}
	if l.tokens.len > 0 { l.tokens << l.new_token_eof() }

}
fn has_next(i int, total int) bool{
	return i < total
}
fn (l Lexer) match_next_char(u u8) bool{
	pos := l.pos + 1
	return has_next(pos, l.total) && u == l.input[pos]
}
fn (l Lexer) match_next_space_or_nil() bool{
	pos := l.pos + 1
	return has_next(pos, l.total) && 32 == l.input[pos]
}
fn (mut l Lexer) parse_token() token.Token {
	if l.pos == l.total  { return l.new_token_eof() }

	u := l.input[l.pos]
	tok := match u {
		`a` {
			if l.match_next_char(`n`) {
				if l.match_next_char(`d`) {
					if l.match_next_space_or_nil() {
						l.new_token('and',._and, 4)
					}else{
						l.match_else()
					}
				}else{
					l.match_else()
				}
			} else{
				l.match_else()
			}
		}
		`d` {
			if l.match_next_char(`e`) {
				if l.match_next_char(`f`) {
					if l.match_next_space_or_nil() {
						l.new_token('def',._def, 4)
					}else{
						l.match_else()
					}
				}else{
					l.match_else()
				}
			} else{
				l.match_else()
			}
		}
		`e` {
			if l.match_next_char(`l`) {
				if l.match_next_char(`s`) {
					if l.match_next_char(`e`) {
						if l.match_next_space_or_nil() {
							l.new_token('else',._else, 5)
						}else{
							l.match_else()
						}
					}else{
						l.match_else()
					}
				}else{
					l.match_else()
				}
			} else if l.match_next_char(`n`) {
				if l.match_next_char(`d`) {
					if l.match_next_space_or_nil() {
						l.new_token('end',._end, 4)
					}else{
						l.match_else()
					}
				}else{
					l.match_else()
				}
			}else{
				l.match_else()
			}
		}
		`f` {
			if l.match_next_char(`a`) {
				if l.match_next_char(`l`) {
					if l.match_next_char(`s`) {
						if l.match_next_char(`e`) {
							if l.match_next_space_or_nil() {
								l.new_token('false',._false, 6)
							}else{
								l.match_else()
							}
						}else{
							l.match_else()
						}
					}else{
						l.match_else()
					}
				}else{
					l.match_else()
				}
			}else{
				l.match_else()
			}
		}
		`n` {
			if l.match_next_char(`i`) {
				if l.match_next_char(`l`) {
					if l.match_next_space_or_nil() {
						l.new_token('nil',._nil, 4)
					}else{
						l.match_else()
					}
				}else{
					l.match_else()
				}
			}else{
				l.match_else()
			}
		}
		`t` {
			if l.match_next_char(`r`) {
				if l.match_next_char(`u`) {
					if l.match_next_char(`e`) {
						if l.match_next_space_or_nil() {
							l.new_token('true',._true, 5)
						}else{
							l.match_else()
						}
					}else{
						l.match_else()
					}
				}else{
					l.match_else()
				}
			}else{
				l.match_else()
			}
		}
		`w` {
			if l.match_next_char(`h`) {
				if l.match_next_char(`e`) {
					if l.match_next_char(`n`) {
						if l.match_next_space_or_nil() {
							l.new_token('when',._when, 5)
						}else{
							l.match_else()
						}
					}else{
						l.match_else()
					}
				}else{
					l.match_else()
				}
			}else{
				l.match_else()
			}
		}
		`=` {
			if l.match_next_char(`=`) {
				if l.match_next_char(`=`) {
					l.new_token('===',._eq_op, 3)
				}else{
					l.new_token('==',._eq_op, 2)
				}
			} else if l.match_next_char(`>`) {
				l.new_token('=>',._right_double_arrow, 2)
			} else if l.match_next_char(`~`) {
				l.new_token('=~',._eq_op, 2)
			} else{
				l.new_token('=',._assign, 1)
			}
		}
		`!` {
			if l.match_next_char(`=`) {
				if l.match_next_char(`=`) {
					l.new_token('!==',._neq_op, 3)
				}else{
					l.new_token('!=',._neq_op, 2)
				}
			}else{
				l.new_token('!',._bang_op, 1)
			}
		}
		`&` {
			if l.match_next_char(`&`) {
				if l.match_next_char(`&`) {
					l.new_token('&&&',._and, 3)
				}else{
					l.new_token('&&',._and, 2)
				}
			}else{
				l.new_token('&',._capture_op, 1)
			}
		}
		`|` {
			if l.match_next_char(`|`) {
				if l.match_next_char(`|`) {
					l.new_token('|||',._or_op, 3)
				}else{
					l.new_token('||',._or_op, 2)
				}
			}else{
				l.new_token('|',._pipe_op, 1)
			}
		}
		`+` {
			if l.match_next_char(`+`) {
				if l.match_next_char(`+`) {
					l.new_token('+++',._concat_op, 3)
				}else{
					l.new_token('++',._concat_op, 2)
				}
			} else{
				l.new_token('+',._plus_op, 1)
			}
		}
		`-` {
			if l.match_next_char(`-`) {
				if l.match_next_char(`-`) {
					l.new_token('---',._concat_op, 3)
				}else{
					l.new_token('--',._concat_op, 2)
				}
			}else{
				l.new_token('-',._minus_op, 1)
			}
		}
		`<` {
			if l.match_next_char(`-`) {
				l.new_token('<-',._left_arrow, 2)
			} else if l.match_next_char(`=`) {
				l.new_token('<=',._elt_op, 2)
			} else if l.match_next_char(`>`) {
				l.new_token('<>',._concat_op, 2)
			}else{
				l.new_token('<',._lt_op, 1)
			}
		}
		`>` {
			if l.match_next_char(`=`) {
				l.new_token('>=',._egt_op, 2)
			}else{
				l.new_token('>',._gt_op, 1)
			}
		}
		`.` {
			if l.match_next_char(`.`) {
				l.new_token('..',._range_op, 2)
			}else{
				l.new_token('.',._dot, 1)
			}
		}
		`:` {
			if l.match_next_char(`:`) {
				l.new_token('::',._type, 2)
			}else{
				l.new_token(':',._type, 1)
			}
		}
		`*` {
			l.new_token('*',._mult_op, 1)
		}
		`,` {
			l.new_token(',',._comma, 1)
		}
		`/` {
			l.new_token(',',._div_op, 1)
		}
		`(` {
			l.new_token('(',._left_parens, 1)
		}
		`)` {
			l.new_token(')',._right_parens, 1)
		}
		`{` {
			l.new_token('{',._left_braces, 1)
		}
		`}` {
			l.new_token('}',._right_braces, 1)
		}
		10 {
			l.new_token_new_line()
		}
		else {
				l.match_else()
		}
	}
	return tok
}

fn (mut l Lexer) new_token_new_line() token.Token {
		l.lines++
		l.pos++
		l.pos_inline = 0
	return token.Token {
		typ: ._linebreak
		literal: '\\n'
		line: l.lines - 1
		pos: l.pos
	}
}
fn (mut l Lexer) new_token_eof() token.Token {
	return token.Token {
		typ: ._eof
		literal: '$'
		line: l.lines
		pos: l.pos
	}
}
fn (mut l Lexer) new_token(key string, typ token.Typ, forward int) token.Token {
	l.pos += forward
	l.pos_inline += forward
	return token.Token {
		typ: typ
		literal: key
		line: l.lines
		pos: l.pos_inline
	}
}
fn (mut l Lexer) match_else() token.Token {
	s := l.input[l.pos].ascii_str()
	return l.get_token_word(s) or {
		l.get_token_integer(s) or {
			l.new_token('s',._ignore,1)
		}
	}
}
fn (mut l Lexer) get_token_word(cch string) !token.Token {
	term := l.get_word(cch)
	if term.len > 0  {
		return l.new_token(term, ._atom, term.len)
	} else {
		return error("not have a word")
	}
}
fn (mut l Lexer) get_token_integer(cch string) !token.Token {
	term, typ := l.get_number(cch)
	if term.len > 0  {
		return l.new_token(term, typ, term.len)
	} else {
		return error("not have a integer")
	}
}

fn (l Lexer) get_word(cch string) string {
	mut str := ''
	mut current_ch := cch
	mut pos := l.pos + 1
	for is_letter(current_ch) && pos < l.total {
		str += current_ch
		current_ch = l.input[pos].ascii_str()
		pos += 1
	}
	return str
}
fn (mut l Lexer) get_number(cch string) (string, token.Typ) {
	mut str := ''
	mut current_ch := cch
	mut pos := l.pos + 1
	mut typ := token.Typ._integer
	for (is_digit(current_ch) && pos <= l.total) || (str.len > 0 && current_ch in ['.', '_'] && pos <= l.total) {
		if current_ch == '.' { typ = ._float}
		str += current_ch
		current_ch = l.input[pos].ascii_str()
		pos += 1
	}
	return str.replace('_',''), typ

}


fn is_letter(a string) bool {
	return (a >= 'a' && a<= 'z') || (a >= 'A' && a <= 'Z') || (a == '_')
}
fn is_digit(a string) bool {
	return (a >= '0' && a<= '9')
}
