# Advent of Code 2022 Day 8 - Treetop Tree House
# https://adventofcode.com/2022/day/8
# Commentary: https://walnut-today.tistory.com/212

defmodule Aoc2022.Day8 do
  @dir "data/day8/"

  def q1(file_name \\ "q.txt") do
    row_size = 99
    col_size = 99

    grid = parse_grid(file_name)

    0..(row_size - 1)
    |> Enum.flat_map(fn i ->
      0..(col_size - 1)
      |> Enum.map(fn j ->
        if i in 1..(row_size - 2) and j in 1..(col_size - 2) do
          {row_left, row_right} = get_row(grid, i, j)
          {col_up, col_down} = get_col(grid, j, i)

          {{i, j},
           any_big_element?(row_left, grid[{i, j}]) and
             any_big_element?(row_right, grid[{i, j}]) and
             any_big_element?(col_up, grid[{i, j}]) and
             any_big_element?(col_down, grid[{i, j}])}
        else
          {{i, j}, false}
        end
      end)
    end)
    |> Enum.into(%{})
    |> Enum.filter(fn {_, v} -> v == false end)
    |> length
  end

  def q2(file_name \\ "q.txt") do
    row_size = 99
    col_size = 99

    grid = parse_grid(file_name)

    0..(row_size - 1)
    |> Enum.flat_map(fn i ->
      0..(col_size - 1)
      |> Enum.map(fn j ->
        if i in 1..(row_size - 2) and j in 1..(col_size - 2) do
          {row_left, row_right} = get_row(grid, i, j)
          {col_up, col_down} = get_col(grid, j, i)

          left_dist =
            viewing_distance(Enum.sort_by(row_left, fn {{_, c}, _} -> c end, :desc), grid[{i, j}])

          right_dist =
            viewing_distance(Enum.sort_by(row_right, fn {{_, c}, _} -> c end), grid[{i, j}])

          up_dist =
            viewing_distance(Enum.sort_by(col_up, fn {{r, _}, _} -> r end, :desc), grid[{i, j}])

          down_dist =
            viewing_distance(Enum.sort_by(col_down, fn {{r, _}, _} -> r end), grid[{i, j}])

          {{i, j}, left_dist * right_dist * up_dist * down_dist}
        else
          {{i, j}, 0}
        end
      end)
    end)
    |> Enum.into(%{})
    |> Map.values()
    |> Enum.max()
  end

  defp parse_grid(file_name) do
    File.read!(@dir <> file_name)
    |> String.split("\n", trim: true)
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      String.graphemes(row)
      |> Enum.with_index()
      |> Enum.map(fn {col, j} ->
        {{i, j}, col}
      end)
    end)
    |> Enum.into(%{})
  end

  defp get_row(grid, row_num, split_col_num) do
    grid
    |> Map.delete({row_num, split_col_num})
    |> Enum.filter(fn {{i, _}, _} -> row_num == i end)
    |> Enum.split_with(fn {{_, j}, _} -> j <= split_col_num end)
    |> then(fn {a, b} ->
      {Enum.into(a, %{}), Enum.into(b, %{})}
    end)
  end

  defp get_col(grid, col_num, split_row_num) do
    grid
    |> Map.delete({split_row_num, col_num})
    |> Enum.filter(fn {{_, j}, _} -> col_num == j end)
    |> Enum.split_with(fn {{i, _}, _} -> i <= split_row_num end)
    |> then(fn {a, b} ->
      {Enum.into(a, %{}), Enum.into(b, %{})}
    end)
  end

  defp any_big_element?(line, compare_to) do
    Enum.any?(line, fn {_, v} -> v >= compare_to end)
  end

  defp viewing_distance(sorted_line, compare_to) do
    Enum.reduce_while(sorted_line, 0, fn {_, v}, acc ->
      cond do
        v < compare_to -> {:cont, acc + 1}
        v == compare_to -> {:halt, acc + 1}
        true -> {:halt, acc + 1}
      end
    end)
  end
end
