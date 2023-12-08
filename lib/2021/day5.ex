# Advent of Code 2021 Day 5 - Hydrothermal Venture
# https://adventofcode.com/2021/day/5
# Commentary: https://walnut-today.tistory.com/46

defmodule Aoc2021.Day5 do
  def parse_input do
    path = "input/day5.txt"

    File.read!(path)
    |> String.split("\n")
    |> Enum.map(&parse_vent/1)
  end

  defp parse_vent(input_line) do
    input_line
    |> String.split(" -> ")
    |> Enum.map(fn point ->
      point
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  @spec run_q1 :: non_neg_integer
  def run_q1 do
    parse_input()
    |> Enum.reduce(%{}, fn vent, acc ->
      get_points(vent, :q1)
      |> Enum.reduce(acc, fn point, tmp_acc ->
        Map.update(tmp_acc, point, 1, &(&1 + 1))
      end)
    end)
    |> Enum.filter(fn {_k, v} -> v >= 2 end)
    |> Enum.count()
  end

  @spec run_q2 :: non_neg_integer
  def run_q2 do
    parse_input()
    |> Enum.reduce(%{}, fn vent, acc ->
      get_points(vent, :q2)
      |> Enum.reduce(acc, fn point, tmp_acc ->
        Map.update(tmp_acc, point, 1, &(&1 + 1))
      end)
    end)
    |> Enum.filter(fn {_k, v} -> v >= 2 end)
    |> Enum.count()
  end

  @spec get_points({{integer, integer}, {integer, integer}}, :q1 | :q2) ::
          list({integer, integer})
  def get_points({{x1, y}, {x2, y}}, _) do
    get_line(x1, x2) |> Enum.map(&{&1, y})
  end

  def get_points({{x, y1}, {x, y2}}, _) do
    get_line(y1, y2) |> Enum.map(&{x, &1})
  end

  def get_points({{_x1, _y1}, {_x2, _y2}}, :q1) do
    []
  end

  def get_points({{x1, y1}, {x2, y2}}, :q2) do
    Enum.zip(get_line(x1, x2), get_line(y1, y2))
  end

  @spec get_line(integer, integer) :: list
  def get_line(a, b) when a < b, do: a..b |> Enum.to_list()

  def get_line(a, b) when a > b, do: a..b//-1 |> Enum.to_list()
end
