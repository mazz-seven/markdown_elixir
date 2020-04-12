defmodule MarkdownElixirTest.ATXHeadings do
  use ExUnit.Case

  import MarkdownElixir.Parser.AtxHeading

  describe "heading" do
    test "is heading" do
      assert parse("# header") == {:ok, [{"heading", [depth: 1], ["header"], %{line: 1}}]}
      assert parse("## header") == {:ok, [{"heading", [depth: 2], ["header"], %{line: 1}}]}
      assert parse("### header") == {:ok, [{"heading", [depth: 3], ["header"], %{line: 1}}]}
      assert parse("#### header") == {:ok, [{"heading", [depth: 4], ["header"], %{line: 1}}]}
      assert parse("##### header") == {:ok, [{"heading", [depth: 5], ["header"], %{line: 1}}]}
      assert parse("###### header  ") == {:ok, [{"heading", [depth: 6], ["header"], %{line: 1}}]}
      assert parse("  ###### header") == {:ok, [{"heading", [depth: 6], ["header"], %{line: 1}}]}

      assert parse("  ###### header #") ==
               {:ok, [{"heading", [depth: 6], ["header"], %{line: 1}}]}

      assert parse("# header ############    ") ==
               {:ok, [{"heading", [depth: 1], ["header"], %{line: 1}}]}

      assert parse("# header ##  wow") ==
               {:ok, [{"heading", [depth: 1], ["header ##  wow"], %{line: 1}}]}

      assert parse("# header#") == {:ok, [{"heading", [depth: 1], ["header#"], %{line: 1}}]}
    end

    @tag :skip
    test "not heading" do
      # more then six hashes
      assert parse("####### header") == {:ok, ["####### header"]}

      # no space
      assert parse("#header") == {:ok, ["#header"]}

      # escaped
      assert parse("\\# header") == {:ok, ["\\# header"]}

      # Four spaces are too much
      assert parse("    # header") == {:ok, ["    # header"]}
    end
  end
end
