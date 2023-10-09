import compiler_v
import os

pub fn test_sum_ex_file() {
	file := 'struct'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'StructTest' == bin.program.modules['StructTest'].name
	assert '{{:defmodule, [line: 1], [{:__aliases__, [line: 1], [:StructTest]},[{:do,{:__block__, [line: 4], [{:defstruct, [line: 4], [{:name,:string},{:age,:integer}]},{:defstruct, [line: 10], [{:model,:string},{:year,:integer}]},{:def, [line: 14,type: SUM::atom], [{:main, [line: 14,type: SUM::atom], []},[{:do,{:__block__, [line: 15,type: atom], [{:=, [line: 15], [{:b, [line: 15], []},{:%, [line: 15], [{:__aliases__, [line: 15], [:StructTest]},{:%{}, [line: 15], [{:name,"Person 1"},{:age,15}]}]}]},{:=, [line: 16], [{:v, [line: 16], []},{:%, [line: 16], [{:__aliases__, [line: 16], [:StructTest.Vehicle]},{:%{}, [line: 16], [{:model,"FIAT"},{:year,2014}]}]}]},{:=, [line: 17,type: integer], [15,{:., [line: 17,type: integer], [{:b, [line: 17,type: integer], []},:age]}]},{:=, [line: 18,type: string], ["Person 1",{:., [line: 18,type: string], [{:b, [line: 18,type: string], []},:name]}]},{:=, [line: 19,type: string], ["FIAT",{:., [line: 19,type: string], [{:v, [line: 19,type: string], []},:model]}]},:ok]}}]]}]}}]]}}' == bin.program.modules['StructTest'].str()
	assert ':ok' == compiler_v.execute(mut bin)
}
