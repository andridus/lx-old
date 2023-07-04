module table

import compiler_v.ast

pub enum State {
	idle = 0
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
	core_modules           map[string]Module
	core_modules_path      []string
	core_modules_constants map[string][]string
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
	dependencies []string
	is_compiled  bool
	compiled_at  int
	is_main      bool
	stmts        []ast.Stmt
}

struct ModuleHeaders {
	functions []string
	requires  map[string]Require
	aliases   map[string]Alias
}

pub fn (mut m Module) put_stmts(stmts []ast.Stmt) {
	m.stmts = stmts
}
