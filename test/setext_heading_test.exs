defmodule MarkdownElixirTest.SetextHeadings do
  use ExUnit.Case

  import MarkdownElixir.Parser.SetextHeading

  describe "Setext Headings" do
    # @tag runnable: true
    test "level 1 heading" do
      markdown = """
        level 1 heading
         =============
      """

      ast = {:ok, [{"heading", [depth: 1], ["level 1 heading"], %{line: 2}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "level 2 heading" do
      markdown = """
        level 2 heading
        ----
      """

      ast = {:ok, [{"heading", [depth: 2], ["level 2 heading"], %{line: 2}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "multiline heading" do
      markdown = """
        Foo
       Bar
      -
      """

      ast = {:ok, [{"heading", [depth: 2], ["Foo\nBar"], %{line: 3}}]}

      assert parse(markdown) == ast
    end
  end
end
