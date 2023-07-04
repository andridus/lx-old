// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.ast
import compiler_v.table
import compiler_v.types
import compiler_v.token
import compiler_v.docs

pub fn (mut p Parser) call_expr() !ast.ExprStmt {
	mut args := ast.CallExpr{}
	mut return_ti := types.void_ti
	if p.tok.kind == .modl {
		args, return_ti = p.call_from_module(.modl)!
	}

	return ast.ExprStmt{
		expr: args
		ti: return_ti
	}
}

pub fn (mut p Parser) call_from_module(kind token.Kind) !(ast.CallExpr, types.TypeIdent) {
	mut is_external := true
	mut is_local := false
	mut tok := p.tok
	mut fun_name := token.Token{}
	mut module_ref := [p.tok]
	mut is_unknown := false
	mut args := []ast.Expr{}
	mut return_ti := types.void_ti
	mut is_c_module := false
	if p.tok.lit == '_c_' {
		is_c_module = true
		module_ref = []
	}
	p.error_pos_in = p.tok.pos - p.tok.lit.len

	mut more := 0
	if kind == .ident {
		if p.peek_tok.kind == .dot {
			// should be a var, check
			p.error_pos_out = p.tok.pos
			p.log_d('ERROR', '`${p.tok.lit}` is not a var', '', '', p.tok.lit)
			exit(0)
		} else {
			fun_name = p.tok
			is_local = true
		}
	}
	p.check(kind)
	for p.tok.kind == .dot {
		p.check(.dot)
		if p.tok.kind == .ident {
			if more > 0 {
				module_ref << fun_name
				more = 0
			}
			fun_name = p.tok
			more++
		} else if p.tok.kind == .modl {
			module_ref << p.tok
		} else {
			p.error_pos_inline = p.lexer.pos_inline
			p.error('The token `${p.tok.str()}` is not a Module. \n Module starts with a capital letter.')
			exit(0)
		}
		p.next_token()
	}

	mut module_name := module_name0(module_ref)
	if is_local {
		module_name = p.current_module
	}

	aliased_name := p.program.modules[p.current_module].aliases[module_name]
	if aliased_name.len > 0 {
		module_name = aliased_name
	}
	module_path := module_name.to_lower()
	if fun_name.kind == .ignore {
		p.warn('Module ${module_name} is orphan')
	}
	// p.check(.modl)

	// for p.tok.kind != .lpar {
	// 	if p.tok.kind == .modl {
	// 		module_path << p.tok.lit
	// 	}
	// 	println(p.tok.kind)
	// 	if p.tok.kind == .ident {
	// 		tok = p.tok
	// 		fn_name = p.check_name()
	// 	}
	// 	p.next_token()
	// }

	p.check(.lpar)
	if f := p.program.table.find_fn(fun_name.lit, module_name) {
		return_ti = f.return_ti

		for i, arg in f.args {
			e, ti := p.expr(0)
			if !types.check(&arg.ti, &ti) {
				p.error_pos_out = p.tok.pos
				mut name0 := '`${module_name}.${fun_name.lit}`'
				if is_local {
					name0 = '`${fun_name.lit}`'
				}
				p.log_d('ERROR', 'The function ${name0} expects an argument of type `${arg.ti.name}`, but you have entered an `${ti.name}`',
					docs.function_args_desc, docs.function_args_url, e.str())
				// p.error('cannot use type `${ti.name}` as type `${arg.ti.name}` in argument to `${fun_name}`')
			}
			args << e
			if i < f.args.len - 1 {
				p.check(.comma)
			}
		}
		if p.tok.kind == .comma {
			p.error('too many arguments in call to `${fun_name}`')
		}
	} else {
		if is_c_module == false {
			is_unknown = true
			p.error_pos_out = p.tok.pos
			if is_local {
				// // should be a local function, check
				p.log_d('ERROR', 'The `${fun_name}` is undefined local function', docs.local_function_desc,
					docs.local_function_url, p.tok.lit)
			} else {
				if is_external {
					// call from external module (perhaps alias?)
					p.log_d('WARN', 'unknown function `${fun_name.lit}` from module `${module_name}`',
						'', '', fun_name.lit)
				} else {
					p.log_d('WARN', 'unknown function `${fun_name.lit}`', '', '', fun_name.lit)
				}
			}
		}
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
		name: fun_name.lit
		args: args
		is_unknown: is_unknown
		tok: tok
		is_external: is_external
		module_path: module_path
		module_name: module_name
		is_c_module: is_c_module
		ti: return_ti
	}
	if is_c_module {
		p.program.c_dependencies << module_name
	}
	if is_unknown {
		p.program.table.unknown_calls << node
	}
	return node, return_ti
}

fn module_name0(tokens []token.Token) string {
	mut name := []string{}
	for t in tokens {
		name << t.lit
	}
	return name.join('.')
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
	pos_in := p.tok.pos
	mut pos_out := p.tok.pos
	is_priv := p.tok.kind == .key_defp
	mut rec_name := ''
	// mut is_method := false
	mut rec_ti := types.void_ti

	p.program.table.clear_vars()
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
	// 	p.program.table.register_var(table.Var{
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
		if p.tok.kind == .typedef {
			p.next_token()
			ti = p.parse_ti()
		}
		for arg_name in arg_names {
			arg := table.Var{
				name: arg_name
				ti: ti
			}
			args << arg
			p.program.table.register_var(arg)
			// ast_args << ast.Arg{
			// 	ti: ti
			// 	name: arg_name
			// }
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
	mut from_type := false
	if p.tok.kind == .typedef {
		p.check(.typedef)
		ti = p.parse_ti()
		p.return_ti = ti
		from_type = true
	}
	stmts := p.parse_block()
	// Try get type from body inference
	if from_type == false {
		ti = stmts[stmts.len - 1].ti
	}
	mut final_args := []table.Var{}
	for a in args {
		var := p.program.table.find_var(a.name) or { a }
		final_args << var
		ast_args << ast.Arg{
			ti: var.ti
			name: var.name
		}
	}
	pos_out = p.tok.pos
	p.program.table.register_fn(table.Fn{
		name: name
		args: final_args
		return_ti: ti
		is_external: false
		is_valid: true
		module_path: p.module_path
		module_name: p.module_name
		def_pos_in: pos_in
		def_pos_out: pos_out
	})

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
	for call in p.program.table.unknown_calls {
		p.program.table.find_fn(call.name, '') or {
			p.error_at_line('unknown function `${call.name}`', call.tok.line_nr)
			return
		}
		// println(f.return_ti.name)
		// println('IN AST typ=' + call.typ.name)
	}
}
