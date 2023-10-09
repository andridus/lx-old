// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.ast
// import compiler_v.table
import compiler_v.types
// import compiler_v.token
// import compiler_v.docs

fn (mut p Parser) call_enum() !ast.Node {
	mut meta := p.meta()
	name := p.tok.lit
	ti := p.parse_ti_name('enum_')
	meta.put_ti(ti)
	p.check(.arrob)
	value := p.tok.lit
	p.check(.ident)
	idx, name0 := p.program.table.find_type_name(ti)
	t := p.program.table.types[idx]
	if t is types.Enum {
		if value in t.values {
			return p.node_caller_enum(mut meta, value, ast.Enum{
				internal: name0
				name: name
				values: t.values
				is_def: false
				ti: ti
			})
		} else {
			p.error_pos_out = p.tok.pos
			p.log_d('ERROR', 'The value `${value}` of enum `${t.name}` is not valid. Please use one of ${t.values}`',
				'', '', '')
			exit(1)
		}
	} else {
		p.error_pos_out = p.tok.pos
		p.log_d('ERROR', 'The enum `{fun_name.lit}` is not defined.`', '', '', '')
		exit(1)
	}
}

fn (mut p Parser) defenum_decl() ast.Node {
	mut meta := p.meta()
	is_private := p.tok.kind == .key_defenump
	if is_private {
		p.check(.key_defenump)
	} else {
		p.check(.key_defenum)
	}

	internal, name := p.check_modl_name()
	p.check(.lsbr)

	mut values := []ast.Node{}
	mut values_for_table := []string{}

	for p.tok.kind != .rsbr {
		atom := p.check_atom()
		values_for_table << atom
		values << p.node_atomic(atom)

		for p.tok.kind == .comma {
			p.check(.comma)
			atom0 := p.check_atom()
			values_for_table << atom0
			values << p.node_atomic(atom0)
		}
	}

	p.check(.rsbr)
	ti := types.new_enum(internal)
	_, name0 := p.program.table.register_enum(ti, values_for_table)
	return p.node_enum(meta, values, ast.Enum{
		internal: name0
		name: name
		values: values_for_table
		is_def: true
		is_pub: !is_private
		ti: ti
	})
}
