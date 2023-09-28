import compiler_v
import os

pub fn test_float_ex_file() {
	file := 'float'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'FloatTest' == bin.program.modules['FloatTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:FloatTest]},[{:do,{:def, [line: 3,type: SUM::atom], [{:main, [line: 3,type: SUM::atom], []},[{:do,{:__block__, [line: 4,type: atom], [{:=, [line: 4,type: float], [2.0,{:+, [line: 4,type: float], [1.0,1.0]}]},{:=, [line: 5,type: float], [2.1,{:+, [line: 5,type: float], [1.0,1.1]}]},{:=, [line: 6,type: float], [4.4,{:-, [line: 6,type: float], [5.5,1.1]}]},{:=, [line: 7,type: float], [2.5,{:/, [line: 7,type: float], [5.0,2.0]}]},{:=, [line: 8,type: float], [9.3,{:*, [line: 8,type: float], [3.1,3.0]}]},{:=, [line: 10,type: bool], [:true,{:>, [line: 10,type: bool], [2.1,1.0]}]},{:=, [line: 11,type: bool], [:false,{:<, [line: 11,type: bool], [2.2,1.1]}]},{:=, [line: 12,type: bool], [:true,{:>=, [line: 12,type: bool], [2.0,1.0]}]},{:=, [line: 13,type: bool], [:false,{:<=, [line: 13,type: bool], [2.8,1.1]}]},:ok]}}]]}}]]}}' == bin.program.modules['FloatTest'].str()
	assert ':ok' == compiler_v.execute(mut bin)
}
