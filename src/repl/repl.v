module repl

import lexer
import readline

const prompt = 'iex'

pub fn start() {
	mut nr_line := 0
	mut history := []string{}
	mut r := readline.Readline{
		is_raw: false
		skip_empty: true
	}
	println('lx REPL type CTRL+C to Exit')

	for {
		nr_line++
		line := r.read_line('${repl.prompt}(${nr_line})> ') or { break }
		history << line
		mut l := lexer.new(line)
		l.generate_tokens()
		println(l.tokens)
	}
}
