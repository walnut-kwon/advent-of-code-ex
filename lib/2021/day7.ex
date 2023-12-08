# Advent of Code 2021 Day 7 - The Treachery of Whales
# https://adventofcode.com/2021/day/7
# Commentary: https://walnut-today.tistory.com/48

defmodule Aoc2021.Day7 do
  def parse_input do
    path = "input/day7.txt"

    File.read!(path)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @spec run_q1 :: {non_neg_integer, non_neg_integer}
  def run_q1 do
    crabs = parse_input() |> Enum.frequencies()

    {min, max} = crabs |> Map.keys() |> Enum.min_max()

    min_fuel_pos =
      min..max
      |> Enum.min_by(&get_fuel_q1(crabs, &1))

    {min_fuel_pos, get_fuel_q1(crabs, min_fuel_pos)}
  end

  @spec run_q2 :: {non_neg_integer, non_neg_integer}
  def run_q2 do
    crabs = parse_input() |> Enum.frequencies()

    {min, max} = crabs |> Map.keys() |> Enum.min_max()

    min_fuel_pos =
      min..max
      |> Enum.min_by(&get_fuel_q2(crabs, &1))

    {min_fuel_pos, get_fuel_q2(crabs, min_fuel_pos)}
  end

  defp get_fuel_q1(crabs, to_pos) do
    crabs
    |> Enum.map(fn {crab_pos, crab_count} ->
      abs(crab_pos - to_pos) * crab_count
    end)
    |> Enum.sum()
  end

  defp get_fuel_q2(crabs, to_pos) do
    crabs
    |> Enum.map(fn {crab_pos, crab_count} ->
      dist = abs(crab_pos - to_pos)
      fuel_to_move = div(dist * (dist + 1), 2)
      fuel_to_move * crab_count
    end)
    |> Enum.sum()
  end
end
