import compiler_v
import os

pub fn test_hello_world_ex_file() {
	file := 'hello_world'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'HelloWorld' == bin.program.modules['HelloWorld'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:HelloWorld]},[{:do,{:def, [line: 2,type: SUM::string], [{:main, [line: 2,type: SUM::string], []},[{:do,"Hello World"}]]}}]]}}' == bin.program.modules['HelloWorld'].str()
	assert 'Hello World' == compiler_v.execute(mut bin)
}
