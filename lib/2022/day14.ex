# Advent of Code 2022 Day 14 - Regolith Reservoir
# https://adventofcode.com/2022/day/14
# Commentary: https://walnut-today.tistory.com/218

defmodule Aoc2022.Day14 do
  @dir "data/day14/"

  def q1(file_name \\ "q.txt") do
    file_name
    |> build_cave()
    |> then(fn cave ->
      max_y =
        Enum.max_by(cave, fn {{_x, y}, _v} -> y end)
        |> elem(0)
        |> elem(1)

      min_x =
        Enum.min_by(cave, fn {{x, _y}, _v} -> x end)
        |> elem(0)
        |> elem(0)

      max_x =
        Enum.max_by(cave, fn {{x, _y}, _v} -> x end)
        |> elem(0)
        |> elem(0)

      {:finish, count, last_cave} = pouring_sand(cave, {500, 0}, 0, max_y)

      IO.inspect(count)
      print_cave(last_cave, min_x, max_x, max_y)
    end)
  end

  def q2(file_name \\ "q.txt") do
    file_name
    |> build_cave()
    |> then(fn cave ->
      max_y =
        Enum.max_by(cave, fn {{_x, y}, _v} -> y end)
        |> elem(0)
        |> elem(1)
        |> Kernel.+(2)

      min_x =
        Enum.min_by(cave, fn {{x, _y}, _v} -> x end)
        |> elem(0)
        |> elem(0)

      max_x =
        Enum.max_by(cave, fn {{x, _y}, _v} -> x end)
        |> elem(0)
        |> elem(0)

      cave =
        (min_x - max_y)..(max_x + max_y)
        |> Map.new(fn x -> {{x, max_y}, :rock} end)
        |> Map.merge(cave)

      {:finish, count, last_cave} = pouring_sand(cave, {500, 0}, 0, max_y)

      IO.inspect(count)
      print_cave(last_cave, min_x, max_x, max_y)
    end)
  end

  defp build_cave(file_name) do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.reduce(MapSet.new(), fn rocks, acc ->
      rocks
      |> String.split(" -> ")
      |> Enum.map(fn coord ->
        coord |> String.split(",") |> Enum.map(&String.to_integer/1) |> List.to_tuple()
      end)
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.reduce(MapSet.new(), fn [{x1, y1}, {x2, y2}], path_acc ->
        points =
          if x1 == x2 do
            y1..y2 |> Enum.map(fn y -> {x1, y} end)
          else
            x1..x2 |> Enum.map(fn x -> {x, y1} end)
          end

        points |> MapSet.new() |> MapSet.union(path_acc)
      end)
      |> MapSet.union(acc)
    end)
    |> Map.new(fn v -> {v, :rock} end)
  end

  defp print_cave(cave, min_x, max_x, max_y) do
    0..max_y
    |> Enum.each(fn y ->
      min_x..max_x
      |> Enum.each(fn x ->
        case Map.get(cave, {x, y}) do
          :rock -> IO.write("#")
          :sand -> IO.write("o")
          nil -> IO.write(".")
        end
      end)

      IO.write("\n")
    end)
  end

  defp pouring_sand(cave, {_x, y}, count, y) do
    {:finish, count, cave}
  end

  defp pouring_sand(cave, {x, y}, count, max_y) do
    if blocked?(cave, {x, y + 1}) do
      if blocked?(cave, {x - 1, y + 1}) do
        if blocked?(cave, {x + 1, y + 1}) do
          if blocked?(cave, {x, y}) do
            {:finish, count, cave}
          else
            Map.put(cave, {x, y}, :sand)
            |> pouring_sand({500, 0}, count + 1, max_y)
          end
        else
          pouring_sand(cave, {x + 1, y + 1}, count, max_y)
        end
      else
        pouring_sand(cave, {x - 1, y + 1}, count, max_y)
      end
    else
      pouring_sand(cave, {x, y + 1}, count, max_y)
    end
  end

  defp blocked?(cave, {x, y}) do
    Map.get(cave, {x, y}) in [:rock, :sand]
  end
end
