module repl

// import lexer
import readline
import table
import parser
import color
import gen
import ast
import net

// import os

const prompt = 'iex'

fn send_socket(erl chan string) string {
	return 'term'
}

fn read_line(op_ch chan int, repl_ch chan int, req_ch chan string, res_ch chan string, tbl table.Table) {
	mut reader := readline.Readline{
		is_raw: false
		skip_empty: true
	}
	for {
		ln := <-repl_ch
		// read line from repl
		r := reader.read_line('${repl.prompt}(${ln})> ') or {
			println(err.msg())
			'quit\n'
		}
		// type quit to exit repl
		if r == 'quit\n' {
			op_ch <- -1
			return
		}

		// parse code
		p := parser.parse_stmt(r, tbl)
		f := ast.File{
			file_name: 'nofile'
			stmts: [p]
		}
		mut res := gen.erl_gen(f, tbl)
		ast_erl := res.ast()
		// send to request eval from compile_server
		req_ch <- ast_erl
		// wait for result
		result := <-res_ch
		print('${result}')
		spawn add_new_line(repl_ch, ln)
	}
}

fn add_new_line(repl_ch chan int, ln int) {
	repl_ch <- (ln + 1)
}

fn code_server(op_ch chan int, req chan string, res chan string) {
	/// connect the compile server
	mut client := net.dial_tcp('localhost:5570') or {
		println('${color.fg(color.red, 'Invalid connection with LX Erl Compile Server ')}')
		op_ch <- -1
		return
	}
	mut buf := []u8{len: 4096}
	for {
		ast_erl := <-req
		client.write_string(ast_erl) or { panic(err) }
		client.read(mut buf) or { panic(err) }
		res <- buf.bytestr()
	}
}

pub fn start() {
	op_ch := chan int{}
	repl_ch := chan int{}
	req_ch := chan string{}
	res_ch := chan string{}
	tbl := &table.Table{}

	spawn code_server(op_ch, req_ch, res_ch)
	spawn read_line(op_ch, repl_ch, req_ch, res_ch, tbl)

	println('Interactive Lx (0.1.0) - press ${color.fg(color.red, 'CTRL+C to exit')} (type h() ENTER for help)')
	repl_ch <- 1
	for {
		op := <-op_ch
		if op == -1 {
			break
		}
	}
	println('exit')
}
