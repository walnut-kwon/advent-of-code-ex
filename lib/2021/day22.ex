# Advent of Code 2021 Day 22 - Reactor Reboot
# https://adventofcode.com/2021/day/22
# Commentary: https://walnut-today.tistory.com/65

defmodule Aoc2021.Day22 do
  defmodule Cuboid do
    defstruct [:x, :y, :z]
  end

  def parse_input(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn
      "on " <> coords ->
        [x, y, z] = coords |> String.split(",") |> Enum.map(&parse_axis/1)
        {:on, %Cuboid{x: x, y: y, z: z}}

      "off " <> coords ->
        [x, y, z] = coords |> String.split(",") |> Enum.map(&parse_axis/1)
        {:off, %Cuboid{x: x, y: y, z: z}}
    end)
    |> IO.inspect()
  end

  defp parse_axis(axis) do
    [s, e] =
      axis
      |> String.split("=")
      |> Enum.at(1)
      |> String.split("..")
      |> Enum.map(&String.to_integer/1)

    s..e
  end

  def run_q1(file_name \\ "input/day22.txt") do
    initial_reactor = %{}

    parse_input(file_name)
    |> Enum.reduce(initial_reactor, fn
      {:on, cuboid}, acc ->
        with %Cuboid{x: x_range, y: y_range, z: z_range} <- in_init_area?(cuboid) do
          x_range
          |> Enum.reduce(acc, fn x, x_acc ->
            y_range
            |> Enum.reduce(x_acc, fn y, y_acc ->
              z_range
              |> Enum.reduce(y_acc, fn z, z_acc ->
                z_acc
                |> Map.put({x, y, z}, :on)
              end)
            end)
          end)
        else
          false -> acc
        end
        |> tap(fn map -> IO.inspect(map_size(map), label: "map size") end)

      {:off, cuboid}, acc ->
        with %Cuboid{x: x_range, y: y_range, z: z_range} <- in_init_area?(cuboid) do
          x_range
          |> Enum.reduce(acc, fn x, x_acc ->
            y_range
            |> Enum.reduce(x_acc, fn y, y_acc ->
              z_range
              |> Enum.reduce(y_acc, fn z, z_acc ->
                z_acc
                |> Map.delete({x, y, z})
              end)
            end)
          end)
        else
          false -> acc
        end
    end)
    |> map_size()
  end

  def run_q2(file_name \\ "input/day22.txt") do
    cubes = []

    file_name
    |> parse_input()
    # |> Enum.filter(fn {_, cube} -> in_init_area?(cube) != false end)
    |> Enum.reduce(cubes, fn
      {:on, new_cube}, acc_cubes ->
        acc_cubes
        |> Enum.flat_map(fn old_cube ->
          if overlap?(old_cube, new_cube) do
            split_first(old_cube, new_cube)
            |> Enum.reject(&overlap?(&1, new_cube))
          else
            [old_cube]
          end
        end)
        |> then(fn cubes -> [new_cube | cubes] end)

      {:off, new_cube}, acc_cubes ->
        acc_cubes
        |> Enum.flat_map(fn old_cube ->
          if overlap?(old_cube, new_cube) do
            split_first(old_cube, new_cube)
            |> Enum.reject(&overlap?(&1, new_cube))
          else
            [old_cube]
          end
        end)
    end)
    |> Enum.map(fn %Cuboid{x: x, y: y, z: z} -> Range.size(x) * Range.size(y) * Range.size(z) end)
    |> Enum.sum()
  end

  defp in_init_area?(%Cuboid{
         x: x_s..x_e = x_range,
         y: y_s..y_e = y_range,
         z: z_s..z_e = z_range
       }) do
    initialization_area = -50..50

    if Range.disjoint?(initialization_area, x_range) or
         Range.disjoint?(initialization_area, y_range) or
         Range.disjoint?(initialization_area, z_range) do
      false
    else
      x_s = if x_s < -50, do: -50, else: x_s
      x_e = if x_e > 50, do: 50, else: x_e
      y_s = if y_s < -50, do: -50, else: y_s
      y_e = if y_e > 50, do: 50, else: y_e
      z_s = if z_s < -50, do: -50, else: z_s
      z_e = if z_e > 50, do: 50, else: z_e

      %Cuboid{x: x_s..x_e, y: y_s..y_e, z: z_s..z_e}
    end
  end

  # splits first argument
  defp split_first(old_cube, new_cube) do
    %Cuboid{}
    |> Map.from_struct()
    |> Map.keys()
    |> Enum.map(fn key ->
      if Range.disjoint?(Map.get(old_cube, key), Map.get(new_cube, key)) do
        [Map.get(old_cube, key)]
      else
        s1..e1 = Map.get(old_cube, key)
        s2..e2 = Map.get(new_cube, key)

        cond do
          # new cube가 포함하는 경우
          s2 <= s1 and e1 <= e2 -> [s1..e1]
          # old cube가 포함하는 경우
          s1 < s2 and e2 < e1 -> [s1..(s2 - 1), s2..e2, (e2 + 1)..e1]
          # 왼쪽으로 겹쳐 있는 경우
          e2 < e1 -> [s1..e2, (e2 + 1)..e1]
          # 오른쪽으로 겹쳐 있는 경우
          s1 < s2 -> [s1..(s2 - 1), s2..e1]
        end
      end
    end)
    |> permutation3()
  end

  defp overlap?(%Cuboid{x: x1, y: y1, z: z1}, %Cuboid{x: x2, y: y2, z: z2}) do
    Range.disjoint?(x1, x2) == false and Range.disjoint?(y1, y2) == false and
      Range.disjoint?(z1, z2) == false
  end

  def permutation3([list1, list2, list3]) do
    Enum.flat_map(list1, fn v1 ->
      Enum.flat_map(list2, fn v2 ->
        Enum.map(list3, fn v3 -> %Cuboid{x: v1, y: v2, z: v3} end)
      end)
    end)
  end
end
