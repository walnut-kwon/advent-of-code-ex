# Advent of Code 2023 Day 5 - If You Give A Seed A Fertilizer
# https://adventofcode.com/2023/day/5

defmodule Aoc2023.Day5 do
  @dir "input/2023/"

  def q1(file_name \\ "day5.txt") do
    [seeds | maps] =
      File.read!(@dir <> file_name)
      |> String.split("\n\n")

    maps = maps |> Enum.map(&parse_map/1)

    seeds
    |> String.trim_leading("seeds: ")
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.map(&get_final_destination(maps, &1))
    |> Enum.min()
  end

  def q2(file_name \\ "day5.txt") do
    [seeds | maps] =
      File.read!(@dir <> file_name)
      |> String.split("\n\n")

    maps = maps |> Enum.map(&parse_map/1)

    seeds
    |> String.trim_leading("seeds: ")
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.chunk_every(2)
    |> Enum.map(fn [a, b] -> a..(a + b - 1) end)
    |> Enum.map(fn seed_range ->
      binary_check(maps, seed_range)
    end)
    |> Enum.min()
  end

  defp binary_check(maps, seed1..seed2) when seed1 >= seed2 do
    get_final_destination(maps, seed1)
  end

  defp binary_check(maps, seed1..seed2) do
    if get_final_destination(maps, seed2) - get_final_destination(maps, seed1) == seed2 - seed1 do
      get_final_destination(maps, seed1)
    else
      mid = div(seed1 + seed2, 2)
      min(binary_check(maps, seed1..mid), binary_check(maps, (mid + 1)..seed2))
    end
  end

  defp parse_map(map) do
    map
    |> String.split("\n")
    |> Enum.drop(1)
    |> Enum.map(fn line ->
      [dest_start, source_start, range_length] =
        line |> String.split(" ") |> Enum.map(&String.to_integer/1)

      {source_start..(source_start + range_length - 1),
       dest_start..(dest_start + range_length - 1)}
    end)
  end

  defp get_final_destination(maps, seed) do
    Enum.reduce(maps, seed, fn map, acc -> get_destination(map, acc) end)
  end

  defp get_destination(map, number) do
    case Enum.find(map, fn {source, _dest} -> number in source end) do
      nil -> number
      {s1.._s2, d1.._d2} -> d1 + (number - s1)
    end
  end
end
