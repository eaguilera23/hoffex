defmodule Hoffex.Find do
  alias Hoffex.Pattern
  @default Application.get_env(:hoffex, :patterns) || [:def, :defp]

  # Here I am trying to build a multiple clause match
  # {} -> someting
  #
  # defmacro dynamic_match(patterns, do: expression) do
  #   ast_patterns =
  #     Enum.reduce(patterns, quote do _, acc -> acc end, fn pattern, acc_ast ->
  #       match = quote do {unquote(pattern), _, args}, acc -> [unquote(expression).(unquote(pattern), args) | acc] end
  #       Enum.concat(match, acc_ast)
  #     end)

  #   {:fn, [], ast_patterns}
  # end
    #build_pattern = fn pattern, args -> %Pattern{name: get_name(args), type: pattern} end

    #Enum.reduce(defs, [], dynamic_match(unquote(@default), do: build_pattern))

    #Enum.reduce(defs, [], fn
    #  {pattern, _, args}, acc ->
    #    if Enum.member?(patterns, pattern) do
    #      [%Pattern{name: get_name(args), type: pattern} | acc]
    #    else
    #      acc
    #    end
    #end)

  def patterns(ast), do: parse(ast)

  defp parse({:defmodule, _, [_, [do: {_, _, defs}]]}) do
    Enum.reduce(defs, [], fn
      {type, _, args}, acc when type in @default ->
        [%Pattern{name: get_name(args), type: type} | acc]
      _, acc -> acc
    end)
  end
 
  defp get_name([{name, _, _}, _]), do: name
end
