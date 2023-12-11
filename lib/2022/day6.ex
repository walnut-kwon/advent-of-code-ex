# Advent of Code 2022 Day 6 - Tuning Trouble
# https://adventofcode.com/2022/day/6
# Commentary: https://walnut-today.tistory.com/210

defmodule Aoc2022.Day6 do
  @dir "data/day6/"

  def q1(file_name \\ "q.txt") do
    marker_length = 4

    File.read!(@dir <> file_name)
    |> String.graphemes()
    |> Enum.chunk_every(marker_length, 1)
    |> Enum.find_index(fn chunk ->
      MapSet.new(chunk) |> MapSet.size() == marker_length
    end)
    |> Kernel.+(marker_length)
  end

  def q2(file_name \\ "q.txt") do
    marker_length = 14

    File.read!(@dir <> file_name)
    |> String.graphemes()
    |> Enum.chunk_every(marker_length, 1)
    |> Enum.find_index(fn chunk ->
      MapSet.new(chunk) |> MapSet.size() == marker_length
    end)
    |> Kernel.+(marker_length)
  end
end
