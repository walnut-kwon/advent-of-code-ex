# Advent of Code 2023 Day 3 - Gear Ratios
# https://adventofcode.com/2023/day/3

defmodule Aoc2023.Day3 do
  @dir "input/2023/"

  def q1(file_name \\ "day3.txt") do
    map =
      File.read!(@dir <> file_name)
      |> String.split("\n")
      |> Enum.with_index()

    engine_parts =
      map
      |> Enum.flat_map(&find_parts/1)
      |> Map.new()

    map
    |> Enum.flat_map(&find_numbers/1)
    |> Enum.filter(&adjacent?(engine_parts, &1))
    |> Enum.map(& &1.number)
    |> Enum.sum()
  end

  def q2(file_name \\ "day3.txt") do
    map =
      File.read!(@dir <> file_name)
      |> String.split("\n")
      |> Enum.with_index()

    engine_parts =
      map
      |> Enum.flat_map(&find_parts/1)
      |> Map.new()

    map
    |> Enum.flat_map(&find_numbers/1)
    |> Enum.flat_map(&adjacent_gear(engine_parts, &1))
    |> Enum.group_by(fn {gear_position, _} -> gear_position end, fn {_, number} -> number end)
    |> Enum.filter(fn {_gear_position, numbers} -> length(numbers) == 2 end)
    |> Enum.map(fn {_gear_position, [n1, n2]} -> n1 * n2 end)
    |> Enum.sum()
  end

  defp find_parts({line_str, line}) do
    Regex.scan(~r/[^\d\.]/, line_str, return: :index)
    |> Enum.map(fn [{offset, 1}] ->
      {{line, offset}, String.at(line_str, offset)}
    end)
  end

  defp find_numbers({line_str, line}) do
    Regex.scan(~r/[0-9]+/, line_str, return: :index)
    |> Enum.map(fn [{offset, length}] ->
      %{
        line: line,
        number: String.slice(line_str, offset, length) |> String.to_integer(),
        offset: offset,
        length: length
      }
    end)
  end

  defp adjacent?(engine_parts, number) do
    adjacent_points(number)
    |> Enum.any?(&Map.has_key?(engine_parts, &1))
  end

  defp adjacent_points(%{line: line, offset: offset, length: length}) do
    horizontal_range = (offset - 1)..(offset + length)

    [{line, offset - 1}, {line, offset + length}]
    |> Kernel.++(Enum.map(horizontal_range, fn x -> {line - 1, x} end))
    |> Kernel.++(Enum.map(horizontal_range, fn x -> {line + 1, x} end))
  end

  defp adjacent_gear(engine_parts, number) do
    adjacent_points(number)
    |> Enum.filter(&(Map.get(engine_parts, &1) == "*"))
    |> Enum.map(&{&1, number.number})
  end
end
