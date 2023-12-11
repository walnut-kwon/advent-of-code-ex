# Advent of Code 2022 Day 11 - Monkey in the Middle
# https://adventofcode.com/2022/day/11
# Commentary: https://walnut-today.tistory.com/215

defmodule Aoc2022.Day11 do
  @dir "data/day11/"

  def q1(file_name \\ "q.txt") do
    monkeys = build_monkeys(file_name)
    items = build_items(monkeys)

    run_round(0, 20, monkeys, items, fn l -> div(l, 3) end)
    |> IO.inspect()
    |> elem(0)
    |> Enum.sort_by(fn {_id, monkey} -> monkey.inspect_count end, :desc)
    |> Enum.take(2)
    |> then(fn [{_, f}, {_, s}] ->
      f.inspect_count * s.inspect_count
    end)
  end

  def q2(file_name \\ "q.txt") do
    monkeys = build_monkeys(file_name)
    items = build_items(monkeys)
    product_of_divisors = monkeys |> Enum.map(fn {_id, m} -> m.divisor end) |> Enum.product()

    run_round(0, 10000, monkeys, items, fn l -> rem(l, product_of_divisors) end)
    |> IO.inspect()
    |> elem(0)
    |> Enum.sort_by(fn {_id, monkey} -> monkey.inspect_count end, :desc)
    |> Enum.take(2)
    |> then(fn [{_, f}, {_, s}] ->
      f.inspect_count * s.inspect_count
    end)
  end

  defp build_monkeys(file_name) do
    File.read!(@dir <> file_name)
    |> String.split("\n\n")
    |> Enum.map(fn monkey_str ->
      [
        "Monkey " <> n,
        "  Starting items: " <> starting_items,
        "  Operation: " <> operation,
        "  Test: divisible by " <> divisor,
        "    If true: throw to monkey " <> if_true,
        "    If false: throw to monkey " <> if_false
      ] =
        monkey_str
        |> String.split("\n")

      {n |> String.trim_trailing(":") |> String.to_integer(),
       %{
         starting_items: String.split(starting_items, ", ") |> Enum.map(&String.to_integer/1),
         operation: operation,
         divisor: String.to_integer(divisor),
         if_true: String.to_integer(if_true),
         if_false: String.to_integer(if_false),
         inspect_count: 0
       }}
    end)
    |> Enum.into(%{})
  end

  defp build_items(monkeys) do
    monkeys
    |> Enum.flat_map(fn {id, monkey} ->
      Enum.map(monkey.starting_items, fn item -> {item, id} end)
    end)
  end

  defp run_round(current, current, monkeys, items, _worry_level_modifier), do: {monkeys, items}

  defp run_round(current, target_round, monkeys, items, worry_level_modifier) do
    {new_items, frequency} =
      0..(map_size(monkeys) - 1)
      |> Enum.reduce({items, %{}}, fn monkey_id, {acc, frequencies} ->
        tmp_freq = acc |> Enum.count(fn {_item, id} -> id == monkey_id end)

        {acc
         |> Enum.map(fn {item, id} ->
           if id == monkey_id do
             eval_item({item, id}, monkeys[id], worry_level_modifier)
           else
             {item, id}
           end
         end), Map.put(frequencies, monkey_id, tmp_freq)}
      end)

    new_monkeys =
      monkeys
      |> Enum.map(fn {id, monkey} ->
        {id, Map.update!(monkey, :inspect_count, &(&1 + frequency[id]))}
      end)
      |> Enum.into(%{})

    run_round(current + 1, target_round, new_monkeys, new_items, worry_level_modifier)
  end

  defp eval_item({item, _id}, monkey, worry_level_modifier) do
    {result, _} = Code.eval_string(monkey.operation, old: item)
    worry_level = worry_level_modifier.(result)

    if rem(worry_level, monkey.divisor) == 0 do
      {worry_level, monkey.if_true}
    else
      {worry_level, monkey.if_false}
    end
  end
end
