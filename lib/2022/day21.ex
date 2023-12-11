# Advent of Code 2022 Day 21 - Monkey Math
# https://adventofcode.com/2022/day/21
# Commentary: https://walnut-today.tistory.com/225

defmodule Aoc2022.Day21 do
  @dir "data/day21/"

  def q1(file_name \\ "q.txt") do
    build_tree(file_name)
    |> fill_number()
    |> Map.get("root")
  end

  defp build_tree(file_name) do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Map.new(fn line ->
      [left, right] = String.split(line, ": ")

      case String.split(right, " ") do
        [one, operator, two] ->
          {left, %{operator: operator, depends_on: [one, two]}}

        [v] ->
          {left, String.to_integer(v)}
      end
    end)
  end

  defp fill_number(tree, _last_tree \\ nil)

  defp fill_number(tree, tree), do: tree

  defp fill_number(tree, _last_tree) do
    tree
    |> Map.map(fn
      {_k, v} when is_number(v) ->
        v

      {_k, %{depends_on: [one, two], operator: op} = map} ->
        val_one =
          cond do
            is_number(one) -> one
            is_number(tree[one]) -> tree[one]
            true -> one
          end

        val_two =
          cond do
            is_number(two) -> two
            is_number(tree[two]) -> tree[two]
            true -> two
          end

        if is_number(val_one) and is_number(val_two) do
          calc_number(val_one, val_two, op)
        else
          %{map | depends_on: [val_one, val_two]}
        end
    end)
    |> fill_number(tree)
  end

  def q2(file_name \\ "q.txt") do
    tree =
      file_name
      |> build_tree()
      |> Map.delete("humn")

    [root_left, root_right] = tree["root"].depends_on

    fixed_tree = tree |> fill_number()

    [root_left_maybe_value, root_right_maybe_value] = fixed_tree["root"].depends_on

    fixed_tree
    |> inverse_lines()
    |> then(fn v ->
      if is_number(root_left_maybe_value) do
        v |> Map.put(root_right, root_left_maybe_value)
      else
        v |> Map.put(root_left, root_right_maybe_value)
      end
    end)
    |> fill_number()
    |> Map.get("humn")
  end

  defp calc_number(a, b, operator) do
    case operator do
      "+" -> a + b
      "-" -> a - b
      "*" -> a * b
      "/" -> a / b
    end
  end

  defp inverse_lines(lines) do
    lines
    |> Enum.flat_map(fn
      {k, %{depends_on: [a, b], operator: op}} ->
        b_map =
          case op do
            "+" -> %{depends_on: [k, a], operator: "-", type: :b}
            "-" -> %{depends_on: [a, k], operator: "-", type: :b}
            "*" -> %{depends_on: [k, a], operator: "/", type: :b}
            "/" -> %{depends_on: [a, k], operator: "/", type: :b}
          end

        [
          {a, %{depends_on: [k, b], operator: inverse_operator(op), type: :a}},
          {b, b_map}
        ]
        |> Enum.reject(fn {k, _} -> is_number(k) end)
        |> Enum.reject(fn {_, %{depends_on: [a, b]}} -> a == "humn" or b == "humn" end)

      entry ->
        [entry]
    end)
    |> Enum.group_by(fn {k, _v} -> k end, fn {_k, v} -> v end)
    |> Map.map(fn {_k, v} ->
      maybe_number = Enum.find(v, &is_number/1)

      if is_nil(maybe_number) do
        hd(v)
      else
        maybe_number
      end
    end)
  end

  defp inverse_operator(op) do
    case op do
      "+" -> "-"
      "-" -> "+"
      "*" -> "/"
      "/" -> "*"
    end
  end
end
