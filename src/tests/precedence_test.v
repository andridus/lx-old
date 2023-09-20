import compiler_v
import os

pub fn test_ok_atom_ex_file() {
	file := 'precedence'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'PrecedenceTest' == bin.program.modules['PrecedenceTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:PrecedenceTest]},[{:do,{:def, [line: 2,type: SUM::integer_], [{:main, [line: 2,type: SUM::integer_], []},[{:do,{:+, [line: 3,type: integer_], [{:-, [line: 3,type: integer_], [{:-, [line: 3,type: integer_], [{:+, [line: 3,type: integer_], [{:+, [line: 3,type: integer_], [1,2]},3]},2]},{:/, [line: 3,type: integer_], [{:*, [line: 3,type: integer_], [{:/, [line: 3,type: integer_], [5,2]},3]},4]}]},{:/, [line: 3,type: integer_], [5,{:+, [line: 3,inside_parens: true,type: integer_], [1,2]}]}]}}]]}}]]}}' == bin.program.modules['PrecedenceTest'].str()
	assert '4' == compiler_v.execute(mut bin)
}
