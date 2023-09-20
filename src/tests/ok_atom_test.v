import compiler_v
import os

pub fn test_ok_atom_ex_file() {
	file := 'ok_atom'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'OkAtom' == bin.program.modules['OkAtom'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:OkAtom]},[{:do,{:def, [line: 2,type: SUM::atom_], [{:main, [line: 2,type: SUM::atom_], []},[{:do,:ok}]]}}]]}}' == bin.program.modules['OkAtom'].str()
	assert ':ok' == compiler_v.execute(mut bin)
	// assert 1 == 2
}
