defmodule MarkdownElixirTest.ThematicBreak do
  use ExUnit.Case

  import MarkdownElixir.Parser.ThematicBreak

  describe "Thematic Break" do
    @tag runnable: true
    test "asterisk break" do
      markdown = "*******"
      ast = {:ok, [{"thematicBreak", [], [], %{line: 1}}]}

      assert parse(markdown) == ast
    end

    @tag runnable: true
    test "underscore break" do
      markdown = "___"
      ast = {:ok, [{"thematicBreak", [], [], %{line: 1}}]}

      assert parse(markdown) == ast
    end

    @tag runnable: true
    test "hyphen break" do
      markdown = " ---"
      ast = {:ok, [{"thematicBreak", [], [], %{line: 1}}]}

      assert parse(markdown) == ast
    end

    @tag :skip
    test "wrong charachter" do
      markdown = "++++++"
      ast = {:ok, ["++++++"]}

      assert parse(markdown) == ast
    end

    @tag :skip
    test "not enough characters" do
      markdown = "__"
      ast = {:ok, ["__"]}

      assert parse(markdown) == ast
    end

    @tag :skip
    test "to many spaces at the begining" do
      markdown = "    ___"
      ast = {:ok, ["    ___"]}

      assert parse(markdown) == ast
    end

    @tag :skip
    test "spaces are allowed between the characters" do
      markdown = " - -    -   "
      ast = {:ok, [{"thematicBreak", [], [], %{line: 1}}]}

      assert parse(markdown) == ast
    end
  end
end
