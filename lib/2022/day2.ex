# Advent of Code 2022 Day 2 - Rock Paper Scissors
# https://adventofcode.com/2022/day/2
# Commentary: https://walnut-today.tistory.com/206

defmodule Aoc2022.Day2 do
  @dir "data/day2/"

  def q1(file_name \\ "q.txt") do
    score = %{
      {"A", "X"} => 1 + 3,
      {"A", "Y"} => 2 + 6,
      {"A", "Z"} => 3 + 0,
      {"B", "X"} => 1 + 0,
      {"B", "Y"} => 2 + 3,
      {"B", "Z"} => 3 + 6,
      {"C", "X"} => 1 + 6,
      {"C", "Y"} => 2 + 0,
      {"C", "Z"} => 3 + 3
    }

    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn round ->
      match = round |> String.split(" ") |> List.to_tuple()
      score[match]
    end)
    |> Enum.sum()
  end

  def q2(file_name \\ "q.txt") do
    score = %{
      {"A", "X"} => 3 + 0,
      {"A", "Y"} => 1 + 3,
      {"A", "Z"} => 2 + 6,
      {"B", "X"} => 1 + 0,
      {"B", "Y"} => 2 + 3,
      {"B", "Z"} => 3 + 6,
      {"C", "X"} => 2 + 0,
      {"C", "Y"} => 3 + 3,
      {"C", "Z"} => 1 + 6
    }

    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn round ->
      match = round |> String.split(" ") |> List.to_tuple()
      score[match]
    end)
    |> Enum.sum()
  end
end
