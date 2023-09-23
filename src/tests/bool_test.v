import compiler_v
import os

pub fn test_bool_ex_file() {
	file := 'bool'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'BoolTest' == bin.program.modules['BoolTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:BoolTest]},[{:do,{:def, [line: 3,type: SUM::atom], [{:main, [line: 3,type: SUM::atom], []},[{:do,{:__block__, [line: 3,type: atom], [{:=, [line: 4,type: bool], [:false,{:&&, [line: 4,type: bool], [:false,:false]}]},{:=, [line: 5,type: bool], [:false,{:&&, [line: 5,type: bool], [:false,:true]}]},{:=, [line: 6,type: bool], [:false,{:&&, [line: 6,type: bool], [:true,:false]}]},{:=, [line: 7,type: bool], [:true,{:&&, [line: 7,type: bool], [:true,:true]}]},{:=, [line: 9,type: bool], [:false,{:||, [line: 9,type: bool], [:false,:false]}]},{:=, [line: 10,type: bool], [:true,{:||, [line: 10,type: bool], [:false,:true]}]},{:=, [line: 11,type: bool], [:true,{:||, [line: 11,type: bool], [:true,:false]}]},{:=, [line: 12,type: bool], [:true,{:||, [line: 12,type: bool], [:true,:true]}]},{:=, [line: 14,type: bool], [:false,{:!, [line: 14,type: bool], [:true]}]},{:=, [line: 15,type: bool], [:true,{:!, [line: 15,type: bool], [{:!, [line: 15,type: bool], [:true]}]}]},{:=, [line: 16,type: bool], [:true,{:!, [line: 16,type: bool], [:false]}]},{:=, [line: 17,type: bool], [:false,{:!, [line: 17,type: bool], [{:!, [line: 17,type: bool], [:false]}]}]},:ok]}}]]}}]]}}' == bin.program.modules['BoolTest'].str()
	assert ':ok' == compiler_v.execute(mut bin)
}
