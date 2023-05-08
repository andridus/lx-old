module ast

interface Native {
	parse_to_exast()
}

pub fn parse_to_ex(atom string, left LiteralType, right LiteralType) string {
	left_metadata := left.get_metadata_str()
	left_str := left.get_ex_value().to_string()
	right_str := right.get_ex_value().to_string()
	return '{:${atom}, [${left_metadata}], [${left_str}, ${right_str}]}'
}

struct ExNil {}

type Float = f32
type ExLiteral = ExAST | ExNil | Float | []ExAST | []string | int | string

pub fn (ex ExLiteral) to_string() string {
	return match ex {
		string { ex }
		[]string { ex.join(',') }
		int, Float { ex.str() }
		ExNil { 'nil' }
		ExAST { '{${ex.first.to_string()}, [${ex.metadata}], ${ex.third.to_string()}}' }
		[]ExAST { '' }
	}
}

pub struct ExAST {
	first    ExLiteral
	metadata string
	third    ExLiteral
}

fn (ex ExAST) msg() string {
	return 'error'
}

pub struct Nil {
	value    u8
	metadata Metadata
}

fn (lt Nil) get_value() ExLiteral {
	return ExNil{}
}

pub struct String {
	value    string
	metadata Metadata
}

fn (lt String) get_value() ExLiteral {
	return lt.value
}

pub struct Integer {
	value    int
	metadata Metadata
}

fn (lt Integer) get_value() ExLiteral {
	return lt.value
}

pub struct Atom {
	value    string
	ref      byte
	metadata Metadata
}

fn (lt Atom) get_value() ExLiteral {
	return ExAST{
		first: ':${lt.value}'
		metadata: lt.metadata.str()
		third: ExNil{}
	}
}

// pub struct Function{
// 	statements Ast
// 	metadata map[string]string
// }
pub struct Metadata {
	attributes map[string]string
}

pub struct AST {
	first    LiteralType
	metadata Metadata
	third    LiteralType
}

fn (lt AST) get_value() ExLiteral {
	return []ExAST{}
}

pub type LiteralType = AST | Atom | Integer | Nil | String

pub fn (lt LiteralType) get_ex_value() ExLiteral {
	return match lt {
		Nil { 0 }
		String, Integer, Atom { lt.get_value() }
		AST { lt.get_value() }
	}
}

pub fn (lt Metadata) str() string {
	mut metadata := ''
	for k, v in lt.attributes {
		metadata += '${k}: ${v}'
	}
	return metadata
}

pub fn (lt LiteralType) get_metadata_str() string {
	return lt.metadata.str()
}
