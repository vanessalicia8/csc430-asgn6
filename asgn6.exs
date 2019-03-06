#IO.puts "Hello world from elixir"

defmodule NumC do
	defstruct n: nil
end

defmodule IdC do
	defstruct sym: nil
end

defmodule StringC do
	defstruct str: nil
end

defmodule LamC do
	defstruct params: nil, body: nil
end

defmodule IfC do
	defstruct con: nil, den: nil, els: nil
end

defmodule AppC do
	defstruct fun: nil, args: nil
end





defmodule Parser do
	def parse(s) do
		cond do
			is_number(s) -> %NumC{n: s}
			is_atom(s) -> %IdC{sym: s}
			is_bitstring(s) -> %StringC{str: s}
			is_tuple(s) ->
				case s do
					{:if, c1, c2, c3} ->
						c_1 = parse(c1)
						c_2 = parse(c2)
						c_3 = parse(c3)
						%IfC{con: c_1, den: c_2, els: c_3}
					{:lam, args, body} ->
						"lambda"
					#{:var, 
					_ -> "AppC, TODO"
				end
			true -> "ZHRL: invalid syntax"
		end
	end
end


defmodule Tests do
	def main do
		s = Parser.parse(5)
		if s != %NumC{n: s} do
			"fails"
		end

		s = Parser.parse(:hi)
		if s != %IdC{sym: s} do
			"fails"
		end

		s = Parser.parse("hello")
		if s != %StringC{str: s} do
			"fails"
		end
		
		s = Parser.parse({1, 2, 3})
		if s != %IfC{con: 1, den: 2, els: 3} do
			"fails"
		end




	end
end

Tests.main



#s = Parser.parse({1, 2, 3})
#IO.puts(s)

