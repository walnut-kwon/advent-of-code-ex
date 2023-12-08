# Advent of Code 2021 Day 1 - Sonar Sweep
# https://adventofcode.com/2021/day/1
# Commentary: https://walnut-today.tistory.com/42

defmodule Aoc2021.Day1 do
  def parse_input do
    path = "input_day1q1.txt"

    File.read!(path)
    |> String.split("\n")
    |> Enum.map(&String.to_integer/1)
  end

  def run_q1 do
    parse_input()
    |> count_increase()
    |> elem(1)
  end

  def run_q2 do
    parse_input()
    |> Enum.chunk_every(3, 1, :discard)
    |> Enum.map(&Enum.sum/1)
    |> count_increase()
    |> elem(1)
  end

  defp count_increase(numbers) do
    numbers
    |> Enum.reduce(
      {nil, 0},
      fn
        element, {nil, cnt} ->
          {element, cnt}

        element, {before, cnt} ->
          if element > before do
            {element, cnt + 1}
          else
            {element, cnt}
          end
      end
    )
  end
end
