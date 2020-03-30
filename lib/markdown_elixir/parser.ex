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

  thematic_break =
    ignore(zero_to_three_whitespace)
    |> choice([
      times(string("-") |> concat(whitespace), min: 3),
      times(string("*") |> concat(whitespace), min: 3),
      times(string("_") |> concat(whitespace), min: 3)
    ])
    |> ignore(whitespace)
    |> reduce({Enum, :join, [""]})
    |> line()
    |> post_traverse(:thematic_break)

  defparsecp(
    :end_of_heading,
    must_whitespace |> times(string("#"), min: 1) |> concat(whitespace) |> eos(),
    inline: true
  )

  heading =
    ignore(zero_to_three_whitespace)
    |> times(string("#"), min: 1, max: 6)
    |> line()
    |> ignore(must_whitespace)
    |> repeat(lookahead_not(parsec(:end_of_heading)) |> utf8_char([]))
    |> ignore(parsec(:end_of_heading) |> optional())
    |> post_traverse(:heading_element)

  defp heading_element(_rest, data, context, _line, _offset) do
    [{header, {line, _}} | rest] = Enum.reverse(data)

    {[
       {"h#{length(header)}", [], [rest |> IO.iodata_to_binary() |> String.trim()], %{line: line}}
     ], context}
  end

  defp thematic_break(_rest, data, context, _line, _offset) do
    [{_break, {line, _}}] = data

    {[
       {"hr", [], [], %{line: line}}
     ], context}
  end

  defparsec(
    :root,
    choice([
      thematic_break,
      heading,
      text,
      whitespace
    ])
  )
end
