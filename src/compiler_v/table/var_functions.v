module table

import compiler_v.types

pub fn (mut t Table) clear_vars() {
	if t.local_vars.len > 0 {
		t.local_vars = map[string]Var{}
	}
}

pub fn (mut t Table) update_var_ti(v Var, ti types.TypeIdent) {
	t.local_vars[v.name] = Var{
		...v
		ti: ti
	}
}

pub fn (mut t Table) new_tmp_var() string {
	t.tmp_cnt++
	return 'tmp${t.tmp_cnt}'
}

pub fn (mut t Table) register_var(v Var) {
	t.local_vars[v.name] = v
}

pub fn (t &Table) find_var(name string) ?Var {
	for key, var in t.local_vars {
		if key == name {
			return var
		}
	}
	return none
}
