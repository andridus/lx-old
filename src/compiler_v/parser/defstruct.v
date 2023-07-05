// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.ast
// import compiler_v.table
import compiler_v.types
// import compiler_v.token
// import compiler_v.docs

fn (mut p Parser) defstruct_init() (ast.StructInit, types.TypeIdent) {
	p.check(.mod)
	mut module_toks := [p.tok.lit]
	p.check(.modl)
	for p.tok.kind == .dot {
		p.check(.dot)
		if p.tok.kind == .modl {
			module_toks << p.tok.lit
		} else {
			p.error_pos_inline = p.lexer.pos_inline
			p.error('The token `${p.tok.str()}` is not a Module. \n Module starts with a capital letter.')
			exit(0)
		}
		p.next_token()
	}
	module_name := module_toks.join('.')
	ti := types.new_struct(module_name)
	mut fields := []string{}
	mut exprs := []ast.Expr{}
	p.check(.lcbr)
	// mut field_names := map[string]ast.Expr{}
	for p.tok.kind == .key_keyword {
		fields << p.tok.lit
		p.check(.key_keyword)
		node0, _ := p.expr(0)
		exprs << node0
		if p.tok.kind == .comma {
			p.check(.comma)
		} else {
			break
		}
	}
	p.check(.rcbr)
	return ast.StructInit{
		// name: name
		exprs: exprs
		fields: fields
		ti: ti
		// size:
	}, ti
}

fn (mut p Parser) defstruct_decl() ast.StructDecl {
	// pos_in := p.tok.pos
	// mut pos_out := p.tok.pos
	is_priv := p.tok.kind == .key_defstructp
	if is_priv {
		p.check(.key_defstructp)
	} else {
		p.check(.key_defstruct)
	}

	name := p.check_struct_name()
	p.check(.lsbr)

	// GET Fields
	mut fields := []ast.Field{}

	for p.tok.kind != .rsbr {
		mut field_names := [p.check_name()]
		for p.tok.kind == .comma {
			p.check(.comma)
			field_names << p.check_name()
		}
		// parse type of Field
		mut ti := types.void_ti
		if p.tok.kind == .typedef {
			p.next_token()
			ti = p.parse_ti()
		}

		for field_name in field_names {
			field := ast.Field{
				name: field_name
				ti: ti
			}
			fields << field
		}
		if p.tok.kind != .rsbr {
			p.check(.comma)
		}
	}

	p.check(.rsbr)
	ti := types.new_struct(name)
	return ast.StructDecl{
		name: name
		fields: fields
		ti: ti
		// size:
		is_pub: !is_priv
	}
}

fn (mut p Parser) check_struct_name() string {
	mut name := ''
	if p.tok.kind == .modl {
		name = p.tok.lit
		p.check(.modl)
	}
	if p.tok.kind == .lsbr {
		name = p.current_module
	}
	return name
}
