module parser

import os
import compiler_v.lexer
import compiler_v.token

pub fn filename_without_extension(filename string) string {
	return filename[0..filename.len - os.file_ext(filename).len]
}

fn (mut p Parser) check_modl_name() string {
	mut name := ''
	if p.tok.kind == .modl {
		name = p.tok.lit
		p.check(.modl)
	}
	if p.tok.kind == .lsbr {
		if name != '' {
			name = '${p.current_module}.${name}'
		} else {
			name = p.current_module
		}
	}
	return name.replace('.', '_').to_lower()
}

fn (mut p Parser) get_mdl_name() string {
	if p.tok.kind == .modl {
		mut module_toks := [p.tok.lit]
		p.check(.modl)
		for p.tok.kind == .dot {
			p.check(.dot)
			if p.tok.kind == .modl {
				module_toks << p.tok.lit
			}
		}
		return module_toks.join('.').replace('.', '_')
	} else {
		return ''
	}
}

fn (mut p Parser) check_name_or_mdl() string {
	mut name := ''
	if p.tok.kind == .ident {
		name = p.tok.lit
		p.check(.ident)
	} else if p.tok.kind == .modl {
		// module_name := module_name0([])
		p.check(.ident)
	}

	return name
}

fn (mut p Parser) check_name() string {
	name := p.tok.lit
	if p.tok.kind == .key_nil {
		p.check(.key_nil)
	} else if p.tok.kind == .ident {
		p.check(.ident)
	}
	return name
}

fn (mut p Parser) check_atom() string {
	name := p.tok.lit
	p.check(.atom)
	return name
}

fn (mut p Parser) check(expected token.Kind) {
	if p.tok.kind != expected {
		s := 'syntax error: unexpected `${p.tok.kind.str()}` , expecting `${expected.str()}`'
		p.error(s)
	}
	p.next_token()
}

pub fn (mut p Parser) read_first_token() {
	p.next_token()
	p.next_token()
}

fn (mut p Parser) next_token() {
	p.tok = p.peek_tok
	p.peek_tok = p.lexer.generate_one_token()
	if p.tok.kind in [.newline, .line_comment, .moduledoc, .doc] {
		p.next_token()
	}
}

fn (mut p Parser) peek_next_token(num int) token.Token {
	mut num0 := num
	pos := p.lexer.pos
	lines := p.lexer.lines
	pos_inline := p.lexer.pos_inline
	mut peek_tok := p.lexer.generate_one_token()
	for num0 - 1 > 0 {
		peek_tok = p.lexer.generate_one_token()
		for peek_tok.kind in [.newline, .line_comment, .moduledoc, .doc] {
			peek_tok = p.lexer.generate_one_token()
		}
		num0--
	}

	p.lexer.pos = pos
	p.lexer.lines = lines
	p.lexer.pos_inline = pos_inline
	return peek_tok
}
