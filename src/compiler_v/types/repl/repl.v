module repl

// import lexer
import readline
import compiler_v.table
import compiler_v.parser
import compiler_v.color
import compiler_v.gen
import compiler_v.ast
import net
import os
import time

const prompt = 'iex'

fn send_socket(erl chan string) string {
	return 'term'
}

fn read_line(op_ch chan int, repl_ch chan int, req_ch chan string, res_ch chan string, tbl &table.Table) {
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

fn kill_server() {
	maybe_port := os.execute('lsof -t -i:5570')
	splitted := maybe_port.output.split('\n')
	for i := 0; i < splitted.len; i++ {
		pid := splitted[i]
		if pid.len > 1 {
			spawn kill_pid(pid)
		}
	}
}

fn kill_pid(pid string) {
	os.execute('kill -9 ${pid}')
}

fn code_server(op_ch chan int, repl_ch chan int, req chan string, res chan string, tbl &table.Table) {
	// Start the server
	kill_server()
	os.execute('./compile_server.sh')
	/// waits to connect the compile server
	time.sleep(time.Duration(200 * time.millisecond))
	mut client := net.dial_tcp('localhost:5570') or {
		println('${color.fg(color.red, 0, 'Invalid connection with LX Erl Compile Server ')}')
		op_ch <- -1
		return
	}
	repl_ch <- 1
	mut buf := []u8{len: 4096}
	for {
		ast_erl := <-req
		tbl_erl := table_to_erl(tbl)
		println('${color.fg(color.blue, 0, ast_erl)}')
		println('${ast_erl}::${tbl_erl}')
		client.write_string('${ast_erl}::${tbl_erl}') or { panic(err) }
		client.read(mut buf) or { panic(err) }
		res <- buf.bytestr()
		for i := 0; i < buf.len; i++ {
			buf[i] = 0
		}
	}
}

fn table_to_erl(tbl table.Table) string {
	mut tbl_ast := '['
	for k, v in tbl.local_vars {
		f := ast.File{
			file_name: 'nofile'
			stmts: [v.expr]
		}
		mut res := gen.erl_gen(f, tbl)
		ast_erl := res.ast()
		tbl_ast += '{{var, 0, \'${k.capitalize()}\'}, ${ast_erl}}'
	}
	tbl_ast += ']'
	return tbl_ast
}

pub fn start() {
	op_ch := chan int{}
	repl_ch := chan int{}
	req_ch := chan string{}
	res_ch := chan string{}
	tbl := &table.Table{}

	spawn read_line(op_ch, repl_ch, req_ch, res_ch, tbl)
	spawn code_server(op_ch, repl_ch, req_ch, res_ch, tbl)

	println('Interactive Lx (0.1.0) - press ${color.fg(color.red, 0, 'CTRL+C to exit')} (type h() ENTER for help)')

	for {
		op := <-op_ch
		if op == -1 {
			kill_server()
			println('Gracefull exit')
			time.sleep(time.Duration(300 * time.millisecond))
			break
		}
	}
}
