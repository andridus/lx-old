module ast

pub fn (n NodeLeft) str() string {
	return match n {
		string {
			':' + n
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

// """
// {
// 	{:defmodule, [line: 1], [
// 		{:__aliases__, [line: 1], [:PrecedenceTest]}, [
// 			{:do, {:def, [line: 2,type: SUM::float_], [
// 				{:main, [line: 2,type: SUM::float_], []}, [
// 					{:do, {:+, [line: 3,type: float_],[1.0,2.0999999046325684]}}
// 					]]}}
// 				]]}}
// """"
// pub fn (x Expr) str() string {
// 	match x {
// 		BinaryExpr {
// 			return '{:${x.op.str()}, ${x.meta}, [${x.left.str()}, ${x.right.str()}]}'
// 		}
// 		UnaryExpr {
// 			return x.left.str() + x.op.str()
// 		}
// 		IntegerLiteral {
// 			return x.val.str()
// 		}
// 		StringLiteral {
// 			return "\"${x.val.str()}\""
// 		}
// 		CharlistLiteral {
// 			return '\'${x.val.bytestr()}\''
// 		}
// 		StructInit {
// 			return x.name
// 		}
// 		Ident {
// 			return x.name
// 		}
// 		KeywordList {
// 			mut st := []string{}
// 			for i in x.items {
// 				if !i.atom && i.key.contains_u8(32) {
// 					st << '"${i.key}": ${i.value}'
// 				} else {
// 					st << '${i.key}:  ${i.value}'
// 				}
// 			}
// 			return '[' + st.join(', ') + ']'
// 		}
// 		else {
// 			return '-'
// 		}
// 	}
// }

// pub fn (node Stmt) str() string {
// 	match node {
// 		VarDecl {
// 			return node.name + ' = ' + node.expr.str()
// 		}
// 		ExprStmt {
// 			return node.expr.str()
// 		}
// 		FnDecl {
// 			return 'fn ${node.name}() { ${node.stmts.len} stmts }'
// 		}
// 		Block {
// 			return node.str()
// 		}
// 		else {
// 			return '[unhandled stmt str]'
// 		}
// 	}
// }
