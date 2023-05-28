// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import ast
import table
import types

pub fn (mut p Parser) call_expr() ast.ExprStmt {
	mut args := ast.CallExpr{}
	mut return_ti := types.void_ti
	if p.tok.kind == .modl {
		args, return_ti = p.call_from_module()
	}
	return ast.ExprStmt{
		expr: args
		ti: return_ti
	}
}

fn (mut p Parser) call_from_module() (ast.CallExpr, types.TypeIdent) {
	mut tok := p.tok
	mut module_path := []string{}
	mut fn_name := ''
	module_path << p.tok.lit
	p.check(.modl)

	for p.tok.kind != .lpar {
		if p.tok.kind == .modl {
			module_path << p.tok.lit
		}
		if p.tok.kind == .atom {
			tok = p.tok
			fn_name = p.check_name()
		}
		p.next_token()
	}
	p.check(.lpar)
	if fn_name == '' {
		p.error('Error no nome da funcao')
	}
	mut is_unknown := false
	mut args := []ast.Expr{}
	mut return_ti := types.void_ti
	if f := p.table.find_fn(fn_name) {
		return_ti = f.return_ti
		for i, arg in f.args {
			e, ti := p.expr(0)
			if !types.check(&arg.ti, &ti) {
				p.error('cannot use type `${ti.name}` as type `${arg.ti.name}` in argument to `${fn_name}`')
			}
			args << e
			if i < f.args.len - 1 {
				p.check(.comma)
			}
		}
		if p.tok.kind == .comma {
			p.error('too many arguments in call to `${fn_name}`')
		}
	} else {
		is_unknown = true
		p.warn('unknown function `${fn_name}`')
		for p.tok.kind != .rpar {
			e, _ := p.expr(0)
			args << e
			if p.tok.kind != .rpar {
				p.check(.comma)
			}
		}
	}
	p.check(.rpar)
	node := ast.CallExpr{
		name: fn_name
		args: args
		is_unknown: is_unknown
		tok: tok
		// typ: return_ti
	}
	if is_unknown {
		p.table.unknown_calls << node
	}
	return node, return_ti
}

pub fn (mut p Parser) call_args() []ast.Expr {
	mut args := []ast.Expr{}
	for p.tok.kind != .rpar {
		e, _ := p.expr(0)
		args << e
		if p.tok.kind != .rpar {
			p.check(.comma)
		}
	}
	p.check(.rpar)
	return args // ,types.void_ti
}

fn (mut p Parser) def_decl() ast.FnDecl {
	is_priv := p.tok.kind == .key_defp
	mut rec_name := ''
	// mut is_method := false
	mut rec_ti := types.void_ti
	p.table.clear_vars()
	if is_priv {
		p.check(.key_defp)
	} else {
		p.check(.key_def)
	}
	// ### if is a method

	// if p.tok.kind == .lpar {
	// 	is_method = true
	// 	p.next_token()
	// 	rec_name = p.check_name()
	// 	if p.tok.kind == .key_mut {
	// 		p.next_token()
	// 	}
	// 	rec_ti = p.parse_ti()
	// 	p.table.register_var(table.Var{
	// 		name: rec_name
	// 		ti: rec_ti
	// 	})
	// 	p.check(.rpar)
	// }

	name := p.check_name()
	p.check(.lpar)

	// GET Args
	mut args := []table.Var{}
	mut ast_args := []ast.Arg{}
	for p.tok.kind != .rpar {
		mut arg_names := [p.check_name()]
		for p.tok.kind == .comma {
			p.check(.comma)
			arg_names << p.check_name()
		}
		// parse type of ARG
		mut ti := types.void_ti
		if p.tok.kind == .colon_space {
			p.next_token()
			ti = p.parse_ti()
		}

		for arg_name in arg_names {
			arg := table.Var{
				name: arg_name
				ti: ti
			}
			args << arg
			p.table.register_var(arg)
			ast_args << ast.Arg{
				ti: ti
				name: arg_name
			}
			// if ti.kind == .variadic && p.tok.kind == .comma {
			// 	p.error('cannot use ...(variadic) with non-final parameter $arg_name')
			// }
		}
		if p.tok.kind != .rpar {
			p.check(.comma)
		}
	}
	p.check(.rpar)
	// Return type
	mut ti := types.void_ti
	if p.tok.kind == .typedef {
		p.check(.typedef)
		ti = p.parse_ti()
		p.return_ti = ti
	}

	// if is_method {
	// 	ok := p.table.register_method(rec_ti, table.Fn{
	// 		name: name
	// 		args: args
	// 		return_ti: ti
	// 	})
	// 	if !ok {
	// 		p.error('expected Struct')
	// 	}
	// }
	// else {
	p.table.register_fn(table.Fn{
		name: name
		args: args
		return_ti: ti
	})
	// }
	stmts := p.parse_block()
	return ast.FnDecl{
		name: name
		stmts: stmts
		ti: ti
		args: ast_args
		is_priv: is_priv
		receiver: ast.Field{
			name: rec_name
			ti: rec_ti
		}
	}
}

pub fn (p &Parser) check_fn_calls() {
	println('check fn calls2')
	for call in p.table.unknown_calls {
		f := p.table.find_fn(call.name) or {
			p.error_at_line('unknown function `${call.name}`', call.tok.line_nr)
			return
		}
		println(f.name)
		// println(f.return_ti.name)
		// println('IN AST typ=' + call.typ.name)
	}
}
