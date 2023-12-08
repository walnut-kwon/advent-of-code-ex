# Advent of Code 2021 Day 11 - Dumbo Octopus
# https://adventofcode.com/2021/day/11
# Commentary: https://walnut-today.tistory.com/52

defmodule Aoc2021.Day11 do
  def parse_input do
    path = "input/day11.txt"

    File.read!(path)
    |> String.split("\n")
    |> Enum.map(fn r ->
      r
      |> String.codepoints()
      |> Enum.map(&String.to_integer/1)
    end)
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
        {{row_index, col_index}, {val, false}}
      end)
    end)
    |> Enum.into(%{})
  end

  @spec run_q1(non_neg_integer()) :: non_neg_integer()
  def run_q1(step) do
    parse_input()
    |> nested_list_to_map()
    |> step_by_count(0, step)
  end

  defp step_by_count(octopuses, flash_count, 0) do
    print(octopuses)

    flash_count
  end

  defp step_by_count(octopuses, flash_count, remain_step) do
    {new_octopuses, new_flash_count} = do_step(octopuses)

    step_by_count(new_octopuses, flash_count + new_flash_count, remain_step - 1)
  end

  @spec run_q2() :: non_neg_integer()
  def run_q2() do
    parse_input()
    |> nested_list_to_map()
    |> step_until(
      fn octopuses ->
        Enum.all?(octopuses, fn {_pos, {val, _}} -> val == 0 end)
      end,
      0
    )
  end

  defp step_until(octopuses, predicate_to_stop, step) do
    if predicate_to_stop.(octopuses) do
      step
    else
      do_step(octopuses)
      |> elem(0)
      |> step_until(predicate_to_stop, step + 1)
    end
  end

  defp do_step(octopuses) do
    new_octopuses =
      octopuses
      |> Enum.map(fn {pos, {val, processed?}} -> {pos, {val + 1, processed?}} end)
      |> Enum.into(%{})
      |> flash()

    flash_count =
      Enum.count(new_octopuses, fn {_pos, {_val, processed?}} -> processed? == true end)

    new_octopuses =
      new_octopuses
      |> Enum.map(fn
        {pos, {val, true}} when val > 9 -> {pos, {0, false}}
        {pos, {val, _}} -> {pos, {val, false}}
      end)
      |> Enum.into(%{})

    {new_octopuses, flash_count}
  end

  defp flash(octopuses) do
    flashed_octopuses =
      octopuses
      |> Enum.filter(fn
        {_pos, {val, processed?}} when val > 9 and processed? == false -> true
        {_pos, _} -> false
      end)

    func_plus_one = fn {val, processed?} -> {val + 1, processed?} end
    func_processed = fn {val, _} -> {val, true} end

    if flashed_octopuses == [] do
      octopuses
    else
      flashed_octopuses
      |> Enum.reduce(octopuses, fn {{row, col}, _}, acc_octopuses ->
        acc_octopuses
        |> map_update_when_exists({row, col}, func_processed)
        |> map_update_when_exists({row - 1, col - 1}, func_plus_one)
        |> map_update_when_exists({row - 1, col}, func_plus_one)
        |> map_update_when_exists({row - 1, col + 1}, func_plus_one)
        |> map_update_when_exists({row, col - 1}, func_plus_one)
        |> map_update_when_exists({row, col + 1}, func_plus_one)
        |> map_update_when_exists({row + 1, col - 1}, func_plus_one)
        |> map_update_when_exists({row + 1, col}, func_plus_one)
        |> map_update_when_exists({row + 1, col + 1}, func_plus_one)
      end)
      |> flash()
    end
  end

  defp map_update_when_exists(map, key, func) do
    if Map.has_key?(map, key) do
      Map.update!(map, key, func)
    else
      map
    end
  end

  defp print(octopuses) do
    0..9
    |> Enum.each(fn r ->
      0..9
      |> Enum.each(fn c ->
        IO.write(octopuses[{r, c}] |> elem(0))
      end)

      IO.puts("")
    end)
  end
end
