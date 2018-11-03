defmodule Hoffex.BuildTest do
  use ExUnit.Case
  alias Hoffex.Build
  alias Hoffex.Node
  alias Hoffex.Pattern

  describe "build/2" do
    test "Returns defmodule with numeric id" do
      result =
        """
        defmodule Test do
        end
        """
        |> Code.string_to_quoted!()
        |> Build.tree()

      assert result == %{1 => %Node{name: "Test", type: :defmodule}}
    end

    test "Returns functions inside defmodule" do
      patterns = [
        %Pattern{name: :foo, type: :def},
        %Pattern{name: :bar, type: :defp}
      ]

      result =
        """
        defmodule Test do
          def foo do

          end

          defp bar do

          end
        end
        """
        |> Code.string_to_quoted!()
        |> Build.tree(patterns)

      %{1 => %Node{name: "Test",
          type: :defmodule,
          children: [child1, child2]
        }
      } = result

      assert Map.has_key?(result, child1)
      assert Map.has_key?(result, child2)

      assert result[child1] == %Node{name: "foo", type: :def}
      assert result[child2] == %Node{name: "bar", type: :defp}

      # We will reserve the 5 first numbers to different trees.
      # Which means you can have MAX 5 defmodules in 1 file.
      # Should be configurable though

      assert child1 > 5
      assert child2 > 5
    end

    test "Returns child function inside def" do
      patterns = [
        %Pattern{name: :foo, type: :def},
        %Pattern{name: :bar, type: :defp}
      ]

      tree =
        """
        defmodule Test do
          def foo do
            bar()
          end

          defp bar do

          end
        end
        """
        |> Code.string_to_quoted!()
        |> Build.tree(patterns)

      %{1 => %Node{name: "Test",
          type: :defmodule,
          children: [child1, child2]
        }
      } = tree
      IO.inspect tree

      foo = tree[child1]

      result = Map.get(tree, List.first(foo.children))

      assert result.name == "bar"
      assert result.type == :call
    end
  end
end
