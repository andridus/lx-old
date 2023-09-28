import compiler_v
import os

pub fn test_integer_ex_file() {
	file := 'integer'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'IntegerTest' == bin.program.modules['IntegerTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:IntegerTest]},[{:do,{:def, [line: 3,type: SUM::atom], [{:main, [line: 3,type: SUM::atom], []},[{:do,{:__block__, [line: 4,type: atom], [{:=, [line: 4,type: integer], [2,{:+, [line: 4,type: integer], [1,1]}]},{:=, [line: 5,type: integer], [4,{:-, [line: 5,type: integer], [5,1]}]},{:=, [line: 6,type: integer], [2,{:/, [line: 6,type: integer], [5,2]}]},{:=, [line: 7,type: integer], [9,{:*, [line: 7,type: integer], [3,3]}]},{:=, [line: 9,type: bool], [:true,{:>, [line: 9,type: bool], [2,1]}]},{:=, [line: 10,type: bool], [:false,{:<, [line: 10,type: bool], [2,1]}]},{:=, [line: 11,type: bool], [:true,{:>=, [line: 11,type: bool], [2,1]}]},{:=, [line: 12,type: bool], [:false,{:<=, [line: 12,type: bool], [2,1]}]},:ok]}}]]}}]]}}' == bin.program.modules['IntegerTest'].str()
	assert ':ok' == compiler_v.execute(mut bin)
}
