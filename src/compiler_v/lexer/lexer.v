module lexer

import compiler_v.token

pub struct Lexer {
	input []u8
pub mut:
	lines      int = 1
	pos        int
	pos_inline int
	total      int
	tokens     []token.Token
}

fn (mut l Lexer) parse_token() token.Token {
	if l.pos == l.total {
		return l.new_token_eof()
	}
	u := l.input[l.pos]
	return match u {
		32, 9 {
			l.skip_space()
		}
		10 {
			l.new_token_new_line()
		}
		`_` {
			l.new_token('_', .underscore, 1)
		}
		`#` {
			if l.match_next_char(`{`) {
				l.match_else()
			} else {
				l.get_token_comment(u)
			}
		}
		`@` {
			if l.match_next_char(`d`) {
				if l.match_next_char(`o`) {
					if l.match_next_char(`c`) {
						pass, qtd := l.match_next_char_ignore_space(`"`)
						if pass {
							l.advance(qtd)
							l.get_text_delim(token.Kind.doc, '"""', '"""')
						} else {
							l.advance(-3)
							l.match_else()
						}
					} else {
						l.advance(-2)
						l.new_token('@', .arrob, 1)
					}
				} else {
					l.advance(-1)
					l.new_token('@', .arrob, 1)
				}
			} else if l.match_next_char(`m`) {
				if l.match_next_char(`o`) {
					if l.match_next_char(`d`) {
						if l.match_next_char(`u`) {
							if l.match_next_char(`l`) {
								if l.match_next_char(`e`) {
									if l.match_next_char(`d`) {
										if l.match_next_char(`o`) {
											if l.match_next_char(`c`) {
												pass, qtd := l.match_next_char_ignore_space(`"`)
												if pass {
													l.advance(qtd)
													l.get_text_delim(token.Kind.moduledoc,
														'"""', '"""')
												} else {
													l.match_else()
												}
											} else {
												l.match_else()
											}
										} else {
											l.match_else()
										}
									} else {
										l.match_else()
									}
								} else {
									l.match_else()
								}
							} else {
								l.match_else()
							}
						} else {
							l.match_else()
						}
					} else {
						l.match_else()
					}
				} else {
					l.match_else()
				}
			} else {
				l.new_token('@', .arrob, 1)
			}
		}
		`"` {
			if l.match_next_char(`"`) {
				if l.match_next_char(`"`) {
					l.advance(-2) // return to first occurence of \"
					l.get_text_delim(token.Kind.multistring, '"""', '"""')
				} else {
					l.match_else()
				}
			} else {
				l.get_text_delim(token.Kind.str, '"', '"')
			}
		}
		`'` {
			l.get_text_delim(token.Kind.charlist, "'", "'")
		}
		`=` {
			if l.match_next_char(`=`) {
				if l.match_next_char(`=`) {
					l.new_token('===', .eq, 3)
				} else {
					l.new_token('==', .eq, 2)
				}
			} else if l.match_next_char(`>`) {
				l.new_token('=>', .arrow, 2)
			} else if l.match_next_char(`~`) {
				l.new_token('=~', .eq, 2)
			} else {
				l.new_token('=', .assign, 1)
			}
		}
		`!` {
			if l.match_next_char(`=`) {
				if l.match_next_char(`=`) {
					l.new_token('!==', .ne, 3)
				} else {
					l.new_token('!=', .ne, 2)
				}
			} else {
				l.new_token('!', .bang, 1)
			}
		}
		`&` {
			if l.match_next_char(`&`) {
				l.new_token('&&', .and, 2)
			} else {
				l.new_token('&', .capture, 1)
			}
		}
		`~` {
			ch, pass := l.get_next_alpha()
			if pass {
				l.new_token('~${ch}', .sigil, 2)
			} else {
				l.new_token('~', .bit_not, 1)
			}
		}
		`|` {
			if l.match_next_char(`|`) {
				if l.match_next_char(`|`) {
					l.new_token('|||', .logical_or, 3)
				} else {
					l.new_token('||', .logical_or, 2)
				}
			} else {
				l.new_token('|', .pipe, 1)
			}
		}
		`+` {
			if l.match_next_char(`+`) {
				if l.match_next_char(`+`) {
					l.new_token('+++', .plus_concat, 3)
				} else {
					l.new_token('++', .plus_concat, 2)
				}
			} else {
				l.new_token('+', .plus, 1)
			}
		}
		`-` {
			if l.match_next_char(`-`) {
				if l.match_next_char(`-`) {
					l.new_token('---', .minus_concat, 3)
				} else {
					l.new_token('--', .minus_concat, 2)
				}
			}
			if l.match_next_char(`>`) {
				l.new_token('->', .right_arrow, 2)
			} else {
				l.new_token('-', .minus, 1)
			}
		}
		`<` {
			if l.match_next_char(`-`) {
				l.new_token('<-', .left_arrow, 2)
			} else if l.match_next_char(`=`) {
				l.new_token('<=', .le, 2)
			} else if l.match_next_char(`>`) {
				l.new_token('<>', .string_concat, 2)
			} else {
				l.new_token('<', .lt, 1)
			}
		}
		`>` {
			if l.match_next_char(`=`) {
				l.new_token('>=', .ge, 2)
			} else {
				l.new_token('>', .gt, 1)
			}
		}
		`.` {
			if l.match_next_char(`.`) {
				l.new_token('..', .range, 2)
			} else {
				l.new_token('.', .dot, 1)
			}
		}
		`:` {
			if l.match_next_char(`:`) {
				l.new_token('::', .typedef, 1)
			} else {
				l.get_token_atom(u)
			}
		}
		`%` {
			l.new_token('%', .mod, 1)
		}
		`?` {
			l.new_token('?', .question, 1)
		}
		`*` {
			l.new_token('*', .mul, 1)
		}
		`,` {
			l.new_token(',', .comma, 1)
		}
		`/` {
			l.new_token('/', .div, 1)
		}
		`(` {
			l.new_token('(', .lpar, 1)
		}
		`)` {
			l.new_token(')', .rpar, 1)
		}
		`{` {
			l.new_token('{', .lcbr, 1)
		}
		`}` {
			l.new_token('}', .rcbr, 1)
		}
		`[` {
			l.new_token('[', .lsbr, 1)
		}
		`]` {
			l.new_token(']', .rsbr, 1)
		}
		else {
			// l.advance(-1)
			l.match_else()
		}
	}
}
