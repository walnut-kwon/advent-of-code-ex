# Advent of Code 2021 Day 15 - Chiton
# https://adventofcode.com/2021/day/15
# Commentary: https://walnut-today.tistory.com/57

defmodule Aoc2021.Day15 do
  @map_size_in_q2 5

  def parse_input do
    map =
      "input/day15.txt"
      |> File.read!()
      |> String.split("\n")
      |> Enum.map(fn r ->
        r |> String.codepoints() |> Enum.map(&String.to_integer/1)
      end)

    {map |> nested_list_to_map(), map |> hd() |> length(), map |> length()}
  end

  @spec nested_list_to_map(list(list(non_neg_integer()))) :: %{
          {non_neg_integer(), non_neg_integer()} => {non_neg_integer(), boolean()}
        }
  defp nested_list_to_map(nested_list) do
    nested_list
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {val, col_index} ->
        {{row_index, col_index}, val}
      end)
    end)
    |> Enum.into(%{})
  end

  def run_q1() do
    {map, w, h} = parse_input()

    initial_point = {0, 0}
    visited_points = %{initial_point => true}
    risk = 0
    min_risk = %{}

    step({map, w, h}, [{initial_point, visited_points, risk}], min_risk, :q1)
  end

  def run_q2() do
    {map, w, h} = parse_input()

    initial_point = {0, 0}
    visited_points = %{initial_point => true}
    risk = 0
    min_risk = %{}

    step({map, w, h}, [{initial_point, visited_points, risk}], min_risk, :q2)
  end

  defp step({_map, w, h}, [{{current_x, current_y}, path, risk} | _], _min_risk, :q1)
       when w - 1 == current_x and h - 1 == current_y do
    {path, risk}
  end

  defp step({_map, w, h}, [{{current_x, current_y}, path, risk} | _], _min_risk, :q2)
       when w * @map_size_in_q2 - 1 == current_x and h * @map_size_in_q2 - 1 == current_y do
    {path, risk}
  end

  defp step({map, w, h}, candidates, min_risk, q) do
    new_candidates =
      Enum.flat_map(candidates, fn c ->
        do_step({map, w, h}, c, q)
      end)
      |> Enum.sort_by(fn c -> elem(c, 2) end, :asc)
      |> prune(min_risk)

    new_min_risk =
      new_candidates
      |> Enum.reduce(min_risk, fn {c, _p, r}, acc ->
        Map.update(acc, c, r, &min(&1, r))
      end)

    step({map, w, h}, new_candidates, new_min_risk, q)
  end

  defp do_step({map, w, h}, {current_point, visited_points, risk}, q) do
    current_x = current_point |> elem(0)
    current_y = current_point |> elem(1)

    []
    # up
    |> prepend_list({map, w, h}, {current_x, current_y - 1}, visited_points, q)
    # down
    |> prepend_list({map, w, h}, {current_x, current_y + 1}, visited_points, q)
    # left
    |> prepend_list({map, w, h}, {current_x - 1, current_y}, visited_points, q)
    # right
    |> prepend_list({map, w, h}, {current_x + 1, current_y}, visited_points, q)
    |> Enum.map(fn candidate ->
      {candidate, Map.put_new(visited_points, candidate, true),
       risk + risk_of_point({map, w, h}, candidate, q)}
    end)
  end

  defp prune(candidates, min_risk) do
    candidates
    |> Enum.uniq_by(fn {current_point, _, _} -> current_point end)
    |> Enum.reject(fn {point, _, risk} ->
      Map.get(min_risk, point, nil) < risk
    end)
  end

  defp prepend_list(list, {_map, w, h}, {next_x, next_y}, _, :q1)
       when next_x < 0 or next_x >= w or next_y < 0 or next_y >= h do
    list
  end

  defp prepend_list(list, {_map, w, h}, {next_x, next_y}, _, :q2)
       when next_x < 0 or
              next_x >= w * @map_size_in_q2 or
              next_y < 0 or
              next_y >= h * @map_size_in_q2 do
    list
  end

  defp prepend_list(list, _, {next_x, next_y}, visited_points, _q) do
    if Map.has_key?(visited_points, {next_x, next_y}) do
      list
    else
      [{next_x, next_y} | list]
    end
  end

  defp risk_of_point({map, _w, _h}, {x, y}, :q1) do
    Map.get(map, {y, x})
  end

  defp risk_of_point({map, w, h}, {x, y}, :q2) do
    x_offset = div(x, w)
    y_offset = div(y, h)

    (risk_of_point({map, w, h}, {rem(x, w), rem(y, h)}, :q1) + x_offset + y_offset)
    |> Kernel.then(fn
      v when v > 9 -> v - 9
      v -> v
    end)
  end
end
