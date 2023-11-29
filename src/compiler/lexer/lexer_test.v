module lexer

import compiler.token

fn test_new_empty_lexer() {
	one_lexer := Lexer{}
	assert []rune{} == one_lexer.input
	// assert [`1`,`+`,`2`] == one_lexer.input
}

fn test_new_lexer() {
	one_input := '1+2'
	one_lexer := new(one_input)
	assert [`1`, `+`, `2`] == one_lexer.input

	two_input := '1 + 2'
	two_lexer := new(two_input)
	assert [`1`, ` `, `+`, ` `, `2`] == two_lexer.input
}

fn test_get_first_token() {
	one_input := '1 + 2'
	mut one_lexer := new(one_input)
	assert 0 == one_lexer.pos
	assert token.Token{
		kind: .integer
		lit: '1'
	} == one_lexer.parse_next_token()
}

fn test_last_token() {
	one_input := '1'
	mut one_lexer := new(one_input)
	assert 0 == one_lexer.pos
	assert token.Token{
		kind: .integer
		lit: '1'
	} == one_lexer.parse_next_token()

	assert token.Token{
		kind: .eof
	} == one_lexer.parse_next_token()
}

fn test_when_not_has_input() {
	one_input := ''
	mut one_lexer := new(one_input)
	assert 0 == one_lexer.pos
	assert token.Token{
		kind: .eof
	} == one_lexer.parse_next_token()
}

fn test_parse_token_without_spaces() {
	one_input := '1 + 1'
	mut one_lexer := new(one_input)
	assert 0 == one_lexer.pos

	assert token.Token{
		kind: .integer
		lit: '1'
	} == one_lexer.parse_next_token()
	assert 1 == one_lexer.pos

	assert token.Token{
		kind: .ident
		lit: '+'
	} == one_lexer.parse_next_token()
	assert 3 == one_lexer.pos

	assert token.Token{
		kind: .integer
		lit: '1'
	} == one_lexer.parse_next_token()
	assert 5 == one_lexer.pos
}

fn test_parse_integer() {
	one_input := '11'
	mut one_lexer := new(one_input)
	tk := one_lexer.parse_next_token()

	assert token.Token{
		kind: .integer
		lit: '11'
	} == tk
	assert 2 == one_lexer.pos
	assert token.Value(11) == tk.get_value()
}

fn test_parse_integer_with_ident() {
	one_input := '11 + 1'
	mut one_lexer := new(one_input)
	tk := one_lexer.parse_next_token()

	assert token.Token{
		kind: .integer
		lit: '11'
	} == tk
	assert 2 == one_lexer.pos
	assert token.Value(11) == tk.get_value()

	tk2 := one_lexer.parse_next_token()
	assert token.Token{
		kind: .ident
		lit: '+'
	} == tk2
	assert 4 == one_lexer.pos
	assert token.Value('+') == tk2.get_value()

	tk3 := one_lexer.parse_next_token()
	assert token.Token{
		kind: .integer
		lit: '1'
	} == tk3
	assert 6 == one_lexer.pos
	assert token.Value(1) == tk3.get_value()
}

fn test_parse_ident() {
	one_input := '+'
	mut one_lexer := new(one_input)
	tk := one_lexer.parse_next_token()
	assert token.Token{
		kind: .ident
		lit: '+'
	} == tk
	assert token.Value('+') == tk.get_value()
}
