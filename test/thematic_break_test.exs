defmodule MarkdownElixirTest.ThematicBreak do
  use ExUnit.Case

  import MarkdownElixir.Parser

  describe "Thematic Break" do
    test "asterisk break" do
      markdown = "*******"
      ast = {:ok, [{"hr", [], [], %{line: 1}}]}

      assert parse(markdown) == ast
    end

    test "underscore break" do
      markdown = "___"
      ast = {:ok, [{"hr", [], [], %{line: 1}}]}

      assert parse(markdown) == ast
    end

    test "hyphen break" do
      markdown = " ---"
      ast = {:ok, [{"hr", [], [], %{line: 1}}]}

      assert parse(markdown) == ast
    end

    test "wrong charachter" do
      markdown = "++++++"
      ast = {:ok, ["++++++"]}

      assert parse(markdown) == ast
    end

    test "not enough characters" do
      markdown = "__"
      ast = {:ok, ["__"]}

      assert parse(markdown) == ast
    end

    test "to many spaces at the begining" do
      markdown = "    ___"
      ast = {:ok, ["    ___"]}

      assert parse(markdown) == ast
    end

    test "spaces are allowed between the characters" do
      markdown = " - -    -   "
      ast = {:ok, [{"hr", [], [], %{line: 1}}]}

      assert parse(markdown) == ast
    end
  end
end
