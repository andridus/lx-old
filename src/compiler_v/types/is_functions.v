// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
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
