import compiler_v
import os
// NOTE: FFI.v could not be used as a value.

pub fn test_builtin_functions_ex_file() {
	file := 'builtin_functions'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'HelloWorld' == bin.program.modules['HelloWorld'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:Lx.IO]},[{:do,{:__block__, [line: 3], [{:def, [line: 3,type: SUM::atom], [{:puts, [line: 3,type: SUM::atom], [{a, [line: 7,type: integer], []}]},[{:do,{:__block__, [line: 3,type: atom], [{{:., [line: 4], [{:__aliases__, [line: 4], [:FFI.v]},:println]}, [line: 4], [{a, [line: 4,type: integer], []}]},:ok]}}]]},{:def, [line: 7,type: SUM::atom], [{:puts, [line: 7,type: SUM::atom], [{a, [line: 11,type: float], []}]},[{:do,{:__block__, [line: 7,type: atom], [{{:., [line: 8], [{:__aliases__, [line: 8], [:FFI.v]},:println]}, [line: 8], [{a, [line: 8,type: float], []}]},:ok]}}]]},{:def, [line: 11,type: SUM::atom], [{:puts, [line: 11,type: SUM::atom], [{a, [line: 15,type: string], []}]},[{:do,{:__block__, [line: 11,type: atom], [{{:., [line: 12], [{:__aliases__, [line: 12], [:FFI.v]},:println]}, [line: 12], [{a, [line: 12,type: string], []}]},:ok]}}]]}]}}]]},{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:HelloWorld]},[{:do,{:def, [line: 2,type: SUM::atom], [{:main, [line: 2,type: SUM::atom], []},[{:do,{{:., [line: 3,type: atom], [{:__aliases__, [line: 3,type: atom], [:Lx.IO]},:puts]}, [line: 3,type: atom], ["Using builtin functions\\n"]}}]]}}]]}}' == bin.program.modules['HelloWorld'].str()
	assert 'Using builtin functions\n\n:ok' == compiler_v.execute(mut bin)
}
