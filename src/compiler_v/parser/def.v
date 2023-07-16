// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import compiler_v.ast
import compiler_v.table
import compiler_v.types
import compiler_v.token
import compiler_v.docs
import compiler_v.color

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
	mut is_unknown := false
	mut is_c_module := false
	mut tok := p.tok
	mut arg_exprs := []ast.Expr{}
	mut arity_num := 0
	mut arity_args := []string{}
	mut arity_name := ''
	mut fun_name := token.Token{}
	mut module_ref := [p.tok]
	mut return_ti := types.void_ti
	// Check if is a C module
	if p.tok.lit == '_c_' {
		is_c_module = true
		module_ref = []
	}
	// Initial lexer position for stmt
	p.error_pos_in = p.tok.pos - p.tok.lit.len

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
	// Gets the name of module or local function
	p.check(kind)
	mut icount := 0
	for p.tok.kind == .dot {
		p.check(.dot)
		if p.tok.kind == .ident {
			if icount > 0 {
				module_ref << fun_name
				icount = 0
			}
			fun_name = p.tok
			icount++
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
	// Check if is a local function
	if is_local {
		module_name = p.current_module
	}
	// Check if is aliased
	aliased_name := p.program.modules[p.current_module].aliases[module_name]
	if aliased_name.len > 0 {
		module_name = aliased_name
	}
	// get module path
	module_path := module_name.to_lower()
	// If module placed with anything
	if fun_name.kind == .ignore {
		p.warn('Module ${module_name} is orphan')
	}
	/// Check the args of function
	p.check(.lpar)
	if f := p.program.table.find_fn(fun_name.lit, module_name) {

		for p.tok.kind != .rpar {
			mut e, ti := p.expr(0)
			match e {
				ast.Ident {
					mut a := e as ast.Ident
					a.set_pointer()
					e = ast.Expr(a)
				}
				else {}
			}
			arity_num++
			arity_args << ti.name
			arg_exprs << e

			if p.tok.kind != .rpar {
				p.check(.comma)
			}
		}

		arity_name = '${arity_num}_${arity_args.join('_')}'
		finded := f.idx_arity_by_args[arity_name]
		mut valid_arity := false
		if finded > 0 {
			a := f.arities[finded]
			if a.is_valid {
				valid_arity = true
			}
			return_ti = a.return_ti
		}

		if valid_arity == false {
			mut args_ := []string{}
			for _, a in f.arities {
				if a.is_valid {
					arg_len := a.args.len
					if arg_len > 0 {
						mut args0 := []string{}
						for a1 in a.args {
							args0 << a1.ti.str()
						}

						args_ << color.fg(color.white, 0, '${fun_name.lit}(${args0.join(', ')})')
					} else {
						args_ << color.fg(color.white, 0, '${fun_name.lit}()')
					}
				}
			}
			p.error_pos_out = p.tok.pos
			fun_name0 := color.fg(color.white, 0, '${fun_name.lit}(${arity_args.join(', ')})')
			p.log_d('ERROR', 'The function ${fun_name0} ${color.fg(color.red, 0, 'not exists, check one of')} ${args_.join(' | ')}',
				docs.function_args_desc, docs.function_args_url, '')
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
		} else {
			for p.tok.kind != .rpar {
				mut e, ti := p.expr(0)
				arity_num++
				arity_args << ti.name
				match e {
					ast.Ident {
						mut a := e as ast.Ident
					 c := p.program.table.find_var(a.name) or {table.Var{}}
					 ex := c.expr.expr
					 match ex {
						ast.EmptyExpr {}
						else {
							a.set_pointer()
							e = ast.Expr(a)
						}
					 }
					}
					else {}
				}
				arg_exprs << e
				if p.tok.kind != .rpar {
					p.check(.comma)
				}
			}
		}
	}
	p.check(.rpar)

	if p.tok.kind == .typedef {
		p.check(.typedef)
		return_ti = p.parse_ti()
	}
	node := ast.CallExpr{
		name: fun_name.lit
		arity: arity_name
		args: arg_exprs
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
	name := p.check_name()
	p.check(.lpar)

	// GET Args
	mut args := []table.Var{}
	mut ast_args := []ast.Arg{}

	for p.tok.kind != .rpar {
		mut is_nil := false
		is_nil = p.tok.kind == .key_nil
		mut arg_names := [p.check_name()]
		for p.tok.kind == .comma {
			p.check(.comma)
			arg_names << p.check_name()
		}
		// parse type of ARG
		mut ti := types.void_ti
		if is_nil {
			ti = types.nil_ti
		} else if p.tok.kind == .typedef {
			p.check(.typedef)

			ti = p.parse_ti()
		}
		for arg_name in arg_names {
			typ0 := p.program.table.find_type(ti.str()) or { types.type_from_ti(ti) }
			arg := table.Var{
				name: arg_name
				ti: ti
				type_: typ0
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
		if stmts.len > 0 {
			ti = stmts[stmts.len - 1].ti
		}
	}
	mut final_args := []table.Var{}
	mut args_overfn := '${args.len}'
	for a in args {
		// var := p.program.table.find_var(a.name) or { a }
		var := ast.Arg{
			ti: a.ti
			name: a.name
		}
		final_args << a
		ast_args << var
		args_overfn += '_${var.ti.name}'
	}

	pos_out = p.tok.pos
	p.program.table.register_or_update_fn(args_overfn, final_args, ti, table.Fn{
		name: name
		is_external: false
		is_valid: true
		module_path: p.module_path
		module_name: p.module_name
		def_pos_in: pos_in
		def_pos_out: pos_out
	})
	// println(p.program.table)

	return ast.FnDecl{
		name: name
		stmts: stmts
		ti: ti
		arity: args_overfn
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
