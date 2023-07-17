module ast

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
