defmodule MarkdownElixirTest.IndentedCodeBlocks do
  use ExUnit.Case

  import MarkdownElixir.Parser.IndentedCodeBlocks

  # @space = \u0020

  describe "Indented Code Blocks" do
    @tag runnable: true
    test "simple #77" do
      markdown = """
          a simple
            indented code block
      """

      ast =
        {:ok, [{"code", [lang: nil, meta: nil], ["a simple\n  indented code block"], %{line: 3}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "code block are literal text #80" do
      markdown = """
          <a/>
          *hi*

          - one
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["<a/>\n*hi*\n\n- one"], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test " three chunks separated by blank lines #81" do
      markdown = """
          chunk1

          chunk2
          \u0020\u0020
          \u0020
          \u0020
          chunk3
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["chunk1\n\nchunk2\n  \n \n \nchunk3"], %{line: 8}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "The first line can be indented more than four spaces #86" do
      markdown = """
              foo
          bar
      """

      ast =
        {:ok, [{"code", [lang: nil, meta: nil], ["    foo\nbar"], %{line: 3}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "Trailing spaces are included in the code block’s content #88" do
      markdown = """
          foo\u0020\u0020
      """

      ast =
        {:ok, [{"code", [lang: nil, meta: nil], ["foo  "], %{line: 2}}]}

      assert parse(markdown) == ast
    end
  end
end
