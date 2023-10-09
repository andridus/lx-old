// Copyright (c) 2023 Helder de Sousa. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module token

pub struct Pos {
pub:
	len     int
	line_nr int
	pos     int
	col     int
pub mut:
	last_line int
}
