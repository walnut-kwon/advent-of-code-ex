# Advent of Code 2022 Day 1 - Calorie Counting
# https://adventofcode.com/2022/day/1
# Commentary: https://walnut-today.tistory.com/205

defmodule Aoc2022.Day1 do
  @dir "data/day1/"

  def q1(file_name \\ "q.txt") do
    file_name
    |> sum_of_each_elf()
    |> Enum.max()
  end

  def q2(file_name \\ "q.txt") do
    file_name
    |> sum_of_each_elf()
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.sum()
  end

  defp sum_of_each_elf(file_name) do
    File.read!(@dir <> file_name)
    |> String.split("\n\n")
    |> Enum.map(fn elf ->
      elf
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.sum()
    end)
  end
end
