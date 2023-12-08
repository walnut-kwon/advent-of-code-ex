# Advent of Code 2021 Day 9 - Smoke Basin
# https://adventofcode.com/2021/day/9
# Commentary: https://walnut-today.tistory.com/50

defmodule Aoc2021.Day9 do
  def parse_input do
    path = "input/day9.txt"

    File.read!(path)
    |> String.split("\n")
    |> Enum.map(fn row ->
      row
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
      |> Enum.with_index()
      |> Enum.map(fn {v, i} -> {i, v} end)
      |> Enum.into(%{})
    end)
    |> Enum.with_index()
    |> Enum.map(fn {r, i} -> {i, r} end)
    |> Enum.into(%{})
  end

  def run_q1 do
    map = parse_input()

    map
    |> low_points()
    |> Enum.map(fn {row_index, col_index} -> map[row_index][col_index] end)
    |> Enum.map(&(&1 + 1))
    |> Enum.sum()
  end

  defp low_points(map) do
    row_max_index = map_size(map) - 1

    0..row_max_index
    |> Enum.reduce([], fn row_index, acc ->
      col_max_index = map_size(map[row_index]) - 1

      0..col_max_index
      |> Enum.reduce(acc, fn col_index, row_acc ->
        curr = map[row_index][col_index]

        cond do
          # top
          row_index != 0 and map[row_index - 1][col_index] <= curr ->
            row_acc

          # bottom
          row_index != row_max_index and map[row_index + 1][col_index] <= curr ->
            row_acc

          # left
          col_index != 0 and map[row_index][col_index - 1] <= curr ->
            row_acc

          # right
          col_index != col_max_index and map[row_index][col_index + 1] <= curr ->
            row_acc

          true ->
            [{row_index, col_index} | row_acc]
        end
      end)
    end)
  end

  def run_q2 do
    map = parse_input()

    low_points = low_points(map)

    low_points
    |> Enum.reduce([], fn {row_index, col_index}, basins ->
      basin_points = bfs(map, row_index, col_index)

      [basin_points | basins]
    end)
    |> Enum.map(&length(&1))
    |> Enum.sort(:desc)
    |> Enum.take(3)
    |> Enum.product()
  end

  defp bfs(map, row_index, col_index) do
    do_bfs(map, [], [{row_index, col_index}])
  end

  defp do_bfs(_map, res, []) do
    res
  end

  defp do_bfs(map, res, [{row_index, col_index} = h | t]) do
    new_points = []

    # top
    new_points =
      if row_index != 0 and map[row_index - 1][col_index] != 9 and
           {row_index - 1, col_index} not in res and
           {row_index - 1, col_index} not in t and
           map[row_index - 1][col_index] > map[row_index][col_index] do
        new_points ++ [{row_index - 1, col_index}]
      else
        new_points
      end

    # bot
    new_points =
      if row_index != map_size(map) - 1 and map[row_index + 1][col_index] != 9 and
           {row_index + 1, col_index} not in res and
           {row_index + 1, col_index} not in t and
           map[row_index + 1][col_index] > map[row_index][col_index] do
        new_points ++ [{row_index + 1, col_index}]
      else
        new_points
      end

    # left
    new_points =
      if col_index != 0 and map[row_index][col_index - 1] != 9 and
           {row_index, col_index - 1} not in res and
           {row_index, col_index - 1} not in t and
           map[row_index][col_index - 1] > map[row_index][col_index] do
        new_points ++ [{row_index, col_index - 1}]
      else
        new_points
      end

    # right
    new_points =
      if col_index != map_size(map[row_index]) - 1 and map[row_index][col_index + 1] != 9 and
           {row_index, col_index + 1} not in res and
           {row_index, col_index - 1} not in t and
           map[row_index][col_index + 1] > map[row_index][col_index] do
        new_points ++ [{row_index, col_index + 1}]
      else
        new_points
      end

    # IO.inspect(res)
    # IO.inspect(new_points, label: "new_points")
    do_bfs(map, [h | res], t ++ new_points)
  end
end
