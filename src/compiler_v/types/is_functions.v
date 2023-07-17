module types

[inline]
pub fn (ti TypeIdent) is_integer() bool {
	return ti.kind == .integer_
}

[inline]
pub fn (ti TypeIdent) is_float() bool {
	return ti.kind == .float_
}

[inline]
pub fn (ti &TypeIdent) is_number() bool {
	return ti.is_integer() || ti.is_float()
}
