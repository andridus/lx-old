module parser

import table
import lexer
import os
import color
import token

// The parse module is responsible to make an overview about files
// and define basic informations about module compilation, that's include:
// - Requireds modules to compile
// - Detects the  main module over the main function defined in itself
// - Set the headers->functions with summary of functions that are defined in itself
pub fn preprocess(path string, prog &table.Program) {
	mut prog0 := unsafe { prog }
	if os.is_dir(path) {
		files := os.ls('${path}') or { []string{} }
		for file in files {
			parse_modules('${path}/${file}', prog)
		}
		prog0.compile_order = compile_order(prog)
	}
}

fn parse_modules(path string, prog &table.Program) {
	text := os.read_file(path) or { panic(err) }
	mut l := lexer.new(text)
	l.generate_tokens()
	mut prog0 := unsafe { prog }
	mut is_main := false
	mut dependencies := []string{}
	tk_len := l.tokens.len
	mut name := ''
	mut i := 0

	// ------ analyze entire source code of file
	for i < tk_len {
		match l.tokens[i].kind {
			// Gets the name module
			.key_defmodule {
				i++
				i, name = get_module_name(i, l.tokens[i], l.tokens)
			}
			// Gets the requireds module by seek source code for external function calling
			// TODO: gets the arity of function
			.modl {
				mut module_required_name := []string{}
				module_required_name << l.tokens[i].lit
				i++
				for j := i; j < tk_len; j++ {
					if l.tokens[j].kind == .dot {
						continue
					} else if l.tokens[j].kind == .modl {
						module_required_name << l.tokens[j].lit
					} else {
						break
					}
				}
				if module_required_name.len > 0 {
					dependencies << module_required_name.join('.')
				}
			}
			// Define the main module when have the main function
			// TODO: get functions with arity and put on module headers struct, event if not defined type.
			.key_def {
				i++
				if i < tk_len {
					tk := l.tokens[i]
					if tk.kind == .ident && tk.lit == 'main' {
						is_main = true
					}
				}
			}
			else {}
		}
		i++
	}
	//--- end of analisys
	prog0.modules[name] = table.Module{
		name: name
		path: path
		dependencies: dependencies
		is_main: is_main
	}
}

// Get compile order from table that have information about modules
pub fn compile_order(prog &table.Program) []string {
	mut main_module := ''
	mut dependencies := []string{}
	for _, mod in prog.modules {
		if mod.is_main {
			main_module = mod.name
			dependencies.prepend(mod.dependencies)
		}
	}
	for req in dependencies.clone() {
		dependencies.prepend(prog.modules[req].dependencies)
	}
	mut arr := []string{}

	for nam in uniq(dependencies) {
		a := prog.modules[nam].name
		if a.len == 0 {
			println(color.fg(color.red, 0, 'COMPILER: Module ${nam} is required and wasn\'t defined in current project'))
			exit(0)
		}
		arr << a
	}
	arr << main_module
	if main_module == '' {
		println(color.fg(color.red, 0, "COMPILER: Main module wasn't defined in current project"))
		exit(0)
	}
	return arr
}

fn uniq(arr []string) []string {
	mut new_arr := []string{}
	for el in arr {
		mut in_array := false
		for i := 0; i < new_arr.len; i++ {
			if new_arr[i] == el {
				in_array = true
			}
		}
		if !in_array {
			new_arr << el
		}
	}
	return new_arr
}

fn get_module_name(i int, tok token.Token, tokens []token.Token) (int, string) {
	tk_len := tokens.len
	mut i0 := i
	mut name := []string{}
	if i0 < tk_len && tokens[i0].kind == .modl {
		name << tokens[i0].lit
		i0++
		for j := i0; j < tk_len; j++ {
			if tokens[j].kind == .dot {
				continue
			} else if tokens[j].kind == .modl {
				name << tokens[j].lit
			} else {
				break
			}
			i0++
		}
	}
	return i0, name.join('.')
}
