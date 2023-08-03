module compiler_v

// import parser
import os
import time
import compiler_v.parser
import compiler_v.table
import compiler_v.gen.vlang
import compiler_v.color

pub fn compile(args []string) {
	if args.len == 3 {
		mut sw := time.new_stopwatch()
		path := os.args[2]
		prog := &table.Program{
			table: &table.Table{}
			build_folder: '_build'
			core_modules_path: ['src/libs']
		}
		parser.preprocess(path, prog)
		parser.parse_files(prog)

		mut generated := vlang.gen(prog)
		builded_file := generated.save() or {
			println(err.msg())
			exit(0)
		}
		// println(prog)
		result := os.execute_or_exit('v run ${builded_file}')
		println(result.output)
		elapsed := sw.elapsed().microseconds()
		println(color.fg(color.dark_yellow, 1, '....... development summary........'))
		println(color.fg(color.dark_yellow, 0, '. Table size: `${sizeof(generated)}b`'))
		println(color.fg(color.dark_yellow, 0, '. Compiled: `${path}` at ${sw.elapsed().microseconds() - elapsed}μs'))
		println(color.fg(color.dark_yellow, 0, '. Using: V 0.4.0'))
		println(color.fg(color.dark_yellow, 1, '..................................\n'))
	} else {
		println('File is need to lexer')
	}
}
