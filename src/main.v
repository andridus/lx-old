// import parser
import os
import lexer
import time
fn main() {
	if os.args.len >= 2 {
		mut sw := time.new_stopwatch()
		path := os.args[1]
		content := os.read_file(path) or { panic("File 'example.ex' not exists on root dir")}
		elapsed := sw.elapsed().microseconds()
		println('\nRead file `$path` at ${elapsed}µs')
		_ = lexer.new(content)
		println('Compiled `$path` at ${sw.elapsed().microseconds()-elapsed}µs')
	} else {
		println("File is need to lexer")
	}
}