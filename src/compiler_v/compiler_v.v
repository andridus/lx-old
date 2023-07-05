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
		cmd := 'gcc ${builded_file} -o ${prog.build_folder}/main'
		os.execute(cmd)
		elapsed := sw.elapsed().milliseconds()
		println(color.fg(color.dark_gray, 1, '....... development summary........'))
		println(color.fg(color.dark_gray, 0, '. Table size: `${sizeof(generated)}b`'))
		println(color.fg(color.dark_gray, 0, '. Compiled: `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms'))
		println(color.fg(color.dark_gray, 1, '..................................\n'))
		os.execvp('${prog.build_folder}/main', []) or {
			println(color.fg(color.red, 1, 'ERROR: ${err.msg()}'))
		}
	} else {
		println('File is need to lexer')
	}
}
