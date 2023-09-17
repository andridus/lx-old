module compiler_v

// import parser
import os
import time
import compiler_v.parser
import compiler_v.table
import compiler_v.gen.vlang
import compiler_v.color

pub fn execute(mut gen vlang.VGen) string {
	builded_file := gen.save() or {
		println(err.msg())
		exit(0)
	}
	root := os.abs_path('')
	result := os.execute_or_exit('v run ${builded_file}')
	os.rm('${root}/${builded_file}') or { println("can't remove temp file") }

	return result.output
}

pub fn generate(path string) vlang.VGen {
	prog := &table.Program{
		table: &table.Table{}
		build_folder: '_build'
		core_modules_path: ['src/libs']
	}
	parser.preprocess(path, prog)
	parser.parse_files(prog)

	return vlang.gen(prog)
}

pub fn compile(args []string) {
	println(args)
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
