# Advent of Code 2022 Day 18 - Boiling Boulders
# https://adventofcode.com/2022/day/18
# Commentary: https://walnut-today.tistory.com/222

defmodule Aoc2022.Day18 do
  @dir "data/day18/"

  def q1(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn v ->
      String.split(v, ",")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.reduce({MapSet.new(), 0}, fn {a, b, c} = cube, {cubes, sides} ->
      new_cubes = MapSet.put(cubes, cube)

      overlaps =
        [
          MapSet.member?(cubes, {a - 1, b, c}),
          MapSet.member?(cubes, {a + 1, b, c}),
          MapSet.member?(cubes, {a, b - 1, c}),
          MapSet.member?(cubes, {a, b + 1, c}),
          MapSet.member?(cubes, {a, b, c - 1}),
          MapSet.member?(cubes, {a, b, c + 1})
        ]
        |> Enum.filter(&(&1 == true))
        |> length()

      {new_cubes, sides + 6 - 2 * overlaps}
    end)
  end

  def q2(file_name \\ "q.txt") do
    cubes =
      File.read!(@dir <> file_name)
      |> String.split("\n")
      |> Enum.map(fn v ->
        String.split(v, ",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)

    max_x = cubes |> Enum.map(&elem(&1, 0)) |> Enum.max() |> IO.inspect(label: "max_x")
    min_x = cubes |> Enum.map(&elem(&1, 0)) |> Enum.min() |> IO.inspect(label: "min_x")
    max_y = cubes |> Enum.map(&elem(&1, 1)) |> Enum.max() |> IO.inspect(label: "max_y")
    min_y = cubes |> Enum.map(&elem(&1, 1)) |> Enum.min() |> IO.inspect(label: "min_y")
    max_z = cubes |> Enum.map(&elem(&1, 2)) |> Enum.max() |> IO.inspect(label: "max_z")
    min_z = cubes |> Enum.map(&elem(&1, 2)) |> Enum.min() |> IO.inspect(label: "min_z")

    air_pockets =
      min_x..max_x
      |> Enum.flat_map(fn x ->
        min_y..max_y
        |> Enum.flat_map(fn y ->
          min_z..max_z
          |> Enum.filter(fn z -> air_pocket?(cubes, {x, y, z}) end)
          |> Enum.map(fn z -> {x, y, z} end)
        end)
      end)

    air_pocket_input =
      air_pockets
      |> Enum.map(fn {x, y, z} -> "#{x},#{y},#{z}" end)
      |> Enum.join("\n")

    tmp_file_name = "tmp.txt"
    File.write!(@dir <> tmp_file_name, air_pocket_input)

    {_, total_sides} = q1(file_name)
    {_, inner_sides} = q1(tmp_file_name)

    total_sides - inner_sides
  end

  defp air_pocket?(cubes, {x, y, z}) do
    if {x, y, z} in cubes do
      false
    else
      if Enum.any?(cubes, fn {cx, cy, cz} -> cx > x and cy == y and cz == z end) and
           Enum.any?(cubes, fn {cx, cy, cz} -> cx < x and cy == y and cz == z end) and
           Enum.any?(cubes, fn {cx, cy, cz} -> cx == x and cy > y and cz == z end) and
           Enum.any?(cubes, fn {cx, cy, cz} -> cx == x and cy < y and cz == z end) and
           Enum.any?(cubes, fn {cx, cy, cz} -> cx == x and cy == y and cz > z end) and
           Enum.any?(cubes, fn {cx, cy, cz} -> cx == x and cy == y and cz < z end) do
        true
      else
        false
      end
    end
  end
end
