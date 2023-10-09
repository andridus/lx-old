// Keyword Functions
module ast

pub fn (n Node) keyword_get(key string) !Node {
	if n.kind is List {
		for n0 in n.nodes {
			if n0.kind is Tuple {
				size := n0.tuple_size()!
				if size == 2 {
					return n0.nodes[1]
				} else {
					return error('1st argument: not a keyword')
				}
			}
		}
	}
	return error('1st argument: not a keyword list')
}
