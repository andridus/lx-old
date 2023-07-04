// import parser
import os
import compiler_v
// import repl
// import token

fn main() {
	if os.args.len >= 2 {
		command := os.args[1]
		match command {
			'-c' {
				compiler_v.compile(os.args)
			}
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
			else {
				println('Basic commands `lx [file.ex]` or `lx .`(to current folder) or `lx repl`')
			}
		}
	} else {
		println('Basic commands `lx [file.ex]` or `lx .`(to current folder) or `lx repl`')
	}
}
