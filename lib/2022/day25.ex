# Advent of Code 2022 Day 25 - Full of Hot Air
# https://adventofcode.com/2022/day/25
# Commentary: https://walnut-today.tistory.com/229

defmodule Aoc2022.Day25 do
  @dir "data/day25/"

  def q1(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(&parse_snafu_number/1)
    |> Enum.sum()
    |> convert_to_snafu_number()
  end

  defp parse_snafu_number(number_str) do
    number_str
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {v, i} ->
      case v do
        "0" -> 0
        "1" -> 1 * Integer.pow(5, i)
        "2" -> 2 * Integer.pow(5, i)
        "-" -> -1 * Integer.pow(5, i)
        "=" -> -2 * Integer.pow(5, i)
      end
    end)
    |> Enum.sum()
  end

  def convert_to_snafu_number(decimal) do
    decimal
    |> Integer.digits(5)
    |> Enum.reverse()
    |> IO.inspect()
    |> Enum.reduce({[], 0}, fn digit, {acc, carry} ->
      case digit + carry do
        0 -> {[0 | acc], 0}
        1 -> {[1 | acc], 0}
        2 -> {[2 | acc], 0}
        3 -> {["=" | acc], 1}
        4 -> {["-" | acc], 1}
        5 -> {[0 | acc], 1}
      end
      |> IO.inspect()
    end)
    |> then(fn {acc, carry} ->
      if carry >= 1 do
        [carry | acc]
      else
        acc
      end
    end)
    |> Enum.join("")
  end
end
