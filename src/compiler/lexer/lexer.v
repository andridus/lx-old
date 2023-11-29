module lexer

import compiler.token

pub struct Lexer {
pub:
	input []rune
mut:
	pos int
}

fn new(text string) Lexer {
	input := text.runes()
	return Lexer{
		input: input
	}
}

fn (mut l Lexer) parse_next_token() token.Token {
	// return eof
	if l.pos >= l.input.len {
		return token.Token{}
	}

	ch := l.input[l.pos]
	l.pos++
	return match ch {
		` ` {
			l.parse_next_token()
		}
		else {
			l.maybe_token_integer() or {
				token.Token{
					kind: .ident
					lit: ch.str()
				}
			}
		}
	}
}

fn (mut l Lexer) maybe_token_integer() !token.Token {
	mut num := []rune{}

	// get the next token if is digit (for integer)
	mut i := l.pos - 1
	for i < l.input.len {
		ch := l.input[i]
		if is_digit(ch) {
			i++
			num << ch
		} else {
			break
		}
	}

	// adjust l.pos
	l.pos += if num.len > 0 { num.len - 1 } else { 0 }

	if num.len > 0 {
		return token.Token{
			kind: .integer
			lit: num.string()
		}
	} else {
		return error('not have an integer')
	}
}
