import os
import lexer
import token

fn test_lexer_ex_file() {
	input := os.read_file('example.ex') or { panic("File 'example.ex' not exists on root dir") }
	mut a := lexer.new(input)
	a.generate_tokens()
	assert 96 == a.pos
	assert 96 == a.total
	assert 38 == a.tokens.len
}

fn test_plus_terms() {
	mut a := lexer.new('5+5')
	a.generate_tokens()
	assert [
		token.Token{
			kind: .integer
			lit: '5'
			line_nr: 1
			pos: 1
		},
		token.Token{
			kind: .plus
			lit: '+'
			line_nr: 1
			pos: 2
		},
		token.Token{
			kind: .integer
			lit: '5'
			line_nr: 1
			pos: 3
		},
		token.Token{
			kind: .eof
			lit: '\0'
			line_nr: 1
			pos: 3
		},
	] == a.tokens
}

fn test_line_break() {
	mut a := lexer.new('5+5\n6+2')
	a.generate_tokens()
	assert 2 == a.lines
	assert [
		token.Token{
			kind: .integer
			lit: '5'
			line_nr: 1
			pos: 1
		},
		token.Token{
			kind: .plus
			lit: '+'
			line_nr: 1
			pos: 2
		},
		token.Token{
			kind: .integer
			lit: '5'
			line_nr: 1
			pos: 3
		},
		token.Token{
			kind: .newline
			lit: '\\n'
			line_nr: 1
			pos: 4
		},
		token.Token{
			kind: .integer
			lit: '6'
			line_nr: 2
			pos: 1
		},
		token.Token{
			kind: .plus
			lit: '+'
			line_nr: 2
			pos: 2
		},
		token.Token{
			kind: .integer
			lit: '2'
			line_nr: 2
			pos: 3
		},
		token.Token{
			kind: .eof
			lit: '\0'
			line_nr: 2
			pos: 7
		},
	] == a.tokens
}
