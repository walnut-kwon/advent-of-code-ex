# Advent of Code 2021 Day 25 - Sea Cucumber
# https://adventofcode.com/2021/day/25
# Commentary: https://walnut-today.tistory.com/68

defmodule Aoc2021.Day25 do
  def parse_input(file_name) do
    input =
      file_name
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(&String.codepoints/1)

    w = input |> hd() |> length()
    h = input |> length()

    {nested_list_to_map(input), w, h}
  end

  defp nested_list_to_map(nested_list) do
    nested_list
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {val, col_index} ->
        {{col_index, row_index}, val}
      end)
      |> Enum.reject(fn {_k, v} -> v == "." end)
    end)
    |> Enum.into(%{})
  end

  def run_q1(file_name \\ "input/day25.txt") do
    file_name
    |> parse_input()
    |> do_run_q1(0, false)
    |> print()
    |> IO.puts()
  end

  defp do_run_q1({map, w, h}, count, true) do
    IO.inspect(count)
    {map, w, h}
  end

  defp do_run_q1({map, w, h}, count, false) do
    east_move =
      map
      |> Enum.reduce(%{}, fn
        {{col_index, row_index}, ">" = ch}, acc_map ->
          case next_point_empty?({map, w, h}, {col_index, row_index}, ch) do
            {next_point, ^ch, true} ->
              Map.put(acc_map, next_point, ch)

            {_, ^ch, false} ->
              Map.put(acc_map, {col_index, row_index}, ch)
          end

        {{col_index, row_index}, "v" = ch}, acc_map ->
          Map.put(acc_map, {col_index, row_index}, ch)
      end)

    # print({east_move, w, h})
    # |> IO.puts()

    south_move =
      east_move
      |> Enum.reduce(%{}, fn
        {{col_index, row_index}, "v" = ch}, acc_map ->
          case next_point_empty?({east_move, w, h}, {col_index, row_index}, ch) do
            {next_point, ^ch, true} ->
              Map.put(acc_map, next_point, ch)

            {_, ^ch, false} ->
              Map.put(acc_map, {col_index, row_index}, ch)
          end

        {{col_index, row_index}, ">" = ch}, acc_map ->
          Map.put(acc_map, {col_index, row_index}, ch)
      end)

    do_run_q1({south_move, w, h}, count + 1, map == south_move)
  end

  defp next_point_empty?({map, w, h}, {x, y}, ch) do
    next_point =
      case ch do
        ">" -> if x == w - 1, do: {0, y}, else: {x + 1, y}
        "v" -> if y == h - 1, do: {x, 0}, else: {x, y + 1}
        _ -> nil
      end

    {
      next_point,
      ch,
      not is_nil(next_point) and Map.get(map, next_point, ".") == "."
    }
  end

  defp print({map, w, h}) do
    0..(h - 1)
    |> Enum.map(fn y ->
      0..(w - 1)
      |> Enum.map(fn x ->
        Map.get(map, {x, y}, ".")
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end
end
