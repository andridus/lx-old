import compiler_v
import os

pub fn test_sum_ex_file() {
	file := 'enum'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'EnumTest' == bin.program.modules['EnumTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:EnumTest]},[{:do,{:__block__, [line: 4], [{:defenum, [line: 4], [[:dog,:cat,:rabbit]]},{:def, [line: 5,type: SUM::void], [{:print, [line: 5,type: SUM::void], [{:a, [line: 10,type: string], []}]},[{:do,{{:., [line: 6], [{:__aliases__, [line: 6], [:FFI.v]},:println]}, [line: 6], [{:a, [line: 6,type: string], []}]}}]]},{:def, [line: 10,type: SUM::void], [{:print, [line: 10,type: SUM::void], [{:a, [line: 15,type: enum_enumtest_kind], []}]},[{:do,{{:., [line: 11], [{:__aliases__, [line: 11], [:FFI.v]},:println]}, [line: 11], [{:a, [line: 11,type: enum_enumtest_kind], []}]}}]]},{:def, [line: 15,type: SUM::atom], [{:main, [line: 15,type: SUM::atom], []},[{:do,{:__block__, [line: 16,type: atom], [{:=, [line: 16,type: enum_enumtest_kind], [{:dog, [line: 16,type: enum_enumtest_kind], []},{:@, [line: 16,type: enum_enumtest_kind], [{:__aliases__, [line: 16,type: enum_enumtest_kind], [:EnumTest]},:dog]}]},{:=, [line: 17,type: enum_enumtest_kind], [{:cat, [line: 17,type: enum_enumtest_kind], []},{:@, [line: 17,type: enum_enumtest_kind], [{:__aliases__, [line: 17,type: enum_enumtest_kind], [:EnumTest]},:cat]}]},{:=, [line: 18,type: enum_enumtest_kind], [{:rabbit, [line: 18,type: enum_enumtest_kind], []},{:@, [line: 18,type: enum_enumtest_kind], [{:__aliases__, [line: 18,type: enum_enumtest_kind], [:EnumTest]},:rabbit]}]},{{:., [line: 19], [{:__aliases__, [line: 19], [:EnumTest]},:print]}, [line: 19], [{:cat, [line: 19,type: enum_enumtest_kind], []}]},{{:., [line: 20], [{:__aliases__, [line: 20], [:EnumTest]},:print]}, [line: 20], [{:dog, [line: 20,type: enum_enumtest_kind], []}]},{{:., [line: 21], [{:__aliases__, [line: 21], [:EnumTest]},:print]}, [line: 21], ["olá mundo \\n"]},{{:., [line: 22], [{:__aliases__, [line: 22], [:EnumTest]},:print]}, [line: 22], [{:rabbit, [line: 22,type: enum_enumtest_kind], []}]},:ok]}}]]}]}}]]}}' == bin.program.modules['EnumTest'].str()
	assert '_cat_\n_dog_\nolá mundo \n\n_rabbit_\n:ok' == compiler_v.execute(mut bin)
}
