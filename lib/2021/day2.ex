# Advent of Code 2021 Day 2 - Dive!
# https://adventofcode.com/2021/day/2
# Commentary: https://walnut-today.tistory.com/43

defmodule Aoc2021.Day2 do
  def parse_input do
    path = "input/day2.txt"

    File.read!(path)
    |> String.split("\n")
    |> Enum.map(&parse_command/1)
  end

  # command = "forward 1", "down 2", "up 3", ...
  defp parse_command(command) do
    command
    |> String.split(" ")
    |> List.update_at(1, &String.to_integer/1)
    |> List.to_tuple()
  end

  def run_q1 do
    parse_input()
    |> Enum.reduce({0, 0}, fn
      {"forward", n}, {position, depth} ->
        {position + n, depth}

      {"down", n}, {position, depth} ->
        {position, depth + n}

      {"up", n}, {position, depth} ->
        {position, depth - n}
    end)
    |> then(fn {position, depth} ->
      position * depth
    end)
  end

  def run_q2 do
    parse_input()
    |> Enum.reduce({0, 0, 0}, fn
      {"forward", n}, {position, depth, aim} ->
        {position + n, depth + n * aim, aim}

      {"down", n}, {position, depth, aim} ->
        {position, depth, aim + n}

      {"up", n}, {position, depth, aim} ->
        {position, depth, aim - n}
    end)
    |> then(fn {position, depth, _aim} ->
      position * depth
    end)
  end
end
