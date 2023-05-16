// import parser
import os
import parser
import repl
import time
import table
// import token

fn main() {
	if os.args.len >= 2 {
		mut sw := time.new_stopwatch()
		command := os.args[1]
		match command {
			'repl' {
				repl.start()
			}
			'build' {
				if os.args.len == 3 {
					path := os.args[2]
					t := &table.Table{}
					p := parser.parse_file(path, t)
					println(p)
					elapsed := sw.elapsed().milliseconds()
					println('\nRead file `${path}` at ${elapsed}ms')
					println('Compiled `${path}` at ${sw.elapsed().milliseconds() - elapsed}ms')
				} else {
					println('File is need to lexer')
				}
			}
			else {
				println('Basic commands `lx build {file.ex}` or `lx repl`')
			}
		}
	} else {
		println('Basic commands `lx build {file.ex}` or `lx repl`')
	}
}
