module lexer

import compiler_v.token

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

pub fn (mut l Lexer) generate_one_token() token.Token {
	return l.parse_token()
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
	for i := l.pos; i <= l.pos + qtd; i++ {
		if l.input[i] == 10 {
			l.pos_inline = 0
		} else {
			l.pos_inline += 1
		}
	}
	l.pos += qtd
}

fn (mut l Lexer) skip_space() token.Token {
	l.advance(1)
	return l.parse_token()
}

fn (mut l Lexer) match_else() token.Token {
	s := l.input[l.pos]

	return l.get_token_word(s) or {
		l.get_token_integer(s) or {
			l.advance(1)
			return l.parse_token()
		}
	}
}
