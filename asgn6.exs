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
		      if is_list(args) do
		         a = Enum.map(args, fn(x) -> parse(x) end)
		         b = parse(body)
		        %LamC{params: a, body: b}
		     else "ZHRL: lam: invalid input"
		     end
	       _ ->
		      cond do
		         elem(s, 0) == :var ->
			    if tuple_size(s) > 1 do
                       		parse(desugar(s))
			    else "ZHRL: var: invalid input"
			    end
		         tuple_size(s) > 1 ->
                   	    s1 = Tuple.to_list(s)
			    arg_list = tl(s1)
                   	    f = parse(hd(s1))
			    if is_list(arg_list) do
			       a = Enum.map(arg_list, fn(x) -> parse(x) end)
			       %AppC{fun: f, args: a}
			    else "ZHRL: app: invalid input"
		            end
		      end
	       end
	   true -> "ZHRL: invalid syntax"
	 end
   end

   def desugar(s) do
      size = tuple_size(s)
      body = elem(s, size-1)
      ss = (Tuple.to_list(s)) -- [:var, body]
      params = Enum.map(ss, fn(x) -> get_params(x) end)
      values = Enum.map(ss, fn(x) -> get_values(x) end)
      l = [{:lam, params, body}] ++ values
      List.to_tuple(l)
   end
   def get_params(e) do
      case e do
	 [sym, :=, _expr] -> sym
	 _ -> "ZHRL: var: invalid input"
      end
   end
   def get_values(e) do
      case e do
	 [_sym, :=, expr] -> expr
	 _ -> "ZHRL: var: invalid input"
      end
   end
end

#TESTS
ExUnit.start()
defmodule Tests do
use ExUnit.Case, async: true
   test "parse numc" do
      assert Parser.parse(5) == %NumC{n: 5}
   end
   test "parse idc" do
      assert Parser.parse(:hi) == %IdC{sym: :hi}
   end
   test "parse stringc" do
      assert Parser.parse("hello") == %StringC{str: "hello"}
   end
   test "parse ifc" do
      assert Parser.parse({:if, 1, 2, 3}) == 
	%IfC{con: %NumC{n: 1}, den: %NumC{n: 2}, els: %NumC{n: 3}}
   end
   test "parse lamc" do
      assert Parser.parse({:lam, [1], 2}) == 
	%LamC{params: [%NumC{n: 1}], body: %NumC{n: 2}}
   end

   test "parse appc" do
      assert Parser.parse({:f, 2}) == 
	%AppC{fun: %IdC{sym: :f}, args: [%NumC{n: 2}]}
   end

   test "parse appc2" do
      assert Parser.parse({:+, :y, 2}) == 
	%AppC{fun: %IdC{sym: :+}, args: [%IdC{sym: :y}, %NumC{n: 2}]}
   end

   test "desugar var" do
      assert Parser.desugar({:var, [:y, :=, 98], {:+, :y, 2}}) == 
	{{:lam, [:y], {:+, :y, 2}}, 98}
   end

   test "parse var" do
      assert Parser.parse({:var, [:y, :=, 98], {:+, :y, 2}}) == 
	%AppC{fun: %LamC{body: %AppC{args: [%IdC{sym: :y}, %NumC{n: 2}], 
        fun: %IdC{sym: :+}}, params: [%IdC{sym: :y}]},
        args: [%NumC{n: 98}]}
   end

   test "parse lam error" do
      assert Parser.parse({:lam, 1, 2}) == 
	"ZHRL: lam: invalid input"
   end
end



