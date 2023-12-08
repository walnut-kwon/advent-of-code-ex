# Advent of Code 2021 Day 10 - Syntax Scoring
# https://adventofcode.com/2021/day/10
# Commentary: https://walnut-today.tistory.com/51

defmodule Aoc2021.Day10 do
  @opening ["(", "[", "{", "<"]
  @closing [")", "]", "}", ">"]

  def parse_input do
    path = "input/day10.txt"

    File.read!(path)
    |> String.split("\n")
  end

  @spec parse_line(String.t()) :: {:incomplete | :corrupt, non_neg_integer()}
  def parse_line(line) do
    line
    |> String.codepoints()
    |> Enum.reduce_while([], fn
      par, acc when par in @opening ->
        {:cont, [par | acc]}

      ")", ["(" | acc_t] ->
        {:cont, acc_t}

      "]", ["[" | acc_t] ->
        {:cont, acc_t}

      "}", ["{" | acc_t] ->
        {:cont, acc_t}

      ">", ["<" | acc_t] ->
        {:cont, acc_t}

      par, acc ->
        {:halt, [par | acc]}
    end)
    |> incomplete_or_corrupt()
  end

  @spec run_q1 :: non_neg_integer()
  def run_q1 do
    parse_input()
    |> Enum.map(&parse_line/1)
    |> Enum.filter(fn tuple -> elem(tuple, 0) == :corrupt end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  @spec run_q2 :: non_neg_integer()
  def run_q2 do
    parse_input()
    |> Enum.map(&parse_line/1)
    |> Enum.filter(fn tuple -> elem(tuple, 0) == :incomplete end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sort()
    |> then(fn scores ->
      size = length(scores)

      Enum.drop(scores, div(size, 2))
    end)
    |> List.first()
  end

  defp incomplete_or_corrupt([h | _] = acc) when h in @opening do
    score =
      acc
      |> Enum.reduce(0, fn c, acc ->
        acc * 5 + score_incomplete(c)
      end)

    {:incomplete, score}
  end

  defp incomplete_or_corrupt([acc | _]) when acc in @closing do
    {:corrupt, score_corrupt(acc)}
  end

  defp score_corrupt(")"), do: 3
  defp score_corrupt("]"), do: 57
  defp score_corrupt("}"), do: 1197
  defp score_corrupt(">"), do: 25137

  defp score_incomplete("("), do: 1
  defp score_incomplete("["), do: 2
  defp score_incomplete("{"), do: 3
  defp score_incomplete("<"), do: 4
end
