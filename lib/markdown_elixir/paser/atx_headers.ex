defmodule MarkdownElixir.Parser.AtxHeading do
  import NimbleParsec

  @doc """
  Parses ATX Heading
  """
  def parse(content) do
    case atx_header(content, context: [macro: nil]) do
      {:ok, tree, "", %{macro: nil}, _, _} ->
        {:ok, tree}

      {:ok, message, _rest, _context, {line, _}, _byte_offset} ->
        {:error, message, line}
    end
  end

  escaped_hash = ascii_char([?\\]) |> ignore() |> ascii_char([?#])
  whitespace = ascii_string([?\s], min: 1)
  maybe_indent = ascii_string([?\s], min: 0, max: 3)

  header_char =
    choice([
      utf8_char(not: ?\n),
      escaped_hash
    ])

  end_of_line = choice([ascii_char([?\n]), eos()])

  end_of_heading =
    whitespace
    |> ascii_string([?#], min: 1)
    |> optional(ignore(whitespace))
    |> concat(end_of_line)

  start_of_heading = ascii_string([?#], min: 1, max: 6) |> ignore(whitespace)
  extra_content = repeat(header_char)

  content =
    lookahead_not(string(" #"))
    |> concat(header_char)
    |> times(min: 1)

  atx_header =
    ignore(maybe_indent)
    |> concat(start_of_heading)
    |> unwrap_and_tag(:depth)
    |> optional(ignore(whitespace))
    |> optional(content)
    |> choice([
      ignore(end_of_heading),
      extra_content
    ])
    |> ignore(end_of_line)
    |> post_traverse(:heading_element)

  defp heading_element(_rest, data, context, {line, _}, _offset) do
    [{:depth, str} | rest] = Enum.reverse(data)

    {[
       {
         "heading",
         [depth: byte_size(str)],
         [rest |> List.to_string() |> String.trim()],
         %{line: line}
       }
     ], context}
  end

  defparsec(
    :atx_header,
    atx_header
  )
end
