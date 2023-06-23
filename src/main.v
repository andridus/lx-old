// import parser
import os
import parser
import repl
import time
import table
import gen
// import token

fn main() {
	if os.args.len >= 2 {
		mut sw := time.new_stopwatch()
		command := os.args[1]
		match command {
			'repl' {
				repl.start()
			}
			'-js' {
				if os.args.len == 3 {
					path := os.args[2]
					t := &table.Table{}
					p := parser.parse_file(path, t)

					elapsed := sw.elapsed().milliseconds()
					res := gen.js_gen(p, t)
					os.write_file('${path}.js', res) or { println(err.msg()) }
					println('Compiled `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms')
				} else {
					println('File is need to lexer')
				}
			}
			'-erl' {
				if os.args.len == 3 {
					path := os.args[2]
					t := &table.Table{}
					p := parser.parse_file(path, t)
					elapsed := sw.elapsed().milliseconds()
					mut generated := gen.erl_gen(p, t)
					generated.save()
					println('Compiled `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms')
				} else {
					println('File is need to lexer')
				}
			}
			'-c' {
				if os.args.len == 3 {
					path := os.args[2]
					t := &table.Table{}
					if os.is_dir(path) {
						files := os.ls('${path}') or { []string{} }
						for file in files {
							parser.parse_modules('${path}/${file}', t)
						}
						order := parser.compile_order(t)
						for file in order {
							// Generate for every file	
							p := parser.parse_file(file, t)
							mut generated := gen.c_gen(p, t)
							generated.save()
						}
					} else {
						p := parser.parse_file(path, t)
						mut generated := gen.c_gen(p, t)
						generated.save()
					}
					elapsed := sw.elapsed().milliseconds()
					println('Compiled `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms')
				} else {
					println('File is need to lexer')
				}
			}
			'build' {
				if os.args.len == 3 {
					path := os.args[2]
					t := &table.Table{}

					parser.parse_file(path, t)
					elapsed := sw.elapsed().milliseconds()
					println('\nRead file `${path}` at ${elapsed}ms')
					println('Compiled `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms')
				} else {
					println('File is need to lexer')
				}
			}
			else {
				println('Basic commands `lx build [file.ex]` or `lx repl`')
			}
		}
	} else {
		println('Basic commands `lx build [file.ex]` or `lx repl`')
	}
}
