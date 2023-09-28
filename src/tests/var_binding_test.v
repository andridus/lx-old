import compiler_v
import os

pub fn test_sum_ex_file() {
	file := 'var_binding'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'VarBindingTest' == bin.program.modules['VarBindingTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:VarBindingTest]},[{:do,{:def, [line: 5,type: SUM::float], [{:main, [line: 5,type: SUM::float], []},[{:do,{:__block__, [line: 6,type: float], [{:=, [line: 6,type: integer], [{:x, [line: 6,type: integer], []},1]},{:=, [line: 7,type: integer], [{:y, [line: 7,type: integer], []},{:x, [line: 8,type: integer], []}]},{:=, [line: 19,type: integer], [1,{:x, [line: 20,type: integer], []}]},{:=, [line: 20,type: integer], [1,{:y, [line: 21,type: integer], []}]},{:=, [line: 24,type: float], [{:z, [line: 24,type: float], []},1.5]},{:z, [line: 40,type: float], []}]}}]]}}]]}}' == bin.program.modules['VarBindingTest'].str()
	assert '1.5' == compiler_v.execute(mut bin)
}
