module ast

interface Native {
	get_value()
}

struct Metadata {
	line       int
	col        int
	attributes map[string]string
}

struct AST {
pub:
	metadata Metadata
	main     LiteralType
	args     []LiteralType
}

struct Nil {
pub:
	value    u8
	metadata Metadata
}

struct String {
pub:
	value    string
	metadata Metadata
}

struct Integer {
pub:
	value    int
	metadata Metadata
}

struct Atom {
	ref byte
pub:
	value    string
	metadata Metadata
}

pub type LiteralType = AST | Atom | Integer | Nil | String

pub fn (mt Metadata) str() string {
	return 'line: ${mt.line}'
}
