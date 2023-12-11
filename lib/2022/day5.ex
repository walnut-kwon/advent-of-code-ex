# Advent of Code 2022 Day 5 - Supply Stacks
# https://adventofcode.com/2022/day/5
# Commentary: https://walnut-today.tistory.com/209

defmodule Aoc2022.Day5 do
  @dir "data/day5/"

  def q1(file_name \\ "q.txt") do
    [stack_str, instructions] =
      File.read!(@dir <> file_name)
      |> String.split("\n\n")

    stacks = parse_stacks(stack_str)

    instructions
    |> String.split("\n")
    |> Enum.reduce(stacks, fn instruction, acc ->
      ["move", cnt, "from", a, "to", b] = String.split(instruction, " ")

      move_one(acc, String.to_integer(a), String.to_integer(b), String.to_integer(cnt))
    end)
    |> Map.values()
    |> Enum.map(&hd/1)
    |> Enum.join("")
  end

  def q2(file_name \\ "q.txt") do
    [stack_str, instructions] =
      File.read!(@dir <> file_name)
      |> String.split("\n\n")

    stacks = parse_stacks(stack_str)

    instructions
    |> String.split("\n")
    |> Enum.reduce(stacks, fn instruction, acc ->
      ["move", cnt, "from", a, "to", b] = String.split(instruction, " ")

      move_multi(acc, String.to_integer(a), String.to_integer(b), String.to_integer(cnt))
    end)
    |> Map.values()
    |> Enum.map(&hd/1)
    |> Enum.join("")
  end

  defp parse_stacks(stack_str) do
    lists =
      stack_str
      |> String.split("\n")
      |> Enum.map(fn line ->
        line
        |> String.graphemes()
        |> Enum.chunk_every(4)
        |> Enum.map(fn chunk -> Enum.join(chunk, "") |> String.trim() end)
        |> List.to_tuple()
      end)

    stack_count = lists |> hd() |> tuple_size()

    0..(stack_count - 1)
    |> Enum.map(fn i ->
      {i + 1,
       lists
       |> Enum.map(&(elem(&1, i) |> String.slice(1..-2//1)))
       |> Enum.reject(fn cell -> cell == "" or String.match?(cell, ~r/[0-9]+/) end)}
    end)
    |> Enum.into(%{})
  end

  defp move_one(stacks, _, _, 0), do: stacks

  defp move_one(stacks, a, b, cnt) do
    stacks
    |> Map.update!(b, fn stack -> [hd(stacks[a]) | stack] end)
    |> Map.update!(a, fn stack -> tl(stack) end)
    |> move_one(a, b, cnt - 1)
  end

  defp move_multi(stacks, a, b, cnt) do
    stacks
    |> Map.update!(b, fn stack -> Enum.take(stacks[a], cnt) ++ stack end)
    |> Map.update!(a, fn stack -> Enum.drop(stack, cnt) end)
  end
end
