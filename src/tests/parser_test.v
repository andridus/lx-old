import parser
// import ast
import lexer

fn test_failed_assign_statements() {
	input := '5 + 5'

	l := lexer.new(input)
	mut p := parser.new(l)
	program := p.parse_program()
	assert program.is_error == true
	assert program.errors == ['Invalid Expected Sintaxe']
	assert program.statements.len == 0
}

fn test_assign_statements() {
	input := 'a = 5'

	l := lexer.new(input)
	mut p := parser.new(l)
	program := p.parse_program()
	assert '{:=, [line: 1], [{:a, [line: 1], nil}, 5]}' == program.statements[0].get_ex_ast()
}
