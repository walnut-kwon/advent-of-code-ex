# Advent of Code 2021 Day 13 - Transparent Origami
# https://adventofcode.com/2021/day/13
# Commentary: https://walnut-today.tistory.com/55

defmodule Aoc2021.Day13 do
  def parse_input do
    input =
      "input/day13.txt"
      |> File.read!()
      |> String.split("\n")

    points =
      input
      |> Enum.filter(&(Integer.parse(&1) != :error))
      |> Enum.map(fn r ->
        r |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)

    folds =
      input
      |> Enum.filter(&String.starts_with?(&1, "fold"))
      |> Enum.map(fn
        "fold along x=" <> x ->
          {:x, String.to_integer(x)}

        "fold along y=" <> y ->
          {:y, String.to_integer(y)}
      end)

    {points, folds}
  end

  def run_q1() do
    {points, folds} = parse_input()

    fold(points, folds |> hd()) |> length()
  end

  def run_q2() do
    {points, folds} = parse_input()

    last_points =
      folds
      |> Enum.reduce(points, fn fold_axis, acc_points ->
        fold(acc_points, fold_axis)
      end)

    last_fold_x =
      folds |> Enum.filter(&(elem(&1, 0) == :x)) |> Enum.map(&elem(&1, 1)) |> Enum.min()

    last_fold_y =
      folds |> Enum.filter(&(elem(&1, 0) == :y)) |> Enum.map(&elem(&1, 1)) |> Enum.min()

    0..last_fold_y
    |> Enum.map(fn y ->
      0..last_fold_x
      |> Enum.map(fn x ->
        if {x, y} in last_points, do: "#", else: "."
      end)
      |> Enum.join("")
    end)
  end

  defp fold(points, {:x, x_axis}) do
    points
    |> Enum.map(fn
      {x, y} when x < x_axis -> {x, y}
      {x, y} when x > x_axis -> {x_axis - (x - x_axis), y}
    end)
    |> Enum.uniq()
  end

  defp fold(points, {:y, y_axis}) do
    points
    |> Enum.map(fn
      {x, y} when y < y_axis -> {x, y}
      {x, y} when y > y_axis -> {x, y_axis - (y - y_axis)}
    end)
    |> Enum.uniq()
  end
end
