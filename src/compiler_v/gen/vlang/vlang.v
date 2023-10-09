// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module vlang

import strings
import compiler_v.ast
import compiler_v.table
import compiler_v.types
import os
import time

pub struct VGen {
pub:
	program &table.Program
mut:
	definitions   strings.Builder
	out_main      strings.Builder
	out_modules   map[string]strings.Builder
	out_function  strings.Builder
	out_expr      strings.Builder
	out_exprs     map[string]string
	out_expr_type map[string][]string

	defer_return bool
	context_var  string

	in_var_decl             bool
	in_function_decl        bool
	in_function_args        bool
	in_binary_exp           bool
	in_expr_decl            bool
	in_ident_c              bool
	is_last_statement       bool
	last_argument           string
	parent_deep             int
	var_count               int
	var_name                string
	var_ti                  types.TypeIdent
	local_vars_binding_arr0 []string
	local_vars_binding_arr1 []string
	match_eval_arg          ?ast.Node
	fn_agg                  map[string][]ast.Function
	fn_agg_node             map[string][]ast.Node
	fn_main                 string
	fn_main_ti              types.TypeIdent

	parent_node ast.Node
}

pub fn gen(prog table.Program) VGen {
	mut outm := map[string]strings.Builder{}
	for o in prog.compile_order {
		outm[o] = strings.new_builder(100)
	}

	mut g := VGen{
		program: &prog
		out_main: strings.new_builder(100)
		out_function: strings.new_builder(100)
		out_expr: strings.new_builder(100)
		out_modules: outm
	}

	for modl in prog.compile_order {
		for node in prog.modules[modl].asts {
			g.parse_node(modl, node)
		}
	}
	return g
}

pub fn (mut g VGen) main_function() string {
	return g.out_main.str()
}

pub fn (mut g VGen) save() !string {
	// read native functions
	native := os.read_file('src/compiler_v/gen/vlang/native.v.source') or {
		eprintln("the file 'native.v.source' not found in dir 'src/compiler_v/gen/vlang' ")
		exit(1)
	}
	mut bin := []u8{}
	mut order := g.program.compile_order.clone()
	order.reverse()
	bin << native.bytes()
	for modl in order {
		bin << g.out_modules[modl]
		// println(g.out_modules[modl].bytestr())
	}
	bin << g.out_main
	filename := time.now().unix_time_nano()
	filepath := '${g.program.build_folder}/${filename}.v'
	os.write_file(filepath, bin.bytestr())!
	return filepath
}

pub fn (mut g VGen) write(modl string, s string) {
	if g.in_expr_decl {
		g.out_expr.writeln(s)
	} else {
		if g.in_function_decl {
			g.out_function.write_string(s)
		} else {
			g.out_modules[modl].write_string(s)
		}
	}
}

pub fn (mut g VGen) writeln(modl string, s string) {
	if g.in_expr_decl {
		g.out_expr.writeln(s)
	} else {
		if g.in_function_decl {
			g.out_function.writeln(s)
		} else {
			g.out_modules[modl].writeln(s)
		}
	}
}

fn (mut g VGen) endln(modl string) {
	g.writeln(modl, '')
}

fn parse_function_name(str string) string {
	return str.replace(':', '').replace('.', '_').replace('?', '_question')
}

fn defer_return(node ast.Node) bool {
	return match node.kind {
		ast.Ast {
			match node.kind.lit {
				'match' { true }
				else { false }
			}
		}
		else {
			false
		}
	}
}

fn (mut g VGen) parse_many_nodes(modl string, nodes []ast.Node) {
	for node in nodes {
		g.parse_node(modl, node)
		g.write(modl, '\n')
	}
}
