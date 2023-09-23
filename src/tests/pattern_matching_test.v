import compiler_v
import os

pub fn test_pattern_matching_ex_file() {
	file := 'pattern_matching'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module

	assert 'PatternMatchingTest' == bin.program.modules['PatternMatchingTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:PatternMatchingTest]},[{:do,{:__block__, [line: 3], [{:def, [line: 3,type: SUM::integer], [{:sum, [line: 3,type: SUM::integer], [{a, [line: 6,type: integer], []},{b, [line: 6,type: integer], []}]},[{:do,{:+, [line: 4,type: integer], [{a, [line: 4,type: integer], []},{b, [line: 4,type: integer], []}]}}]]},{:def, [line: 6,type: SUM::integer], [{:sub, [line: 6,type: SUM::integer], [{a, [line: 9,type: integer], []},{b, [line: 9,type: integer], []}]},[{:do,{:-, [line: 7,type: integer], [{a, [line: 7,type: integer], []},{b, [line: 7,type: integer], []}]}}]]},{:def, [line: 9,type: SUM::integer], [{:mul, [line: 9,type: SUM::integer], [{a, [line: 12,type: integer], []},{b, [line: 12,type: integer], []}]},[{:do,{:*, [line: 10,type: integer], [{a, [line: 10,type: integer], []},{b, [line: 10,type: integer], []}]}}]]},{:def, [line: 12,type: SUM::integer], [{:div, [line: 12,type: SUM::integer], [{a, [line: 16,type: integer], []},{b, [line: 16,type: integer], []}]},[{:do,{:/, [line: 13,type: integer], [{a, [line: 13,type: integer], []},{b, [line: 13,type: integer], []}]}}]]},{:def, [line: 16,type: SUM::atom], [{:main, [line: 16,type: SUM::atom], []},[{:do,{:__block__, [line: 16,type: atom], [{:=, [line: 17,type: integer], [3,{{:., [line: 17,type: integer], [{:__aliases__, [line: 17,type: integer], [:PatternMatchingTest]},:sum]}, [line: 17,type: integer], [1,2]}]},{:=, [line: 18,type: integer], [1,{{:., [line: 18,type: integer], [{:__aliases__, [line: 18,type: integer], [:PatternMatchingTest]},:sub]}, [line: 18,type: integer], [2,1]}]},{:=, [line: 19,type: integer], [6,{{:., [line: 19,type: integer], [{:__aliases__, [line: 19,type: integer], [:PatternMatchingTest]},:mul]}, [line: 19,type: integer], [3,2]}]},{:=, [line: 20,type: integer], [4,{{:., [line: 20,type: integer], [{:__aliases__, [line: 20,type: integer], [:PatternMatchingTest]},:div]}, [line: 20,type: integer], [8,2]}]},{:=, [line: 22,type: string], ["Hello World","Hello World"]},:ok]}}]]}]}}]]}}' == bin.program.modules['PatternMatchingTest'].str()
	assert ':ok' == compiler_v.execute(mut bin)
}
