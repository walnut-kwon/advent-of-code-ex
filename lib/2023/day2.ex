# Advent of Code 2023 Day 2 - Cube Conundrum
# https://adventofcode.com/2023/day/2

defmodule Aoc2023.Day2 do
  @dir "input/2023/"

  def q1(file_name \\ "day2.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Map.new(&parse_game/1)
    |> Map.filter(&part1_possible?/1)
    |> Map.keys()
    |> Enum.sum()
  end

  def q2(file_name \\ "day2.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Map.new(&parse_game/1)
    |> Enum.map(&power_of_cubes/1)
    |> Enum.sum()
  end

  defp parse_game("Game " <> game_str) do
    [id, tries_str] = String.split(game_str, ": ")

    tries =
      tries_str
      |> String.split("; ")
      |> Enum.map(fn tri_str ->
        Regex.scan(~r/(([0-9]+) (red|green|blue))+/, tri_str)
        |> Enum.reduce({0, 0, 0}, fn [_, _, num, color], {r, g, b} ->
          case color do
            "red" -> {String.to_integer(num), g, b}
            "green" -> {r, String.to_integer(num), b}
            "blue" -> {r, g, String.to_integer(num)}
          end
        end)
      end)

    {String.to_integer(id), tries}
  end

  defp part1_possible?({_id, tries}) do
    Enum.all?(tries, fn {r, g, b} -> r <= 12 and g <= 13 and b <= 14 end)
  end

  defp power_of_cubes({_id, tries}) do
    # This calculating-power part can be included in `Enum.reduce/3` of `parse_game/1`
    # but explicitly separated, considering role of each function
    Enum.reduce(tries, {0, 0, 0}, fn {r, g, b}, {max_r, max_g, max_b} ->
      {max(r, max_r), max(g, max_g), max(b, max_b)}
    end)
    |> then(fn {r, g, b} ->
      r * g * b
    end)
  end
end
