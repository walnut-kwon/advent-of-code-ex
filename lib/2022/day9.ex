# Advent of Code 2022 Day 9 - Rope Bridge
# https://adventofcode.com/2022/day/9
# Commentary: https://walnut-today.tistory.com/213

defmodule Aoc2022.Day9 do
  @dir "data/day9/"

  defmodule Trace do
    defstruct head: {0, 0}, tail: {0, 0}, visit: MapSet.new()
  end

  defmodule Trace2 do
    defstruct knots: List.duplicate({0, 0}, 10), visit: MapSet.new()
  end

  def q1(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.flat_map(fn move ->
      String.split(move, " ")
      |> then(fn [dir, cnt] -> List.duplicate(dir, String.to_integer(cnt)) end)
    end)
    |> Enum.reduce(%Trace{}, fn
      dir, %Trace{head: {x_h, y_h}, tail: {x_t, y_t} = t, visit: v} = acc ->
        new_head =
          case dir do
            "R" -> {x_h + 1, y_h}
            "L" -> {x_h - 1, y_h}
            "D" -> {x_h, y_h - 1}
            "U" -> {x_h, y_h + 1}
          end

        new_tail =
          case relative_pos(new_head, t) do
            {:same, true} -> t
            {_, true} -> t
            {:head_is_right, _} -> {x_t + 1, y_t}
            {:head_is_up_right, _} -> {x_t + 1, y_t + 1}
            {:head_is_down_right, _} -> {x_t + 1, y_t - 1}
            {:head_is_up, _} -> {x_t, y_t + 1}
            {:head_is_down, _} -> {x_t, y_t - 1}
            {:head_is_left, _} -> {x_t - 1, y_t}
            {:head_is_up_left, _} -> {x_t - 1, y_t + 1}
            {:head_is_down_left, _} -> {x_t - 1, y_t - 1}
          end

        %{acc | head: new_head, tail: new_tail, visit: MapSet.put(v, new_tail)}
        |> tap(fn v -> Map.take(v, [:head, :tail]) |> IO.inspect() end)
    end)
    |> Map.get(:visit)
    |> MapSet.size()
  end

  def q2(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.flat_map(fn move ->
      String.split(move, " ")
      |> then(fn [dir, cnt] -> List.duplicate(dir, String.to_integer(cnt)) end)
    end)
    |> Enum.reduce(%Trace2{}, fn
      dir, %Trace2{knots: [{x_h, y_h} | _] = knots, visit: v} = acc ->
        new_head =
          case dir do
            "R" -> {x_h + 1, y_h}
            "L" -> {x_h - 1, y_h}
            "D" -> {x_h, y_h - 1}
            "U" -> {x_h, y_h + 1}
          end

        new_knots_reversed =
          Enum.reduce(tl(knots), [new_head], fn {x_t, y_t} = t, [h | _] = knot_acc ->
            new_tail =
              case relative_pos(h, t) do
                {:same, true} -> t
                {_, true} -> t
                {:head_is_right, _} -> {x_t + 1, y_t}
                {:head_is_up_right, _} -> {x_t + 1, y_t + 1}
                {:head_is_down_right, _} -> {x_t + 1, y_t - 1}
                {:head_is_up, _} -> {x_t, y_t + 1}
                {:head_is_down, _} -> {x_t, y_t - 1}
                {:head_is_left, _} -> {x_t - 1, y_t}
                {:head_is_up_left, _} -> {x_t - 1, y_t + 1}
                {:head_is_down_left, _} -> {x_t - 1, y_t - 1}
              end

            [new_tail | knot_acc]
          end)

        %{
          acc
          | knots: Enum.reverse(new_knots_reversed),
            visit: MapSet.put(v, hd(new_knots_reversed))
        }
        |> tap(fn v -> Map.take(v, [:knots]) |> IO.inspect() end)
    end)
    |> Map.get(:visit)
    |> MapSet.size()
  end

  defp relative_pos({x_h, y_h} = h, {x_t, y_t} = t) do
    cond do
      h == t -> :same
      x_h > x_t and y_h == y_t -> :head_is_right
      x_h > x_t and y_h > y_t -> :head_is_up_right
      x_h > x_t and y_h < y_t -> :head_is_down_right
      x_h == x_t and y_h > y_t -> :head_is_up
      x_h == x_t and y_h < y_t -> :head_is_down
      x_h < x_t and y_h == y_t -> :head_is_left
      x_h < x_t and y_h > y_t -> :head_is_up_left
      x_h < x_t and y_h < y_t -> :head_is_down_left
      true -> :unknown
    end
    |> then(fn atom ->
      {atom, adjacent?(h, t)}
    end)
  end

  defp adjacent?({x_h, y_h}, {x_t, y_t}) do
    abs(x_t - x_h) <= 1 and abs(y_t - y_h) <= 1
  end
end
