// import parser
import os
import lexer
import time
fn main() {
	if os.args.len >= 2 {
		mut sw := time.new_stopwatch()
		path := os.args[1]
		content := os.read_file(path) or { panic("File 'example.ex' not exists on root dir")}
		elapsed := sw.elapsed().milliseconds()
		println('\nRead file `$path` at ${elapsed}ms')
		_ = lexer.new(content)
		println('Compiled `$path` at ${sw.elapsed().milliseconds()-elapsed}ms')
	} else {
		println("File is need to lexer")
	}
}