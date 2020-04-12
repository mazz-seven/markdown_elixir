defmodule MarkdownElixir.Parser.SetextHeading do
  import NimbleParsec

  @doc """
  Parses Setext Heading
  """
  def parse(content) do
    case setext_heading(content, context: [macro: nil]) do
      {:ok, tree, "", %{macro: nil}, _, _} ->
        {:ok, tree}

      {:ok, message, _rest, _context, {line, _}, _byte_offset} ->
        {:error, message, line}
    end
  end

  maybe_indent = ascii_string([?\s], min: 0, max: 3)

  line_break = ascii_char([?\n])

  level_1 =
    ignore(maybe_indent) |> times(string("="), min: 1) |> wrap() |> reduce({List, :to_string, []})

  level_2 =
    ignore(maybe_indent) |> times(string("-"), min: 1) |> wrap() |> reduce({List, :to_string, []})

  text =
    repeat(
      ignore(maybe_indent)
      |> utf8_char(not: ?=, not: ?-, not: ?>, not: ?\s)
      |> utf8_string([not: ?\n], min: 0)
      |> concat(line_break)
    )

  setext_heading =
    text
    |> line()
    |> choice([
      level_1,
      level_2
    ])
    |> ignore(line_break)
    |> post_traverse(:setext_heading)

  defp setext_heading(_rest, data, context, _line, _offset) do
    [{content, {line, _}}, header] = Enum.reverse(data)

    depth =
      cond do
        String.starts_with?(header, "=") ->
          1

        String.starts_with?(header, "-") ->
          2

        true ->
          raise "invalid setext_heading"
      end

    {[
       {
         "heading",
         [depth: depth],
         [content |> List.to_string() |> String.trim()],
         %{line: line}
       }
     ], context}
  end

  defparsec(
    :setext_heading,
    setext_heading
  )
end
