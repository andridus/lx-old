// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.lexer
import compiler_v.color

pub fn (mut p Parser) log(type_error string, message string, s string) {
	p.log_d(type_error, message, '', '', s)
}

pub fn (mut p Parser) log_d(type_error string, message string, description string, url string, s string) {
	p.error_pos_in, p.error_pos_out = p.lexer.get_in_out(p.error_pos_in, p.error_pos_out,
		s)
	match type_error {
		'ERROR' {
			p.error_d(message, description, url)
		}
		'WARN' {
			p.warn_d(message, description, url)
		}
		else {
			panic(message)
		}
	}
}

pub fn (p &Parser) error(s string) {
	p.error_d(s, '', '')
}

pub fn (p &Parser) error_d(s string, desc string, url string) {
	// print_backtrace()
	mut description := ''
	if desc.len > 0 {
		description += desc
	}
	if url.len > 0 {
		description += '\nView more: ${url}\n'
	}
	eprintln(color.fg(color.red, 0, 'ERROR1: ${p.file_name}[${p.error_line},${p.error_pos_in}]:\n${s}'))
	eprint(color.fg(color.dark_gray, 3, description))
	eprintln(p.lexer.get_code_between_line_breaks(color.red, p.tok.pos, p.error_pos_in,
		p.error_pos_out, 1, p.error_line))
	exit(1)
}

pub fn (p &Parser) error_at_line(s string, line_nr int) {
	num := p.tok.lit.len + 2
	eprintln(color.fg(color.red, 0, 'ERROR: ${p.file_name}:${line_nr}: ${s}'))
	eprintln(p.lexer.get_code_between_line_breaks(color.red, p.tok.pos, p.tok.pos_inline - num,
		p.tok.pos_inline, 1, p.error_line))
	exit(1)
}

pub fn (p &Parser) warn(s string) {
	p.warn_d(s, '', '')
}

pub fn (p &Parser) warn_d(s string, desc string, url string) {
	line := p.error_line
	pos_global := p.error_pos_inline
	pos_in := p.error_pos_in
	pos_out := p.error_pos_out
	mut description := ''
	if desc.len > 0 {
		description += desc
	}
	if url.len > 0 {
		description += '\nView more: ${url}\n'
	}
	println('${color.fg(color.dark_yellow, 0, 'WARN:')} ${p.file_name}[${line},${pos_in}]:\n${s}')
	print(color.fg(color.dark_gray, 3, description))
	println(p.lexer.get_code_between_line_breaks(color.red, pos_global, pos_in, pos_out,
		1, line))
}
