// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import os
import compiler_v.ast
import compiler_v.lexer
import compiler_v.token
import compiler_v.types

pub fn filename_without_extension(filename string) string {
	return filename[0..filename.len - os.file_ext(filename).len]
}

fn (mut p Parser) check_modl_name() (string, string) {
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
	return name.replace('.', '_').to_lower(), name
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

fn (mut p Parser) maybe_update_two_nodes_with_ti(left ast.Node, right ast.Node, ti types.TypeIdent) (ast.Node, ast.Node) {
	mut left0 := left
	mut right0 := right
	if left.meta.ti.kind == .void_ && right.meta.ti.kind == .void_ {
		left0.meta.put_ti(ti)
		right0.meta.put_ti(ti)
	} else if left.meta.ti.kind == .void_ {
		left0.meta.put_ti(right.meta.ti)
	} else if right.meta.ti.kind == .void_ {
		right0.meta.put_ti(left.meta.ti)
	}

	if left0.kind is ast.Ast {
		k := left0.kind as ast.Ast
		if k.lit == 'var' {
			name0 := left0.left.atomic_str()
			// if the var, locate and update the TypeIdent if is nil
			if v0 := p.program.table.find_var(name0, p.context) {
				p.program.table.update_var_ti(v0, left0.meta.ti)
			}
		}
	}

	if right0.kind is ast.Ast {
		k := right0.kind as ast.Ast
		if k.lit == 'var' {
			name0 := right0.left.atomic_str()
			// if the var, locate and update the TypeIdent if is nil
			if v0 := p.program.table.find_var(name0, p.context) {
				p.program.table.update_var_ti(v0, right0.meta.ti)
			}
		}
	}
	return left0, right0
}

fn (mut p Parser) maybe_update_var_node_with_ti(node ast.Node, ti types.TypeIdent) ast.Node {
	mut node0 := node
	if node.meta.ti.kind == .void_ {
		node0.meta.put_ti(ti)
	}
	if node0.kind is ast.Ast {
		k := node0.kind as ast.Ast
		if k.lit == 'var' {
			name0 := node0.left.atomic_str()
			// if the var, locate and update the TypeIdent if is nil
			if v0 := p.program.table.find_var(name0, p.context) {
				p.program.table.update_var_ti(v0, node0.meta.ti)
			}
		}
	}
	return node0
}
