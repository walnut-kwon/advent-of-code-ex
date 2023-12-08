# Advent of Code 2021 Day 18 - Snailfish
# https://adventofcode.com/2021/day/18
# Commentary: https://walnut-today.tistory.com/61

defmodule Aoc2021.Day18 do
  @explode_depth 4
  def parse_input(file_name \\ "input/day18.txt") do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn line -> line |> Code.eval_string() |> elem(0) end)
  end

  def run_q1() do
    parse_input()
    |> Enum.reduce(fn element, acc ->
      [acc, element]
      # |> IO.inspect()
      |> calculate()
    end)
    # |> IO.inspect(charlists: :as_lists)
    |> magnitude()
  end

  def run_q2() do
    pairs = parse_input()

    Enum.map(pairs, fn x ->
      Enum.map(pairs, fn
        ^x -> 0
        y -> [x, y] |> calculate() |> magnitude()
      end)
      |> Enum.max()
    end)
    |> Enum.max()
  end

  defp calculate(pairs) do
    explodable_path = find_explodable(pairs)

    if not is_nil(explodable_path) do
      explode(pairs, explodable_path)
      |> calculate()
    else
      splittable_path = find_splittable(pairs)

      if not is_nil(splittable_path) do
        split(pairs, splittable_path)
        |> calculate()
      else
        pairs
      end
    end
  end

  def explode(pairs, path) when length(path) >= @explode_depth do
    access_path = path |> Enum.map(&Access.at/1)

    [a, b] = pairs |> get_in(access_path)

    indexed_path = path |> Enum.with_index() |> Enum.reverse()

    first_left_depth =
      indexed_path
      |> Enum.find({nil, nil}, &(elem(&1, 0) == 1))
      |> elem(1)

    first_left_access_path =
      if not is_nil(first_left_depth) do
        Enum.slice(path, 0, first_left_depth)
        |> Kernel.++([0])
        |> then(&find_child(pairs, &1, :rightmost))
        |> Enum.map(&Access.at/1)
      else
        nil
      end

    first_right_depth =
      indexed_path
      |> Enum.find({nil, nil}, &(elem(&1, 0) == 0))
      |> elem(1)

    first_right_access_path =
      if not is_nil(first_right_depth) do
        Enum.slice(path, 0, first_right_depth)
        |> Kernel.++([1])
        |> then(&find_child(pairs, &1, :leftmost))
        |> Enum.map(&Access.at/1)
      else
        nil
      end

    pairs
    |> update_in(access_path, fn _ -> 0 end)
    |> update(first_left_access_path, fn v -> v + a end)
    |> update(first_right_access_path, fn v -> v + b end)
  end

  def split(pairs, path) do
    access_path = path |> Enum.map(&Access.at/1)
    # pairs |> get_in(access_path) |> IO.inspect()
    pairs |> update_in(access_path, fn v -> [div(v, 2), round(v / 2)] end)
  end

  def update(pairs, path, _func) when is_nil(path), do: pairs
  def update(pairs, path, func), do: pairs |> update_in(path, func)

  # mode = :leftmost, :rightmost
  defp find_child(pairs, path, mode) do
    access_path = path |> Enum.map(&Access.at/1)

    if is_integer(pairs |> get_in(access_path)) do
      path
    else
      if mode == :rightmost do
        find_child(pairs, path ++ [1], mode)
      else
        find_child(pairs, path ++ [0], mode)
      end
    end
  end

  def find_explodable(pairs, path \\ []) do
    access_path = path |> Enum.map(&Access.at/1)

    value =
      if path != [] do
        get_in(pairs, access_path)
      else
        :empty_path
      end

    cond do
      value |> is_integer() ->
        false

      value |> is_list() and length(path) >= 4 ->
        path

      value == :empty_path or value |> is_list() ->
        left_explodable_path = find_explodable(pairs, path ++ [0])
        right_explodable_path = find_explodable(pairs, path ++ [1])

        cond do
          left_explodable_path |> is_list() -> left_explodable_path
          right_explodable_path |> is_list() -> right_explodable_path
          true -> nil
        end
    end
  end

  def find_splittable(pairs, path \\ []) do
    access_path = path |> Enum.map(&Access.at/1)

    value =
      if path != [] do
        get_in(pairs, access_path)
      else
        :empty_path
      end

    cond do
      value |> is_integer() and value >= 10 ->
        path

      value |> is_integer() ->
        nil

      value == :empty_path or value |> is_list() ->
        left_splittable_path = find_splittable(pairs, path ++ [0])
        right_splittable_path = find_splittable(pairs, path ++ [1])

        cond do
          left_splittable_path |> is_list() -> left_splittable_path
          right_splittable_path |> is_list() -> right_splittable_path
          true -> nil
        end
    end
  end

  defp magnitude(value) when is_integer(value), do: value

  defp magnitude([a, b]) do
    3 * magnitude(a) + 2 * magnitude(b)
  end
end
