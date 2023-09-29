// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module types

import compiler_v.token

pub fn type_from_ti(ti TypeIdent) Type {
	return match ti.kind {
		.atom_ {
			atom_type
		}
		.void_ {
			void_type
		}
		.nil_ {
			nil_type
		}
		.any_ {
			void_type
		}
		.pointer_ {
			void_type
		}
		.integer_ {
			integer_type
		}
		.float_ {
			float_type
		}
		.string_ {
			string_type
		}
		.char_ {
			char_type
		}
		.bool_ {
			bool_type
		}
		else {
			void_type
		}
	}
}

pub fn type_from_token(tok token.Token) Type {
	return match tok.kind {
		.key_any { void_type }
		.key_nil { nil_type }
		.key_true, .key_false { bool_type }
		.integer { integer_type }
		.float { float_type }
		.str { string_type }
		else { void_type }
	}
}

pub fn ti_from_token(tok token.Token) TypeIdent {
	return match tok.kind {
		.key_any { any_ti }
		.key_nil { nil_ti }
		.integer { integer_ti }
		.float { float_ti }
		.str { string_ti }
		else { void_ti }
	}
}
