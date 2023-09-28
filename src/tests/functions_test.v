import compiler_v
import os

pub fn test_functions_ex_file() {
	file := 'functions'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate Functions Module
	assert 'Functions' == bin.program.modules['Functions'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:IO]},[{:do,{:__block__, [line: 2], [{:def, [line: 2,type: SUM::atom], [{:puts, [line: 2,type: SUM::atom], [{str, [line: 6,type: string], []}]},[{:do,{:__block__, [line: 3,type: atom], [{{:., [line: 3], [{:__aliases__, [line: 3], [:FFI.v]},:println]}, [line: 3], [{str, [line: 3,type: string], []}]},:ok]}}]]},{:def, [line: 6,type: SUM::atom], [{:puts, [line: 6,type: SUM::atom], [{integer, [line: 11,type: integer], []}]},[{:do,{:__block__, [line: 7,type: atom], [{{:., [line: 7], [{:__aliases__, [line: 7], [:FFI.v]},:println]}, [line: 7], [{integer, [line: 7,type: integer], []}]},:ok]}}]]}]}}]]},{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:Functions]},[{:do,{:__block__, [line: 2], [{:def, [line: 2,type: SUM::integer], [{:sum, [line: 2,type: SUM::integer], [{a, [line: 5,type: integer], []},{b, [line: 5,type: integer], []}]},[{:do,{:+, [line: 3,type: integer], [{a, [line: 3,type: integer], []},{b, [line: 4,type: integer], []}]}}]]},{:def, [line: 5,type: SUM::atom], [{:main, [line: 5,type: SUM::atom], []},[{:do,{:__block__, [line: 6,type: atom], [{:=, [line: 6,type: integer], [{a, [line: 6,type: integer], []},{{:., [line: 6,type: integer], [{:__aliases__, [line: 6,type: integer], [:Functions]},:sum]}, [line: 6,type: integer], [5,2]}]},{{:., [line: 7,type: atom], [{:__aliases__, [line: 7,type: atom], [:IO]},:puts]}, [line: 7,type: atom], ["Hello Lx World\\n"]},{{:., [line: 8,type: atom], [{:__aliases__, [line: 8,type: atom], [:IO]},:puts]}, [line: 8,type: atom], [{a, [line: 8,type: integer], []}]},:ok]}}]]}]}}]]}}' == bin.program.modules['Functions'].str()
	assert 'Hello Lx World\n\n7\n:ok' == compiler_v.execute(mut bin)
}
