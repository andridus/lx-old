// Copyright (c) 2023 Helder de Sousa. All rights reserved/
// Use of this source code is governed by a MIT license
// that can be found in the LICENSE file
module ast

pub fn (n NodeLeft) atomic_str() string {
	return match n {
		Atom { n.name }
		int { n.str() }
		f64 { n.str() }
		string { n }
		Node { '' }
	}
}

pub fn (n NodeLeft) str() string {
	return match n {
		Atom {
			':' + n.name
		}
		int {
			n.str()
		}
		f64 {
			n.str()
		}
		string {
			n
		}
		Node {
			res := n.str()
			res
		}
	}
}

pub fn (n Node) str() string {
	match n.kind {
		String {
			return "\"${n.left.str()}\""
		}
		Function {
			mut str := []string{}
			for n0 in n.nodes {
				str << n0.str()
			}
			list := '[' + str.join(',') + ']'
			return '{${n.left.str()}, ${n.meta}, ${list}}'
		}
		Tuple {
			mut str := []string{}
			for n0 in n.nodes {
				str << n0.str()
			}
			return '{' + str.join(',') + '}'
		}
		Boolean {
			return '${n.left.str()}'
		}
		Atomic {
			return '${n.left.str()}'
		}
		Atom {
			return '${n.left.str()}'
		}
		Integer, Float {
			return '${n.left.str()}'
		}
		List {
			mut str := []string{}
			for n0 in n.nodes {
				str << n0.str()
			}
			return '[' + str.join(',') + ']'
		}
		else {
			mut str := []string{}
			for n0 in n.nodes {
				str << n0.str()
			}
			list := '[' + str.join(',') + ']'
			return '{${n.left.str()}, ${n.meta}, ${list}}'
		}
	}
}

pub fn format_str(str string) string {
	mut s := ''
	mut n := 0
	str0 := replace_all_split(str, [['{{', '{$1{'], ['[{', '[$1{'],
		['],[{', '], [$1{'], ['},[$1{', '},$1[$1{']], '$1')
	for s0 in str0 {
		s += '\n' + ' '.repeat(n) + s0
		n++
	}
	str1 := replace_all_split(s, [['}]]', '}]$2]'], [']}', ']}$2'],
		[']}$2,', ']},'], [']}$2}]', ']}}$2]']], '$2')
	s = ''
	for s1 in str1 {
		if n > 0 {
			if s1.len <= 2 && n - s1.len > 0 {
				n = n - s1.len
			} else {
				n--
			}
		}
		s += '\n' + ' '.repeat(n) + s1
	}
	return s.trim('\n').trim(' ').trim('\n')
}

fn replace_all_split(str string, pairs [][]string, splt string) []string {
	mut s0 := str.clone()
	for p in pairs {
		s0 = s0.replace(p[0], p[1])
	}
	return s0.split(splt)
}

fn (m Meta) str() string {
	mut mets := ['line: ${m.line}']
	if m.inside_parens > 0 {
		mets << 'inside_parens: true'
	}
	if m.ti.kind != .void_ {
		mets << 'type: ${m.ti}'
	}
	return '[${mets.join(',')}]'
}

pub fn (k NodeKind) str() string {
	return match k {
		String { 'string' }
		Tuple { 'tuple' }
		Boolean { 'boolean' }
		Atomic { 'atom' }
		Atom { 'atom' }
		Integer { 'integer' }
		Float { 'float' }
		List { 'list' }
		ListFixed { 'list_fixed' }
		Alias { 'alias' }
		Ast { k.lit }
		Case { 'case' }
		Char { 'char' }
		Enum { 'enum' }
		Function { 'function' }
		FunctionCaller { 'function_caller' }
		Map { 'map' }
		Module { 'module' }
		Nil { 'nil' }
		Port { 'port' }
		Record { 'record' }
		Struct { 'struct' }
		Underscore { 'underscore' }
	}
}
