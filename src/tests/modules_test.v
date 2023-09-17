import compiler_v
import os
import compiler_v.table
import compiler_v.ast
import compiler_v.types
import compiler_v.token

pub fn test_lexer_ex_file() {
	file := 'a'
	root := os.abs_path('')
	path := '${root}/src/tests/modules'
	filepath := '${path}/${file}.ex'
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'A' == bin.program.modules['A'].name
	assert table.Module{
		name: 'A'
		path: filepath
		is_main: true
		dependencies: ['B', 'C']
		stmts: [
			ast.Stmt(ast.Module{
				name: 'A'
				stmt: ast.Stmt(ast.Block{
					stmts: [
						ast.Stmt(ast.FnDecl{
							name: 'main'
							arity: '0'
							stmts: [
								ast.Stmt(ast.ExprStmt{
									expr: ast.Expr(ast.CallExpr{
										name: 'one'
										arity: '0'
										is_external: true
										module_path: 'b'
										module_name: 'B'
										tok: token.Token{
											kind: token.Kind.modl
											lit: 'B'
											line_nr: 3
											pos: 33
											pos_inline: 6
										}
										ti: types.float_ti
									})
									ti: types.float_ti
								}),
							]
							ti: types.new_sum_ti([
								types.Kind.float_,
							])
							args: []
						}),
						ast.Stmt(ast.FnDecl{
							name: 'other'
							arity: '0'
							stmts: [
								ast.Stmt(ast.ExprStmt{
									expr: ast.Expr(ast.CallExpr{
										name: 'sum'
										arity: '0'
										args: []
										is_unknown: false
										is_external: true
										is_c_module: false
										is_v_module: false
										module_path: 'c'
										module_name: 'C'
										tok: token.Token{
											kind: token.Kind.modl
											lit: 'C'
											line_nr: 6
											pos: 64
											pos_inline: 6
										}
										ti: types.integer_ti
									})
									ti: types.integer_ti
								}),
							]
							ti: types.new_sum_ti([
								types.Kind.integer_,
							])
							args: []
							is_private: false
							is_used: false
						}),
					]
					name: '${path}/${file}'
					args: []
				})
				is_parent_module: false
			}),
		]
	} == bin.program.modules['A']
	assert '2.0' == compiler_v.execute(mut bin)
}
