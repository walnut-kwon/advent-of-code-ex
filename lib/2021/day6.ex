# Advent of Code 2021 Day 6 - Lanternfish
# https://adventofcode.com/2021/day/6
# Commentary: https://walnut-today.tistory.com/47

defmodule Aoc2021.Day6 do
  @period 6
  @first_period @period + 2

  def parse_input do
    path = "input/day6.txt"

    File.read!(path)
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @spec run_q1 :: non_neg_integer
  def run_q1 do
    parse_input()
    |> Enum.frequencies()
    |> step(80)
    |> Map.values()
    |> Enum.sum()
  end

  @spec run_q1_old :: non_neg_integer
  def run_q1_old do
    parse_input()
    |> step_old(80)
    |> Enum.count()
  end

  def run_q2 do
    parse_input()
    |> Enum.frequencies()
    |> step(256)
    |> Map.values()
    |> Enum.sum()
  end

  @spec step(%{integer() => integer()}, integer()) :: %{integer() => integer()}
  defp step(fishes, 0) do
    fishes
  end

  defp step(fishes, remain_day) do
    fishes
    |> Enum.reduce(%{}, fn
      {0, fish_count}, acc_fishes ->
        acc_fishes
        |> Map.update(@period, fish_count, &(&1 + fish_count))
        |> Map.update(@first_period, fish_count, &(&1 + fish_count))

      {day, fish_count}, acc_fishes ->
        acc_fishes
        |> Map.update(day - 1, fish_count, &(&1 + fish_count))
    end)
    |> step(remain_day - 1)
  end

  @spec step_old(list(integer), integer) :: list(integer)
  defp step_old(fishes, 0) do
    fishes
  end

  defp step_old(fishes, remain_day) do
    {existing_fishes, count_of_new_fishes} =
      fishes
      |> Enum.reduce({[], 0}, fn
        0, {fishes, count_of_new_fishes} ->
          {[6 | fishes], count_of_new_fishes + 1}

        day, {acc, count_of_new_fishes} ->
          {[day - 1 | acc], count_of_new_fishes}
      end)

    1..count_of_new_fishes//1
    |> Enum.map(fn _ -> @first_period end)
    |> Kernel.++(existing_fishes)
    |> Enum.reverse()
    # |> IO.inspect(label: remain_day)
    |> step_old(remain_day - 1)
  end
end
