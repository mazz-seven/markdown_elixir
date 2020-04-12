defmodule MarkdownElixir.Parser.ThematicBreak do
  import NimbleParsec

  @doc """
  Parses ThematicBreak
  """
  def parse(content) do
    case thematic_break(content, context: [macro: nil]) do
      {:ok, tree, "", %{macro: nil}, _, _} ->
        {:ok, tree}

      {:ok, message, _rest, _context, {line, _}, _byte_offset} ->
        {:error, message, line}
    end
  end

  maybe_indent = ascii_string([?\s], min: 0, max: 3)
  maybe_whitespace = ascii_string([?\s, ?\n], min: 0)

  thematic_break =
    ignore(maybe_indent)
    |> choice([
      times(string("-") |> concat(maybe_whitespace), min: 3),
      times(string("*") |> concat(maybe_whitespace), min: 3),
      times(string("_") |> concat(maybe_whitespace), min: 3)
    ])
    |> ignore(maybe_whitespace)
    |> reduce({Enum, :join, [""]})
    |> line()
    |> post_traverse(:thematic_break)

  defp thematic_break(_rest, data, context, _line, _offset) do
    [{_break, {line, _}}] = data

    {[
       {"thematicBreak", [], [], %{line: line}}
     ], context}
  end

  defparsec(
    :thematic_break,
    thematic_break
  )
end
