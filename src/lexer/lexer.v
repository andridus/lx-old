module lexer
import token
pub struct Lexer {
	input []u8
	pub mut:
		pos int
		total int
		tokens []token.Token
}

pub fn new(input string) Lexer {
	mut l := Lexer {
		input: input.bytes()
		total: input.len
	}
	for l.pos < l.total {
		l.tokens << l.parse_token()
	}
	l.tokens = l.tokens.filter(it.typ != 'IGNORE')
	return l
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
	u := l.input[l.pos]
	tok := match u {
		`a` {
			if l.match_next_char(`n`) {
				if l.match_next_char(`d`) {
					if l.match_next_space_or_nil() {
						l.new_token('and','END', 4)
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
						l.new_token('def','DEF', 4)
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
							l.new_token('else','ELSE', 5)
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
						l.new_token('end','END', 4)
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
								l.new_token('false','FALSE', 6)
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
						l.new_token('nil','NIL', 4)
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
							l.new_token('true','TRUE', 5)
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
							l.new_token('when','WHEN', 5)
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
					l.new_token('===','COMP', 3)
				}else{
					l.new_token('==','COMP', 2)
				}
			} else if l.match_next_char(`>`) {
				l.new_token('=>','R_DOUBLE_ARROW', 2)
			} else if l.match_next_char(`~`) {
				l.new_token('=~','COMP', 2)
			} else{
				l.new_token('=','ASSIGN', 1)
			}
		}
		`!` {
			if l.match_next_char(`=`) {
				if l.match_next_char(`=`) {
					l.new_token('!==','COMP', 3)
				}else{
					l.new_token('!=','COMP', 2)
				}
			}else{
				l.new_token('!','BANG', 1)
			}
		}
		`&` {
			if l.match_next_char(`&`) {
				if l.match_next_char(`&`) {
					l.new_token('&&&','AND', 3)
				}else{
					l.new_token('&&','AND', 2)
				}
			}else{
				l.new_token('&','CAPTURE', 1)
			}
		}
		`|` {
			if l.match_next_char(`|`) {
				if l.match_next_char(`|`) {
					l.new_token('|||','OR', 3)
				}else{
					l.new_token('||','OR', 2)
				}
			}else{
				l.new_token('|','PIPE', 1)
			}
		}
		`+` {
			if l.match_next_char(`+`) {
				if l.match_next_char(`+`) {
					l.new_token('---','CONCAT', 3)
				}else{
					l.new_token('--','CONCAT', 2)
				}
			} else if l.match_next_char(`-`) {
				l.new_token('->','R_ARROW', 2)
			}else{
				l.new_token('-','OPERATOR', 1)
			}
		}
		`-` {
			if l.match_next_char(`+`) {
				l.new_token('++','CONCAT', 2)
			}else{
				l.new_token('+','OPERATOR', 1)
			}
		}
		`<` {
			if l.match_next_char(`-`) {
				l.new_token('<-','L_ARROW', 2)
			} else if l.match_next_char(`=`) {
				l.new_token('<=','OPERATOR', 2)
			} else if l.match_next_char(`>`) {
				l.new_token('<>','CONCAT', 2)
			}else{
				l.new_token('<','OPERATOR', 1)
			}
		}
		`>` {
			if l.match_next_char(`=`) {
				l.new_token('>=','OPERATOR', 2)
			}else{
				l.new_token('>','OPERATOR', 1)
			}
		}
		`.` {
			if l.match_next_char(`.`) {
				l.new_token('..','RANGE', 2)
			}else{
				l.new_token('.','DOT', 1)
			}
		}
		`:` {
			if l.match_next_char(`:`) {
				l.new_token('::','TYPE', 2)
			}else{
				l.new_token(':','TYPE', 1)
			}
		}
		`*` {
			l.new_token('*','OPERATOR', 1)
		}
		`,` {
			l.new_token(',','COMMA', 1)
		}
		`/` {
			l.new_token(',','OPERATOR', 1)
		}
		`(` {
			l.new_token('(','L_PARENS', 1)
		}
		`)` {
			l.new_token('(','R_PARENS', 1)
		}
		`{` {
			l.new_token('(','L_BRACKET', 1)
		}
		`}` {
			l.new_token('(','R_BRACKET', 1)
		}
		else {
				l.match_else()
		}
	}
	return tok
}

fn (mut l Lexer) match_else() token.Token {
	s := l.input[l.pos].ascii_str()
	return l.get_token_word(s) or {
		l.get_token_integer(s) or {
			l.new_token('s','IGNORE',1)
		}
	}
}
fn (mut l Lexer) get_token_word(cch string) !token.Token {
	term := l.get_word(cch)
	if term.len > 0  {
		return l.new_token(term, 'ATOM', term.len)
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
fn (mut l Lexer) get_number(cch string) (string, string) {
	mut str := ''
	mut current_ch := cch
	mut pos := l.pos + 1
	mut typ := 'INTEGER'
	for (is_digit(current_ch) && pos < l.total) || (str.len > 0 && current_ch in ['.', '_'] && pos < l.total) {
		if current_ch == '.' { typ = 'FLOAT'}
		str += current_ch
		current_ch = l.input[pos].ascii_str()
		pos += 1
	}
	return str.replace('_',''), typ

}

fn (mut l Lexer) new_token(key string, typ string, forward int) token.Token {
	l.pos += forward
	return token.Token {
		typ: typ
		literal: key
	}
}
fn is_letter(a string) bool {
	return (a >= 'a' && a<= 'z') || (a >= 'A' && a <= 'Z') || (a == '_')
}
fn is_digit(a string) bool {
	return (a >= '0' && a<= '9')
}
