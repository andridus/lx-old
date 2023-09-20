import compiler_v
import os
import compiler_v.table

// [assert_continues]
pub fn test_lexer_ex_file() {
	file := 'a'
	root := os.abs_path('')
	path := '${root}/src/tests/modules'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	assert 'A' == bin.program.modules['A'].name
	assert 'as' == bin.program.modules['A'].str()
	assert '2.01' == compiler_v.execute(mut bin)
}
