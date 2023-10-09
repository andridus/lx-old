import compiler_v
import os

pub fn test_type_inference_ex_file() {
	file := 'type_inference'
	root := os.abs_path('')
	path := '${root}/src/tests/${file}'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'TypeInferenceTest' == bin.program.modules['TypeInferenceTest'].name
	assert '{{:defmodule, [line: 3], [{:__aliases__, [line: 3], [:TypeInferenceTest]},[{:do,{:__block__, [line: 4], [{:def, [line: 4,type: SUM::integer], [{:sum, [line: 4,type: SUM::integer], [{:a, [line: 8,type: integer], []},{:b, [line: 8,type: integer], []}]},[{:do,{:+, [line: 5,type: integer], [{:a, [line: 5,type: integer], []},{:b, [line: 6,type: integer], []}]}}]]},{:def, [line: 8,type: SUM::integer], [{:main, [line: 8,type: SUM::integer], []},[{:do,{{:., [line: 9,type: integer], [{:__aliases__, [line: 9,type: integer], [:TypeInferenceTest]},:sum]}, [line: 9,type: integer], [1,2]}}]]}]}}]]}}' == bin.program.modules['TypeInferenceTest'].str()
	assert '3' == compiler_v.execute(mut bin)
}
