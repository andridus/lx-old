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
			'build-js' {
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
			'build-erl' {
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
