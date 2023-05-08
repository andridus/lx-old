module ast

import token

fn tokens_to_literal_type(tokens [][]token.Token) (LiteralType, []Identifier) {
	if tokens.len == 1 && tokens[0].len == 1 {
		return type_from_token_to_literal(tokens[0][0]), []Identifier{}
	} else {
		return Nil{}, []Identifier{}
		// return ast.AST{first: first, second: ast.Metadata{}, third: ast.Nil}
	}
	return Nil{}, []Identifier{}
}

pub fn type_from_token_to_literal(tk token.Token) LiteralType {
	match tk.typ {
		._integer {
			return Integer{
				value: tk.literal.int()
				metadata: Metadata{
					attributes: {
						'line': tk.line.str()
					}
				}
			}
		}
		._string {
			return String{
				value: tk.literal
				metadata: Metadata{
					attributes: {
						'line': tk.line.str()
					}
				}
			}
		}
		._atom {
			return Atom{
				value: tk.literal
				metadata: Metadata{
					attributes: {
						'line': tk.line.str()
					}
				}
			}
		}
		._nil {
			return Nil{
				metadata: Metadata{
					attributes: {
						'line': tk.line.str()
					}
				}
			}
		}
		else {
			return Nil{
				metadata: Metadata{
					attributes: {
						'line': tk.line.str()
					}
				}
			}
		}
	}
}
