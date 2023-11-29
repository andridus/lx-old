module token

fn test_create_token() {
	token := Token{}
	assert Kind.eof == token.kind
	assert 0 == token.line_nr
	assert 0 == token.pos_inline
	assert 0 == token.pos
}

fn test_create_token_with_custom_attributes() {
	token := Token{
		kind: .atom
		pos: 2
		pos_inline: 2
		line_nr: 1
	}
	assert Kind.atom == token.kind
	assert 1 == token.line_nr
	assert 2 == token.pos_inline
	assert 2 == token.pos
}

fn test_get_value_from_token() {
	token := Token{
		kind: .integer
		lit: '1'
	}
	assert Kind.integer == token.kind
	assert '1' == token.lit
	assert Value(1) == token.get_value()
}
