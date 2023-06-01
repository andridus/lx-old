module repl

// import lexer
import readline
import table
import parser
import color

// import os

const prompt = 'iex'

pub fn start() {
	mut nr_line := 0
	mut history := []string{}
	mut r := readline.Readline{
		is_raw: false
		skip_empty: true
	}
	println('Interactive Lx (0.1.0) - press ${color.fg(color.red,'CTRL+C to exit')} (type h() ENTER for help)')
	t := &table.Table{}
	for {
		nr_line++
		line := r.read_line('${repl.prompt}(${nr_line})> ') or { break }
		history << line
		p := parser.parse_stmt(line, t)
		println(p)
	}
}
