defmodule MarkdownElixirTest.FencedCodeBlocks do
  use ExUnit.Case

  import MarkdownElixir.Parser.FencedCodeBlocks

  # @space = \u0020

  describe "Fenced Code Blocks" do
    # @tag runnable: true
    test "simple #89" do
      markdown = """
      ```
      <
       >
      ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["<\n >"], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "simple with tildes #90" do
      markdown = """
      ~~~
      <
       >
      ~~~
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["<\n >"], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "The closing code fence must use the same character as the opening fence #92" do
      markdown = """
      ~~~
      aaa
      ```
      ~~~
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa\n```"], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "The closing code fence must use the same character as the opening fence #93" do
      markdown = """
      ```
      aaa
      ~~~
      ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa\n~~~"], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "The closing code fence must be at least as long as the opening fence #94" do
      markdown = """
      ````
      aaa
      ```
      ``````
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa\n```"], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "The closing code fence must be at least as long as the opening fence #95" do
      markdown = """
      ~~~~
      aaa
      ~~~
      ~~~~
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa\n~~~"], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "A code block can have all empty lines as its content #99" do
      markdown = """
      ```

      \u0020\u0020
      ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["\n  "], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "A code block can be empty #100" do
      markdown = """
      ```
      ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], [""], %{line: 3}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "Fences can be indented. If the opening fence is indented, content lines will have equivalent opening indentation removed, if present #101" do
      markdown = """
       ```
       aaa
      aaa
      ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa\naaa"], %{line: 5}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "Fences can be indented. If the opening fence is indented, content lines will have equivalent opening indentation removed, if present #102" do
      markdown = """
        ```
      aaa
        aaa
      aaa
        ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa\naaa\naaa"], %{line: 6}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "Fences can be indented. If the opening fence is indented, content lines will have equivalent opening indentation removed, if present #103" do
      markdown = """
         ```
         aaa
          aaa
        aaa
         ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa\n aaa\naaa"], %{line: 6}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "Closing fences may be indented by 0-3 spaces, and their indentation need not match that of the opening fence #105" do
      markdown = """
      ```
      aaa
        ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa"], %{line: 4}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "Closing fences may be indented by 0-3 spaces, and their indentation need not match that of the opening fence #106" do
      markdown = """
         ```
      aaa
         ```
      """

      ast = {:ok, [{"code", [lang: nil, meta: nil], ["aaa"], %{line: 4}}]}

      assert parse(markdown) == ast
    end
  end

  describe "info string" do
    # @tag runnable: true
    test "An info string can be provided after opening code fence #112" do
      markdown = """
      ~~~ruby
      def foo(x)
        return 3
      end
      ~~~
      """

      ast =
        {:ok, [{"code", [lang: "ruby", meta: nil], ["def foo(x)\n  return 3\nend"], %{line: 6}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "An info string can be provided after opening code fence #113" do
      markdown = """
      ~~~     ruby startline=3 $%@#$
      def foo(x)
        return 3
      end
      ~~~
      """

      ast =
        {:ok, [{"code", [lang: "ruby", meta: nil], ["def foo(x)\n  return 3\nend"], %{line: 6}}]}

      assert parse(markdown) == ast
    end

    # @tag runnable: true
    test "An info string can be provided after opening code fence #116" do
      markdown = """
      ~~~ aa ``` ~~~
      foo
      ~~~
      """

      ast =
        {:ok, [{"code", [lang: "aa", meta: nil], ["foo"], %{line: 4}}]}

      assert parse(markdown) == ast
    end
  end
end
