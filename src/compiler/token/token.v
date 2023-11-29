module token

pub struct Token {
pub:
	kind       Kind
	lit        string
	line_nr    int
	pos        int
	pos_inline int
}

pub enum Kind {
	eof
	ident // name
	atom //  :atom or :'atom'
	integer // 123
	float // 123.12
	str // "my first string"
	charlist // 'abcd'
	typedef // :, ::
	// {}  () []
	lcbr
	rcbr
	lpar
	rpar
	lsbr
	rsbr
}

type Value = f64 | int | string

pub fn (t Token) get_value() Value {
	return match t.kind {
		.integer { Value(t.lit.int()) }
		.float { Value(t.lit.f64()) }
		else { Value(t.lit) }
	}
}
