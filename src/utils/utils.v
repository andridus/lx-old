module utils

import os

pub fn filename_without_extension(filename string) string {
	return  filename[0..filename.len - os.file_ext(filename).len]
}