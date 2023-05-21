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
	fn test_parser_grammar() {

	    mut a := lexer.new('
	      true
		  false
		  nil
		  when
		  and
		  or
	      not
          in
          fn
          do
          end
          catch
          rescue
          after
          else
		')

	assert [
		token.Token{
			kind: .key_true
			lit: 'true'
			line_nr: 1
			pos: 1
		},
		token.Token{
			kind: .key_false
			lit: 'false'
			line_nr: 2
			pos: 1
		},
		token.Token{
			kind: .key_nil
			lit: 'nil'
			line_nr: 3
			pos: 1
		},
		token.Token{
			kind: .key_when
			lit: 'when'
			line_nr: 4
		    pos: 1
		},
		token.Token{
			kind: .key_and
			lit: 'and'
			line_nr: 5
			pos: 1
		},
		token.Token{
			kind: .key_or
			lit: 'or'
			line_nr: 6
			pos: 1
		},
        token.Token{
			kind: .key_not
			lit: 'not'
			line_nr: 7
			pos: 1
		},
		token.Token{
			kind: .key_in
			lit: 'in'
			line_nr: 8
			pos: 1
		},
        token.Token{
			kind: .key_fn
			lit: 'fn'
			line_nr: 9
			pos: 1
		},
		token.Token{
			kind: .key_do
			lit: 'do'
			line_nr: 10
			pos: 1
		},
		token.Token{
			kind: .key_end
			lit: 'end'
			line_nr: 11
			pos: 1
		},
		token.Token{
			kind: .key_catch
			lit: 'catch'
			line_nr: 12
			pos: 1
		},

		token.Token{
			kind: .key_rescue
			lit: 'rescue'
			line_nr: 13
		    pos: 1
		},
		token.Token{
			kind: .key_after
			lit: 'after'
			line_nr: 14
			pos: 1
		},
		token.Token{
			kind: .eof
			lit: '\0'
			line_nr: 14
			pos: 6
		},
	] == a.tokens
}
