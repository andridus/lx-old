// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module lexer

import compiler_v.token

pub fn new(input string) &Lexer {
	mut bytes := input.bytes()
	bytes << 0
	mut l := &Lexer{
		input: bytes
		total: input.len
	}
	return l
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
		pos_inline: l.pos_inline
	}
}

fn (mut l Lexer) new_token_eof() token.Token {
	return token.Token{
		kind: .eof
		lit: '\0'
		line_nr: l.lines
		pos: l.pos
		pos_inline: l.pos_inline
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
		value = token.LiteralValue{
			fval: lit.f64()
		}
	} else if kind in [.float, .atom] {
		value = token.LiteralValue{
			sval: lit
		}
	}

	return token.Token{
		kind: kind
		lit: lit
		line_nr: l.lines
		pos: l.pos
		pos_inline: l.pos_inline
		value: value
	}
}
