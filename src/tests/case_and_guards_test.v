import compiler_v
import os

pub fn test_sum_ex_file() {
	file := 'case_and_guards'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'CaseAndGuardsTest' == bin.program.modules['CaseAndGuardsTest'].name
	// assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:CaseAndGuardsTest]},[{:do,{:__block__, [line: 3], [{:def, [line: 3,type: SUM::bool], [{:number?, [line: 3,type: SUM::bool], [{:_x, [line: 6,type: integer], []}]},[{:do,:true}]]},{:def, [line: 6,type: SUM::bool], [{:number?, [line: 6,type: SUM::bool], [{:_x, [line: 10,type: any], []}]},[{:do,:false}]]},{:def, [line: 10,type: SUM::atom], [{:main, [line: 10,type: SUM::atom], []},[{:do,{:__block__, [line: 11,type: atom], [{:=, [line: 13,type: integer], [{:x0, [line: 13,type: integer], []},1]},{:case, [line: 14], [{:x0, [line: 14,type: integer], []},[{:do,[{:->, [line: 14], [[1],:true]},{:->, [line: 14], [[2],:false]}]}]]},{:=, [line: 21,type: integer], [{:x1, [line: 21,type: integer], []},1]},{:case, [line: 22], [{:x1, [line: 22,type: integer], []},[{:do,[{:->, [line: 22], [[1],:true]},{:->, [line: 22], [[{:_int, [line: 24,type: integer], []}],:false]}]}]]},{:=, [line: 29,type: integer], [{:x2, [line: 29,type: integer], []},1]},{:case, [line: 30], [{:x2, [line: 30,type: integer], []},[{:do,[{:->, [line: 30], [[{:_x, [line: 31,type: integer], []}],:true]},{:->, [line: 30], [[{:_, [line: 32,type: integer], []}],:false]}]}]]},{:=, [line: 39,type: integer], [{:x3, [line: 39,type: integer], []},1]},{:case, [line: 40], [{:x3, [line: 40,type: integer], []},[{:do,[{:->, [line: 40], [[{:x, [line: 41,type: integer], []}],{:x, [line: 42,type: integer], []}]},{:->, [line: 40], [[{:_, [line: 42,type: integer], []}],0]}]}]]},{:=, [line: 47,type: integer], [{:x4, [line: 47,type: integer], []},1]},{:case, [line: 48], [{:x4, [line: 48,type: integer], []},[{:do,[{:->, [line: 48], [[{:when, [line: 49,type: integer], [{:x, [line: 49,type: integer], []},{:==, [line: 49,type: bool], [{:x, [line: 49,type: integer], []},1]}]}],:true]},{:->, [line: 48], [[{:_, [line: 50,type: integer], []}],:false]}]}]]},{:=, [line: 55,type: integer], [{:x5, [line: 55,type: integer], []},1]},{:case, [line: 56], [{:x5, [line: 56,type: integer], []},[{:do,[{:->, [line: 56], [[{:when, [line: 57,type: integer], [{:x, [line: 57,type: integer], []},{:==, [line: 57,type: bool], [{:x, [line: 57,type: integer], []},1]}]}],:true]},{:->, [line: 56], [[{:_, [line: 58,type: integer], []}],:false]}]}]]},{:=, [line: 63,type: integer], [{:x6, [line: 63,type: integer], []},1]},{:case, [line: 64], [{:x6, [line: 64,type: integer], []},[{:do,[{:->, [line: 64], [[{:when, [line: 65,type: integer], [{:x, [line: 65,type: integer], []},{{:., [line: 65,type: bool], [{:__aliases__, [line: 65,type: bool], [:CaseAndGuardsTest]},:number?]}, [line: 65,type: bool], [{:x, [line: 65,type: integer], []}]}]}],:true]},{:->, [line: 64], [[{:_, [line: 66,type: integer], []}],:false]}]}]]},{:=, [line: 71,type: integer], [{:x7, [line: 71,type: integer], []},1]},{:case, [line: 72], [{:x7, [line: 72,type: integer], []},[{:do,[{:->, [line: 72], [[{:when, [line: 73,type: integer], [{:x, [line: 73,type: integer], []},{{:., [line: 73,type: bool], [{:__aliases__, [line: 73,type: bool], [:CaseAndGuardsTest]},:number?]}, [line: 73,type: bool], [{:x, [line: 73,type: integer], []}]}]}],:true]},{:->, [line: 72], [[{:_, [line: 74,type: integer], []}],:false]}]}]]},{:=, [line: 79,type: integer], [{:x8, [line: 79,type: integer], []},1]},{:case, [line: 80], [{:x8, [line: 80,type: integer], []},[{:do,[{:->, [line: 80], [[{:|, [line: 81,type: integer], [2,{:|, [line: 81,type: integer], [1,0]}]}],:true]},{:->, [line: 80], [[{:_, [line: 82,type: integer], []}],:false]}]}]]},{:=, [line: 87,type: integer], [{:x9, [line: 87,type: integer], []},1]},{:case, [line: 88], [{:x9, [line: 88,type: integer], []},[{:do,[{:->, [line: 88], [[{:|, [line: 89,type: integer], [2,{:|, [line: 89,type: integer], [{:when, [line: 89,type: integer], [{:x, [line: 89,type: integer], []},{:==, [line: 89,type: bool], [{:x, [line: 89,type: integer], []},10]}]},1]}]}],:true]},{:->, [line: 88], [[{:_, [line: 90,type: integer], []}],:false]}]}]]},:ok]}}]]}]}}]]}}' == bin.program.modules['CaseAndGuardsTest'].str()
	assert ':ok' == compiler_v.execute(mut bin)
}