defmodule MarkdownElixirTest.ATXHeadings do
  use ExUnit.Case

  import MarkdownElixir.Parser

  test "empty node" do
    assert parse("") == {:ok, [""]}
  end

  test "only text" do
    assert parse("Some text") == {:ok, ["Some text"]}
  end

  describe "heading" do
    test "is heading" do
      assert parse("# header") == {:ok, [{"h1", [], ["header"], %{line: 1}}]}
      assert parse("## header") == {:ok, [{"h2", [], ["header"], %{line: 1}}]}
      assert parse("### header") == {:ok, [{"h3", [], ["header"], %{line: 1}}]}
      assert parse("#### header") == {:ok, [{"h4", [], ["header"], %{line: 1}}]}
      assert parse("##### header") == {:ok, [{"h5", [], ["header"], %{line: 1}}]}
      assert parse("###### header  ") == {:ok, [{"h6", [], ["header"], %{line: 1}}]}
      assert parse("  ###### header") == {:ok, [{"h6", [], ["header"], %{line: 1}}]}
      assert parse("  ###### header #") == {:ok, [{"h6", [], ["header"], %{line: 1}}]}
      assert parse("# header ############    ") == {:ok, [{"h1", [], ["header"], %{line: 1}}]}
      assert parse("# header ##  wow") == {:ok, [{"h1", [], ["header ##  wow"], %{line: 1}}]}
      assert parse("# header#") == {:ok, [{"h1", [], ["header#"], %{line: 1}}]}
    end

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
