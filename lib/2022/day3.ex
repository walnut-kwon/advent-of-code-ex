# Advent of Code 2022 Day 3 - Rucksack Reorganization
# https://adventofcode.com/2022/day/3
# Commentary: https://walnut-today.tistory.com/207

defmodule Aoc2022.Day3 do
  @dir "data/day3/"

  def q1(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn backpack ->
      part_size = div(String.length(backpack), 2)

      [set1, set2] =
        String.split_at(backpack, part_size)
        |> Tuple.to_list()
        |> Enum.map(fn part ->
          part |> String.graphemes() |> MapSet.new()
        end)

      MapSet.intersection(set1, set2)
      |> single_elem_mapset_to_char()
      |> priority()
    end)
    |> Enum.sum()
  end

  def q2(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.chunk_every(3)
    |> Enum.map(fn group ->
      group
      |> Enum.map(fn backpack ->
        backpack |> String.graphemes() |> MapSet.new()
      end)
      |> Enum.reduce(&MapSet.intersection/2)
      |> single_elem_mapset_to_char()
      |> priority()
    end)
    |> Enum.sum()
  end

  defp single_elem_mapset_to_char(mapset) do
    mapset
    |> MapSet.to_list()
    |> Enum.join("")
    |> String.to_charlist()
    |> hd()
  end

  defp priority(char) when char in ?A..?Z do
    char - ?A + 27
  end

  defp priority(char) when char in ?a..?z do
    char - ?a + 1
  end
end
