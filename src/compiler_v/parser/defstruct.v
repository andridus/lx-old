// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.table
import compiler_v.ast
import compiler_v.types
// import compiler_v.token
// import compiler_v.docs

fn (mut p Parser) defstruct_init() ast.Node {
	mut meta := p.meta()
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
			exit(1)
		}
		p.next_token()
	}
	module_name0 := module_toks.join('.')
	module_name := module_name0.replace('.', '_').to_lower()
	ti := types.new_struct(module_name)
	// mut fields := []string{}
	mut exprs := map[string]ast.Node{}
	p.check(.lcbr)
	// mut field_names := map[string]ast.Expr{}
	for p.tok.kind == .key_keyword {
		field_name := p.tok.lit
		p.check(.key_keyword)
		node0 := p.expr_node(0)
		exprs[field_name] = node0
		if p.tok.kind == .comma {
			p.check(.comma)
		} else {
			break
		}
	}
	p.check(.rcbr)
	idx, name0 := p.program.table.find_type_name(ti)
	if p.program.table.types[idx] is types.Struct {
		stct := p.program.table.types[idx] as types.Struct
		// TODO: improve the struct caller
		mut fields := map[string]ast.Node{}
		for field in stct.fields {
			meta0 := p.meta_w_ti(field.ti)
			fields[field.name] = p.node_struct_field(meta0, field.name)
		}
		return p.node_caller_struct(meta, ast.Struct{
			internal: name0
			name: module_name0
			exprs: exprs
			fields: fields
			ti: ti
		})
	} else {
		println('Struct not found')
		panic(1)
	}
}

fn (mut p Parser) defstruct_decl() ast.Node {
	mut meta := p.meta()

	is_private := p.tok.kind == .key_defstructp
	if is_private {
		p.check(.key_defstructp)
	} else {
		p.check(.key_defstruct)
	}

	internal, name := p.check_modl_name()
	p.check(.lsbr)

	// GET Fields
	mut fields := map[string]ast.Node{}

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
			meta0 := p.meta_w_ti(ti)
			field0 := p.node_struct_field(meta0, field_name)
			fields[field_name] = field0
		}
		if p.tok.kind != .rsbr {
			p.check(.comma)
		}
	}

	p.check(.rsbr)
	ti := types.new_struct(internal)
	_, name0 := p.program.table.register_struct(ti, fields)
	return p.node_struct(meta, ast.Struct{
		internal: name0
		name: name
		fields: fields
		is_def: true
		ti: ti
		is_pub: !is_private
	})
}
