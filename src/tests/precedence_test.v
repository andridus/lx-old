import compiler_v
import os

pub fn test_precedence_ex_file() {
	file := 'precedence'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'PrecedenceTest' == bin.program.modules['PrecedenceTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:PrecedenceTest]},[{:do,{:def, [line: 2,type: SUM::integer], [{:main, [line: 2,type: SUM::integer], []},[{:do,{:+, [line: 3,type: integer], [{:-, [line: 3,type: integer], [{:-, [line: 3,type: integer], [{:+, [line: 3,type: integer], [{:+, [line: 3,type: integer], [1,2]},3]},2]},{:/, [line: 3,type: integer], [{:*, [line: 3,type: integer], [{:/, [line: 3,type: integer], [5,2]},3]},4]}]},{:/, [line: 3,type: integer], [5,{:+, [line: 3,inside_parens: true,type: integer], [1,2]}]}]}}]]}}]]}}' == bin.program.modules['PrecedenceTest'].str()
	assert '4' == compiler_v.execute(mut bin)
}
