// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module table

import compiler_v.ast

pub enum State {
	idle       = 0
	preparing
	started
	processing
	finished
	error
}

pub enum TypeMsg {
	info
	warning
	error
}

pub struct Program {
pub mut:
	table                  &Table
	main_module            string
	modules                map[string]Module
	compile_order          []string
	c_dependencies         []string
	v_dependencies         []string
	core_modules           map[string]Module
	core_modules_path      []string
	core_modules_constants map[string][]string
	global_structs         map[string]Module
	build_folder           string
	build_state            State
	build_progress         int
	errors                 []ProgramMsg
	warnings               []ProgramMsg
	infos                  []ProgramMsg
}

pub struct ProgramMsg {
	kind TypeMsg
pub mut:
	msg  string
	line int
	col  int
}

pub struct Module {
pub mut:
	name         string
	path         string
	headers      ModuleHeaders
	is_struct    bool
	is_enum      bool
	dependencies []string
	aliases      map[string]string
	is_compiled  bool
	compiled_at  int
	is_main      bool
	asts         []ast.Node
}

pub struct ModuleHeaders {
	functions []string
	requires  map[string]Require
}

pub fn (m Module) str() string {
	mut s := []string{}
	for ast in m.asts {
		unsafe { s << ast.str() }
	}
	return '{${s.join(',')}}'
}

// pub fn (mut m Module) put_stmts(stmts []ast.Stmt) {
// 	m.stmts = stmts
// }

pub fn (mut m Module) put_ast(nodes []ast.Node) {
	m.asts = nodes
}
