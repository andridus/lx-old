import compiler_v
import os
import compiler_v.table

// [assert_continues]
pub fn test_modules_ex_file() {
	file := 'a'
	root := os.abs_path('')
	path := '${root}/src/tests/modules'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	assert 'A' == bin.program.modules['A'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:B]},[{:do,{:def, [line: 2,type: SUM::float], [{:one, [line: 2,type: SUM::float], []},[{:do,:2.0}]]}}]]},{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:A]},[{:do,{:def, [line: 2,type: SUM::float], [{:main, [line: 2,type: SUM::float], []},[{:do,{{:., [line: 3,type: float], [{:__aliases__, [line: 3,type: float], [:B]},:one]}, [line: 3,type: float], []}}]]}}]]}}' == bin.program.modules['A'].str()
	assert '2.0' == compiler_v.execute(mut bin)
}
