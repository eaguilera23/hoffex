defmodule Hoffex.Build do
  alias Hoffex.Node
  alias Hoffex.Pattern

  def tree(ast, patterns \\ []) do
    get_nodes(ast, patterns)
  end

  defp get_nodes({:defmodule, _, [name_list, [do: {_, _, content}]]}, patterns, tree_num \\ 1) do

    {types, names} = Enum.reduce(patterns, {[],[]}, fn 
      %{type: type, name: name}, {types, names} -> 
        {[type | types], [name | names]}
    end)

    {calls_nodes, calls_map} =
      Enum.reduce(content, {[], %{}}, fn
        {type, _, [name, calls_ast]}, {acc, calls} ->
          if type in types do
            {calls_uids, sub_calls_map} =
              Macro.prewalk(calls_ast, [], fn 
                {atom, _, _} = node, acc ->
                  if atom in names do
                    {node, [%Node{name: get_name(atom), type: :call} | acc]}
                  else
                    {node, acc}
                  end
                node, acc -> {node, acc}
              end)
              |> elem(1)
              |> Enum.reduce({[], %{}}, fn node, {uids, map} ->
                uid = :rand.uniform(4096)
                {[uid | uids], Map.put_new(map, uid, node)}
              end)

              {[%Node{name: get_name(name), type: type, children: calls_uids} | acc], Map.merge(calls, sub_calls_map)}
          end
        _, acc -> acc
      end)

    {children_uids, children_map} =
      Enum.reduce(calls_nodes, {[], calls_map}, fn node, {uids, map} ->
        uid = :rand.uniform(4096)
        {[uid | uids], Map.put_new(map, uid, node)}
      end)

    name = get_name(name_list)

    Map.put_new(children_map, tree_num, %Node{name: name, type: :defmodule, children: children_uids})
  end

  defp get_name({:__aliases__, _, name_list}) do
    Enum.join(name_list, ".")
  end
  defp get_name([{name, _, _}, _]), do: to_string(name)
  defp get_name({name, _, _}), do: to_string(name)
  defp get_name(atom) when is_atom(atom), do: to_string(atom)
end
