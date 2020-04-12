defmodule MarkdownElixir.Parser.IndentedCodeBlocks do
  import NimbleParsec

  @doc """
  Parses Indented Code Blocks
  """
  def parse(content) do
    case indented_code_blocks(content, context: [macro: nil]) do
      {:ok, tree, "", %{macro: nil}, _, _} ->
        {:ok, tree}

      {:ok, message, _rest, _context, {line, _}, _byte_offset} ->
        {:error, message, line}
    end
  end

  indent = ascii_string([?\s], 4)
  line_break = ascii_char([?\n])

  text_line = ignore(indent) |> utf8_string([not: ?\n], min: 0) |> concat(line_break)
  empty_line = ascii_char([?\n, ?\s])

  content = repeat(choice([text_line, empty_line]))

  indented_code_blocks =
    content
    |> line()
    |> post_traverse(:indented_code_blocks)

  defp indented_code_blocks(_rest, data, context, {_line, _}, _offset) do
    [{content, {line, _}} | _rest] = Enum.reverse(data)

    {[
       {
         "code",
         [lang: nil, meta: nil],
         [content |> List.to_string() |> String.trim_trailing("\n")],
         %{line: line}
       }
     ], context}
  end



  defparsec(
    :indented_code_blocks,
    indented_code_blocks
  )
end
