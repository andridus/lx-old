// import parser
import os
import lexer
import repl
import time
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
					content := os.read_file(path) or {
						panic("File '${path}' not exists on root dir")
					}
					elapsed := sw.elapsed().milliseconds()
					println('\nRead file `${path}` at ${elapsed}ms')
					mut le := lexer.new(content)
					le.generate_tokens()
					// for t in le.tokens {
					// 	if t.kind == token.Kind.line_comment {
					// 		println(t)
					// 	}
					// }
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
