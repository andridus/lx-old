module compiler_v

// import parser
import os
import time
import compiler_v.parser
import compiler_v.table
import compiler_v.gen.c
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

		mut generated := c.gen(prog)

		builded_file := generated.save() or {
			println(err.msg())
			exit(0)
		}
		elapsed := sw.elapsed().microseconds()
		println(color.fg(color.dark_gray, 1, '....... development summary........'))
		println(color.fg(color.dark_gray, 0, '. Table size: `${sizeof(generated)}b`'))
		println(color.fg(color.dark_gray, 0, '. Compiled: `${path}` at ${sw.elapsed().microseconds() - elapsed}μs'))
		println(color.fg(color.dark_gray, 0, '. Using: TCC (https://bellard.org/tcc) Compiler'))
		println(color.fg(color.dark_gray, 1, '..................................\n'))
		println(color.fg(color.dark_gray, 4, 'Program Execution:\n'))
		os.execvp('tcc', ['-bench', '-run', builded_file]) or {
			println(color.fg(color.red, 1, 'ERROR: ${err.msg()}'))
		}
	} else {
		println('File is need to lexer')
	}
}
