# Advent of Code 2022 Day 4 - Camp Cleanup
# https://adventofcode.com/2022/day/4
# Commentary: https://walnut-today.tistory.com/208

defmodule Aoc2022.Day4 do
  @dir "data/day4/"

  def q1(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.count(fn ranges ->
      [first, second] = str_to_range(ranges)

      if Range.size(first) >= Range.size(second) do
        a..b = first
        c..d = second

        a <= c and b >= d
      else
        a..b = second
        c..d = first

        a <= c and b >= d
      end
    end)
  end

  def q2(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.count(fn ranges ->
      [first, second] = str_to_range(ranges)

      not Range.disjoint?(first, second)
    end)
  end

  defp str_to_range(ranges) do
    ranges
    |> String.split(",")
    |> Enum.map(fn range ->
      range
      |> String.split("-")
      |> then(fn [a, b] ->
        String.to_integer(a)..String.to_integer(b)
      end)
    end)
  end
end
