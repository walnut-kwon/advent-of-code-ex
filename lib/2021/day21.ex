# Advent of Code 2021 Day 21 - Dirac Dice
# https://adventofcode.com/2021/day/21
# Commentary: https://walnut-today.tistory.com/64

defmodule Aoc2021.Day21 do
  @dice_side_q1 100
  @map_size 10
  @win_score_q1 1000
  @win_score_q2 21
  @cases_for_point %{3 => 1, 4 => 3, 5 => 6, 6 => 7, 7 => 6, 8 => 3, 9 => 1}

  def parse_input(file_name \\ "input/day21.txt") do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn r ->
      r |> String.split(": ") |> Enum.drop(1) |> hd() |> String.to_integer()
    end)
    |> List.to_tuple()
  end

  def run_q1(file_name \\ "input/day21.txt") do
    file_name |> parse_input() |> do_run_q1({0, 0}, :p1, 1, 0)
  end

  def run_q2(file_name \\ "input/day21.txt") do
    {p1_start, p2_start} = parse_input(file_name)

    do_run_q2(%{{{p1_start, p2_start}, {0, 0}, :p1} => 1}, {0, 0})
  end

  defp do_run_q1(_, {s1, s2}, _turn, _, thrown_count) when s1 >= @win_score_q1 do
    s2 * thrown_count
  end

  defp do_run_q1(_, {s1, s2}, _turn, _, thrown_count) when s2 >= @win_score_q1 do
    s1 * thrown_count
  end

  defp do_run_q1({p1, p2}, {s1, s2}, :p1 = _turn, dice_offset, thrown_count) do
    {to_move, next_dice_offset} = throw_dice_q1(dice_offset)

    new_p1 = move(p1, to_move)

    do_run_q1({new_p1, p2}, {s1 + new_p1, s2}, :p2, next_dice_offset, thrown_count + 3)
  end

  defp do_run_q1({p1, p2}, {s1, s2}, :p2 = _turn, dice_offset, thrown_count) do
    {to_move, next_dice_offset} = throw_dice_q1(dice_offset)

    new_p2 = move(p2, to_move)

    do_run_q1({p1, new_p2}, {s1, s2 + new_p2}, :p1, next_dice_offset, thrown_count + 3)
  end

  defp do_run_q2(game_instances, {p1_won, p2_won}) when map_size(game_instances) == 0,
    do: {p1_won, p2_won}

  defp do_run_q2(game_instances, {p1_won, p2_won}) do
    IO.inspect(game_instances, label: "instances")
    IO.inspect({p1_won, p2_won}, label: "won_count")

    new_p1_won =
      game_instances
      |> Enum.filter(fn {{{_p1, _p2}, {s1, _s2}, _}, _ins_count} -> s1 >= @win_score_q2 end)
      |> Enum.map(fn {{{_p1, _p2}, {_s1, _s2}, _}, ins_count} -> ins_count end)
      |> Enum.sum()
      |> Kernel.+(p1_won)

    new_p2_won =
      game_instances
      |> Enum.filter(fn {{{_p1, _p2}, {_s1, s2}, _}, _ins_count} -> s2 >= @win_score_q2 end)
      |> Enum.map(fn {{{_p1, _p2}, {_s1, _s2}, _}, ins_count} -> ins_count end)
      |> Enum.sum()
      |> Kernel.+(p2_won)

    new_game_instance =
      game_instances
      |> Enum.reject(fn {{{_p1, _p2}, {s1, s2}, _}, _ins_count} ->
        s1 >= @win_score_q2 or s2 >= @win_score_q2
      end)
      |> Enum.reduce(%{}, fn
        # 3 => 1/27, 4 => 3/27, 5 => 6/27, 6 => 7/27, 7 => 6/27, 8 => 3/27, 9 => 1/27
        {{{p1, p2}, {s1, s2}, :p1}, ins_count}, acc ->
          Enum.reduce(@cases_for_point, acc, fn {point, num_of_cases}, acc_instances ->
            update_instance(
              acc_instances,
              {{move(p1, point), p2}, {s1 + move(p1, point), s2}, :p2},
              num_of_cases * ins_count
            )
          end)

        {{{p1, p2}, {s1, s2}, :p2}, ins_count}, acc ->
          Enum.reduce(@cases_for_point, acc, fn {point, num_of_cases}, acc_instances ->
            update_instance(
              acc_instances,
              {{p1, move(p2, point)}, {s1, s2 + move(p2, point)}, :p1},
              num_of_cases * ins_count
            )
          end)
      end)

    do_run_q2(new_game_instance, {new_p1_won, new_p2_won})
  end

  defp throw_dice_q1(dice_offset) do
    value = 0..2 |> Enum.map(fn v -> rem(dice_offset + v, @dice_side_q1) end) |> Enum.sum()
    next = rem(dice_offset + 3, @dice_side_q1)
    {value, next}
  end

  defp move(position, dice) do
    if rem(position + dice, @map_size) == 0, do: 10, else: rem(position + dice, @map_size)
  end

  defp update_instance(map, key, value), do: Map.update(map, key, value, &(&1 + value))
end
