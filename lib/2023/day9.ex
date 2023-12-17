# Advent of Code 2023 Day 9 - Mirage Maintenance
# https://adventofcode.com/2023/day/9

defmodule Aoc2023.Day9 do
  @dir "input/2023/"

  def q1(file_name \\ "day9.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> append_next_number()
      |> Enum.reverse()
      |> hd()
    end)
    |> Enum.sum()
  end

  def q2(file_name \\ "day9.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)
      |> Enum.reverse()
      |> append_next_number()
      |> Enum.reverse()
      |> hd()
    end)
    |> Enum.sum()
  end

  defp append_next_number(line) do
    diff = difference_sequence(line)

    diff =
      if Enum.all?(diff, &(&1 == hd(diff))) do
        diff
      else
        append_next_number(diff)
      end

    line ++ [List.last(line) + List.last(diff)]
  end

  defp difference_sequence(line) do
    line
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [a, b] -> b - a end)
  end
end
