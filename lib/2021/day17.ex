# Advent of Code 2021 Day 17 - Trick Shot
# https://adventofcode.com/2021/day/17
# Commentary: https://walnut-today.tistory.com/60

defmodule Aoc2021.Day17 do
  def parse_input(file_name \\ "input/day17.txt") do
    file_name
    |> File.read!()
    |> String.trim_leading("target area: ")
    |> String.split(", ")
    |> Enum.map(fn range ->
      [s, e] =
        range
        |> String.slice(2..-1//1)
        |> String.split("..")
        |> Enum.map(&String.to_integer/1)
        |> Enum.sort()

      Range.new(s, e)
    end)
    |> List.to_tuple()
  end

  def run_q1() do
    {x_s..x_e, y_s..y_e} = parse_input()

    initial_y_velocity = 0
    min_x_velocity = find_min_x_velocity(x_s..x_e)
    {max_y_velocity, _} = step({x_s..x_e, y_s..y_e}, min_x_velocity, initial_y_velocity, 0)

    {max_y_velocity, max_y_velocity * (max_y_velocity + 1) / 2}
  end

  def run_q2() do
    {x_s..x_e, y_s..y_e} = parse_input()

    initial_y_velocity = y_s
    min_x_velocity = find_min_x_velocity(x_s..x_e)

    {_, candidate_count} = step({x_s..x_e, y_s..y_e}, min_x_velocity, initial_y_velocity, 0)

    candidate_count
  end

  defp step({_, y_s..y_e} = target, min_x_velocity, y_velocity, candidate_count) do
    result =
      simulate(target, min_x_velocity, y_velocity)
      |> Enum.reject(&(&1 == :never_reached))

    cond do
      Enum.any?(result, &(&1 == true)) ->
        feasibles = Enum.count(result, &(&1 == true))
        step(target, min_x_velocity, y_velocity + 1, candidate_count + feasibles)

      # y 영역이 모두 음수 지역에 있는데, 쏜 드론은 항상 y=0을 지남
      # 따라서 y 영역의 절대값이 큰 지점보다 속도가 빠른 경우 항상 지나침
      Enum.any?(result, &(&1 == :not_reached)) and
        y_velocity < abs(y_s) and y_velocity < abs(y_e) ->
        step(target, min_x_velocity, y_velocity + 1, candidate_count)

      Enum.all?(result, &(&1 == :over_reached)) ->
        {y_velocity - 1, candidate_count}

      true ->
        {y_velocity - 1, candidate_count}
    end
  end

  defp simulate({x_s..x_e, y_s..y_e}, min_x_velocity, y_velocity) do
    min_x_velocity..x_e
    |> Enum.map(fn x_velocity ->
      in_target_area?({x_s..x_e, y_s..y_e}, x_velocity, y_velocity)
    end)
  end

  defp find_min_x_velocity(x_s.._x_e) do
    0..x_s |> Enum.find_index(fn x_vel -> x_vel * (x_vel + 1) / 2 > x_s end)
  end

  defp x_velocity_step(x) when x > 0, do: x - 1
  defp x_velocity_step(x) when x < 0, do: x + 1
  defp x_velocity_step(0), do: 0

  defp in_target_area?({x_s..x_e, y_s..y_e}, x_velocity, y_velocity, with_log? \\ false) do
    Stream.iterate({x_velocity, y_velocity}, fn {x, y} -> {x_velocity_step(x), y - 1} end)
    |> Enum.reduce_while({0, 0}, fn {x_vel, y_vel}, {x, y} ->
      new_x = x + x_vel
      new_y = y + y_vel

      if with_log? do
        IO.inspect({new_x, new_y},
          label: "x=#{x_velocity}, y=#{y_velocity}, target=#{inspect({x_s..x_e, y_s..y_e})}"
        )
      end

      cond do
        new_x <= x_s and new_y < y_s and x_vel == 0 -> {:halt, :never_reached}
        new_x <= x_e and new_y < y_s -> {:halt, :not_reached}
        new_x > x_e -> {:halt, :over_reached}
        new_x in x_s..x_e and new_y in y_s..y_e -> {:halt, true}
        true -> {:cont, {new_x, new_y}}
      end
    end)
  end
end
