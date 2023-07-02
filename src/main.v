// import parser
import os
import parser
// import repl
import time
import table
import gen.c
import color
// import token

fn main() {
	if os.args.len >= 2 {
		mut sw := time.new_stopwatch()
		command := os.args[1]
		match command {
			// 'repl' {
			// 	repl.start()
			// }
			// '-js' {
			// 	if os.args.len == 3 {
			// 		path := os.args[2]
			// 		t := &table.Table{}
			// 		p := parser.parse_file(path, t)
			// 		elapsed := sw.elapsed().milliseconds()
			// 		res := gen.js_gen(p, t)
			// 		os.write_file('${path}.js', res) or { println(err.msg()) }
			// 		println('Compiled `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms')
			// 	} else {
			// 		println('File is need to lexer')
			// 	}
			// }
			// '-erl' {
			// 	if os.args.len == 3 {
			// 		path := os.args[2]
			// 		t := &table.Table{}
			// 		p := parser.parse_file(path, t)
			// 		elapsed := sw.elapsed().milliseconds()
			// 		mut generated := gen.erl_gen(p, t)
			// 		generated.save()
			// 		println('Compiled `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms')
			// 	} else {
			// 		println('File is need to lexer')
			// 	}
			// }
			'-c' {
				if os.args.len == 3 {
					path := os.args[2]
					prog := &table.Program{
						table: &table.Table{}
						build_folder: '_build'
					}
					parser.preprocess(path, prog)
					parser.parse_files(prog)

					mut generated := c.gen(prog)
					builded_file := generated.save() or {
						 println(err.msg())
						 exit(0)
					}
					cmd := 'gcc $builded_file -o ${prog.build_folder}/main'
					os.execute(cmd)
					elapsed := sw.elapsed().milliseconds()
					println(color.fg(color.dark_gray, 1, '....... development summary........'))
					println(color.fg(color.dark_gray, 0, '. Table size: `${sizeof(generated)}b`'))
					println(color.fg(color.dark_gray, 0, '. Compiled: `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms'))
					println(color.fg(color.dark_gray, 1, '..................................\n'))
					os.execvp('${prog.build_folder}/main', []) or {
						println(color.fg(color.red, 1, 'ERROR: $err.msg()'))
					}
					// println(generated)
					// for file in order {
					// 	// Generate for every file
					// 	parser.parse_file(file, prog)
					// }
					// mut generated := gen.c_gen(prog)
					// p := parser.parse_file(path, prog)
					// mut generated := gen.c_gen(p, prog)
					// generated.save()

				} else {
					println('File is need to lexer')
				}
			}
			// 'build' {
			// 	if os.args.len == 3 {
			// 		path := os.args[2]
			// 		t := &table.Table{}
			// 		parser.parse_file(path, t)
			// 		elapsed := sw.elapsed().milliseconds()
			// 		println('\nRead file `${path}` at ${elapsed}ms')
			// 		println('Compiled `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms')
			// 	} else {
			// 		println('File is need to lexer')
			// 	}
			// }
			else {
				println('Basic commands `lx build [file.ex]` or `lx repl`')
			}
		}
	} else {
		println('Basic commands `lx build [file.ex]` or `lx repl`')
	}
}
