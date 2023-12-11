# Advent of Code 2022 Day 12 - Hill Climbing Algorithm
# https://adventofcode.com/2022/day/12
# Commentary: https://walnut-today.tistory.com/216

defmodule Aoc2022.Day12 do
  @dir "data/day12/"

  defmodule Point do
    defstruct [:elevation, :min_step]
  end

  def q1(file_name \\ "q.txt") do
    {grid, max_x, max_y} =
      file_name
      |> parse_grid

    # s_position = grid |> Enum.find(fn {_, c} -> c == 'S' end)
    e_position = grid |> Enum.find(fn {_, %Point{elevation: e}} -> e == ?E end) |> elem(0)

    grid
    |> normalize_grid
    |> run(0, e_position, max_x, max_y)
  end

  def q2(file_name \\ "q.txt") do
    {grid, max_x, max_y} =
      file_name
      |> parse_grid

    e_position = grid |> Enum.find(fn {_, %Point{elevation: e}} -> e == ?E end) |> elem(0)

    grid
    |> normalize_grid(true)
    |> run(0, e_position, max_x, max_y)
  end

  defp parse_grid(file_name) do
    lines =
      File.read!(@dir <> file_name)
      |> String.split("\n")

    grid =
      lines
      |> Enum.with_index()
      |> Enum.flat_map(fn {line, y} ->
        line
        |> String.to_charlist()
        |> Enum.with_index()
        |> Enum.map(fn {c, x} -> {{x, y}, %Point{elevation: c}} end)
      end)
      |> Enum.into(%{})

    {grid, hd(lines) |> String.length(), length(lines)}
  end

  defp normalize_grid(grid, all_a_is_start? \\ false) do
    grid
    |> Enum.map(fn
      {coord, %Point{elevation: ?E} = p} ->
        {coord, %{p | elevation: ?z}}

      {coord, %Point{elevation: ?S} = p} ->
        {coord, %{p | elevation: ?a, min_step: 0}}

      {coord, %Point{elevation: ?a} = p} ->
        if all_a_is_start? do
          {coord, %{p | elevation: ?a, min_step: 0}}
        else
          {coord, p}
        end

      p ->
        p
    end)
    |> Enum.into(%{})
  end

  defp run(grid, step_count, end_position, max_x, max_y) do
    if is_integer(grid[end_position].min_step) do
      grid[end_position].min_step
    else
      new_points =
        grid
        |> Enum.filter(fn {_coord, %Point{min_step: min_step}} -> min_step == step_count end)
        |> Enum.flat_map(fn {coord, %Point{elevation: e}} ->
          adjecent_points(coord, max_x, max_y)
          |> Enum.filter(fn {x, y} ->
            grid[{x, y}].elevation <= e + 1 and is_nil(grid[{x, y}].min_step)
          end)
          |> Enum.map(fn {x, y} ->
            {{x, y}, %Point{grid[{x, y}] | min_step: step_count + 1}}
          end)
        end)
        |> Enum.into(%{})

      if new_points == %{} do
        {:error, grid, step_count, end_position}
      else
        Map.merge(grid, new_points)
        |> run(step_count + 1, end_position, max_x, max_y)
      end
    end
  end

  defp adjecent_points({x, y}, max_x, max_y) do
    [
      {x, y - 1},
      {x - 1, y},
      {x + 1, y},
      {x, y + 1}
    ]
    |> Enum.reject(fn {x, y} -> x < 0 or y < 0 or x >= max_x or y >= max_y end)
  end
end
