module docs

pub const (
	local_function_desc = 'The local functions should be defined in the context of the module before they\ncan be used anywhere in the module.'
	local_function_url  = 'https://github.com/andridus/lx/wiki/Refer%C3%AAncia-da-Linguagem#funcoes-locais'
	///
	function_args_desc  = 'The Lx has the inference system to analyze your code to get the right type for your argument,\nbut if is not work you should be define manually using the symbol :: after variable and/or after\nfunction and enter right return type.\n\nLike this:\n\n def fun(my_var :: string) :: string do \n ... \n'
	function_args_url   = 'https://github.com/andridus/lx/wiki/Refer%C3%AAncia-da-Linguagem#tipagem-estatica-e-inferencia'
)
