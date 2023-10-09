// Keyword Functions
module ast

pub fn (n Node) tuple_size() !int {
	if n.kind is Tuple {
		return n.nodes.len
	}
	return error('1st argument: not a tuple')
}

pub fn (n Node) tuple_elem(el int) !Node {
	if n.kind is Tuple {
		if el < n.nodes.len {
			return n.nodes[el]
		}
	}
	return error('tuple not have the element')
}
