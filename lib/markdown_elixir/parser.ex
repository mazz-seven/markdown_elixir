defmodule MarkdownElixir.Parser do
  import NimbleParsec

  @doc """
  Parses a surface HTML document.
  """
  def parse(content) do
    case root(content, context: [macro: nil]) do
      {:ok, tree, "", %{macro: nil}, _, _} ->
        {:ok, tree}

      {:ok, message, _rest, _context, {line, _}, _byte_offset} ->
        # Something went wrong then it has to be an error parsing the HTML tag.
        # However, because of repeat, the error is discarded, so we call node
        # again to get the proper error message.
        # {:error, message, _rest, _context, {line, _col}, _byte_offset} =
        #   node(rest, context: context, line: line, byte_offset: byte_offset)

        # {:error, message, line}
        {:error, message, line}

      {:error, message, _rest, _context, {line, _col}, _byte_offset} ->
        {:error, message, line}
    end
  end

  text = utf8_string([], min: 1)
  whitespace = ascii_string([?\s, ?\n], min: 0)
  must_whitespace = ascii_string([?\s, ?\n], min: 1)
  zero_to_three_whitespace = ascii_string([?\s, ?\n], min: 0, max: 3)
  line_break = ascii_string([?\n], min: 1)



  defparsec(
    :root,
    choice([
      text,
      whitespace
    ])
  )
end
