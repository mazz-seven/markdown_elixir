defmodule MarkdownElixir.Parser.FencedCodeBlocks do
  import NimbleParsec

  @doc """
  Parses Fenced Code Blocks
  """
  def parse(content) do
    case fenced_code_blocks(content, context: [macro: nil]) do
      {:ok, tree, "", %{macro: nil}, _, _} ->
        {:ok, tree}

      {:ok, message, _rest, _context, {line, _}, _byte_offset} ->
        {:error, message, line}
    end
  end

  maybe_indent = ascii_string([?\s], min: 0, max: 3)
  whitespace = ascii_string([?\s], min: 1)

  backticks = times(string("`"), min: 3) |> reduce({Enum, :join, [""]})
  tildes = times(string("~"), min: 3) |> reduce({Enum, :join, [""]})
  line_break = ascii_char([?\n])

  info_string_after_backticks =
    ignore(optional(whitespace))
    |> utf8_string([not: ?\`, not: ?\n, not: ?\s], min: 1)
    |> ignore(optional(whitespace |> utf8_string([not: ?\`, not: ?\n], min: 1)))

  info_string_after_tildes =
    ignore(optional(whitespace))
    |> utf8_string([not: ?\n, not: ?\s], min: 1)
    |> ignore(optional(whitespace |> utf8_string([not: ?\n], min: 1)))

  text_line = utf8_string([not: ?\n], min: 0) |> concat(line_break)
  empty_line = ascii_char([?\n, ?\s])

  content =
    repeat(
      maybe_indent
      |> utf8_char(not: ?\~, not: ?\`)
      |> choice([text_line, empty_line])
    )

  opening_fenced_code =
    maybe_indent
    |> choice([
      backticks |> optional(info_string_after_backticks) |> wrap(),
      tildes |> optional(info_string_after_tildes) |> wrap()
    ])
    |> ignore(line_break)
    |> line()

  closing_fenced_code =
    ignore(maybe_indent)
    |> choice([
      backticks,
      tildes
    ])
    |> ignore(line_break)

  fenced_code_blocks =
    opening_fenced_code
    |> post_traverse(:opening_fenced_code)
    |> concat(content)
    |> concat(
      repeat_while(
        closing_fenced_code,
        {:stop_while, []}
      )
    )
    |> ignore(closing_fenced_code)
    |> line()
    |> post_traverse(:closing_fenced_code)

  def opening_fenced_code(_rest, [data], context, _line, _offset) do
    {[], %{context | macro: data}}
  end

  defp stop_while(
         <<?~, rest::binary>>,
         %{macro: {[_indent, opening_code_fence], {_line, _}}} = context,
         _,
         _
       ) do
    rest = get_first_row(rest)

    case opening_code_fence do
      [type, _lang] ->
        halt_or_cont(type, "~" <> rest, context)

      [type] ->
        halt_or_cont(type, "~" <> rest, context)
    end
  end

  defp stop_while(
         <<?`, rest::binary>>,
         %{macro: {[_indent, opening_code_fence], {_line, _}}} = context,
         _,
         _
       ) do
    rest = get_first_row(rest)

    case opening_code_fence do
      [type, _lang] ->
        halt_or_cont(type, "`" <> rest, context)

      [type] ->
        halt_or_cont(type, "`" <> rest, context)
    end
  end

  defp stop_while(
         <<?\s, rest::binary>>,
         context,
         line,
         offset
       ),
       do: stop_while(String.trim_leading(rest), context, line, offset)

  defp stop_while(_, context, _, _), do: {:cont, context}

  def closing_fenced_code(
        _rest,
        data,
        %{macro: {[indent, opening_code_fence], {_, _}}} = context,
        _line,
        _offset
      ) do
    [{content, {line, _}} | _rest] = Enum.reverse(data)

    content =
      content
      |> io_list_to_string()
      |> trim_indent_for_rows(indent)

    {[
       {
         "code",
         [lang: Enum.at(opening_code_fence, 1), meta: nil],
         [content],
         %{line: line}
       }
     ], %{context | macro: nil}}
  end

  defp halt_or_cont(opening, closing, context) do
    if is_match?(opening, closing) do
      {:halt, context}
    else
      {:cont, context}
    end
  end

  defp io_list_to_string(list) do
    list
    |> List.to_string()
    |> String.trim_trailing("\n")
  end

  defp trim_indent_for_rows(content, indent) do
    content
    |> String.split("\n")
    |> Enum.map(&trim_indent(&1, indent))
    |> Enum.join("\n")
  end

  defp is_match?(opening_code_fence, closing_code_fence) do
    String.at(opening_code_fence, 0) == String.at(closing_code_fence, 0) &&
      String.length(opening_code_fence) <= String.length(closing_code_fence)
  end

  defp get_first_row(rows) do
    rows |> String.split("\n") |> Enum.at(0)
  end

  defp trim_indent(row, ""), do: row

  defp trim_indent(row, indent) do
    [row_indent, rest] = Regex.run(~r/(^\s*)(.*)/, row, capture: :all_but_first)

    if String.length(row_indent) < String.length(indent) do
      rest
    else
      String.trim_leading(row, indent)
    end
  end

  defparsec(
    :fenced_code_blocks,
    fenced_code_blocks
  )
end
