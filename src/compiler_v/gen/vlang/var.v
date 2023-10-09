module vlang

fn (mut g VGen) temp_var(modl string) string {
	g.var_count++
	tmp_var := 'tmpvar_${g.var_count}'
	return tmp_var
}

fn (mut g VGen) clear_vars() {
	g.var_count = 0
	g.local_vars_binding_arr0.clear()
	g.local_vars_binding_arr1.clear()
}

fn (mut g VGen) set_var_custom(s string, v string) string {
	g.local_vars_binding_arr0 << s
	g.local_vars_binding_arr1 << v
	return v
}

fn (mut g VGen) set_var(s string) string {
	g.var_count++
	s0 := '${g.context_var}var_${g.var_count}'
	g.local_vars_binding_arr0 << s
	g.local_vars_binding_arr1 << s0
	return s0
}

fn (mut g VGen) get_var(s string) ?string {
	for i, v0 in g.local_vars_binding_arr0 {
		if v0 == s {
			return g.local_vars_binding_arr1[i]
		}
	}
	return none
}

fn (mut g VGen) get_var_force(s string) string {
	if a := g.get_var(s) {
		return a
	} else {
		return ''
	}
}
