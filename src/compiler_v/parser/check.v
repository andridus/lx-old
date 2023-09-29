module parser

import compiler_v.ast

pub fn (mut p Parser) check_node(mut node ast.Node) {
	if !node.meta.is_last_expr {
		match node.kind {
			ast.Ast {
				// NOTE: match should be or not inside this list
				if node.kind.lit in ['match', 'assign', 'def'] {
					return
				}
			}
			ast.Function {
				return
			}
			ast.FunctionCaller {
				if node.kind.return_ti.kind == .void_ {
					return
				}
			}
			else {}
		}
		p.error_line = node.meta.line
		p.error_pos_inline = node.meta.start_pos
		p.error_pos_in = node.meta.start_pos
		p.error_pos_out = p.lexer.pos
		node.mark_with_is_unused()
		p.log('WARN', 'expression `${node.left}` evaluated but not used', '')
	}
}
