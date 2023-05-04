import os
import lexer

fn test_lexer_ex_file() {
	input := os.read_file('example.ex') or {
		panic("File 'example.ex' not exists on root dir")
	}
	a := lexer.new(input)
	assert 96 == a.pos
	assert 96 == a.total
	assert 37 == a.tokens.len
}