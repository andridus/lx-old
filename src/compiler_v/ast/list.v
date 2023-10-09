// Keyword Functions
module ast

pub fn (n Node) list_get_nth(u int) !Node {
	if n.kind is List {
		if u < n.nodes.len {
			return n.nodes[u]
		}
		return error('1st argument: not have the ${u}nth item')
	}
	return error('1st argument: not a list')
}
