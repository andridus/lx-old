defmodule A do
	def main() do
		B.one()
		:ok
	end
	def other() do
		C.sum()
	end
end