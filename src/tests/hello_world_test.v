import compiler_v
import os
import compiler_v.table
import compiler_v.ast
import compiler_v.types

pub fn test_lexer_ex_file() {
	file := "hello_world"
	root := os.abs_path("")
	path := "$root/src/tests/$file"
	filepath := "$path/${file}.ex"
	mut bin := compiler_v.generate(path)

	// Generate HelloWorld Module
	assert 'HelloWorld' == bin.program.modules['HelloWorld'].name
	assert table.Module{
			name: 'HelloWorld'
			path: filepath
			is_main: true
			stmts: [
				ast.Stmt(ast.Module{
					name: 'HelloWorld'
					stmt: ast.Stmt(ast.Block{
							stmts: [ast.Stmt(ast.FnDecl{
									name: 'main'
									arity: '0'
									stmts: [ast.Stmt(ast.ExprStmt{
											expr: ast.Expr(ast.StringLiteral{
													val: 'Hello World'
													ti: types.string_ti
											})
											ti: types.string_ti
									})]
									ti: types.new_sum_ti([types.Kind.string_])
									args: []
							})]
							name: '$path/$file'
							args: []
					})
					is_parent_module: false
			})
		]
	} == bin.program.modules['HelloWorld']
	assert 'Hello World' == compiler_v.execute(mut bin)
}