defmodule Hoffex.FindTest do
  use ExUnit.Case
  alias Hoffex.Find
  alias Hoffex.Pattern

  describe "patterns/2" do
    test "find correct functions" do
      result =
        """
        defmodule Test do
          def test_function do

          end

          defp priv_function(a, b) do

          end
        end
        """
        |> Code.string_to_quoted!()
        |> Find.patterns()

      assert result == [
               %Pattern{name: :priv_function, type: :defp},
               %Pattern{name: :test_function, type: :def}
             ]
    end
  end
end
