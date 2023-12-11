# Advent of Code 2022 Day 20 - Grove Positioning System
# https://adventofcode.com/2022/day/20
# Commentary: https://walnut-today.tistory.com/224

defmodule Aoc2022.Day20 do
  @dir "data/day20/"

  def q1(file_name \\ "q.txt") do
    list =
      File.read!(@dir <> file_name)
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(fn v -> {v, false} end)

    size = length(list)

    result =
      list
      |> Enum.reduce(list, fn {value, false}, acc ->
        idx = Enum.find_index(acc, &(elem(&1, 1) == false))

        new_idx = Integer.mod(idx + value, size - 1)

        # IO.inspect(acc, label: "Next number: #{value} at #{idx} to #{new_idx}")

        next_list =
          if idx == 0 do
            Enum.slice(acc, (idx + 1)..-1)
          else
            Enum.slice(acc, 0..(idx - 1)) ++ Enum.slice(acc, (idx + 1)..-1)
          end
          |> List.insert_at(new_idx, {value, true})

        next_list
      end)
      |> IO.inspect()

    zero_index = Enum.find_index(result, &(&1 == {0, true})) |> IO.inspect()
    num_1000 = Enum.at(result, rem(1000 + zero_index, size)) |> elem(0)
    num_2000 = Enum.at(result, rem(2000 + zero_index, size)) |> elem(0)
    num_3000 = Enum.at(result, rem(3000 + zero_index, size)) |> elem(0)

    num_1000 + num_2000 + num_3000
  end

  def q2(file_name \\ "q.txt") do
    multiplier = 811_589_153

    list =
      File.read!(@dir <> file_name)
      |> String.split("\n")
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(fn v -> v * multiplier end)
      |> Enum.with_index()

    size = length(list)

    result =
      1..10
      |> Enum.flat_map(fn _ -> list end)
      |> Enum.reduce(list, fn {value, idx}, acc ->
        if idx == 0 do
          IO.inspect(acc, label: "Round finished")
        end

        real_index = Enum.find_index(acc, fn {_v, i} -> i == idx end)
        new_idx = Integer.mod(real_index + value, size - 1)

        # IO.inspect(acc)
        # IO.puts("Next number: #{value} at #{real_index} to #{new_idx}")

        next_list =
          if real_index == 0 do
            Enum.slice(acc, (real_index + 1)..-1)
          else
            Enum.slice(acc, 0..(real_index - 1)) ++ Enum.slice(acc, (real_index + 1)..-1)
          end
          |> List.insert_at(new_idx, {value, idx})

        next_list
      end)
      |> IO.inspect()

    zero_index = Enum.find_index(result, &(elem(&1, 0) == 0))
    num_1000 = Enum.at(result, rem(1000 + zero_index, size)) |> elem(0) |> IO.inspect()
    num_2000 = Enum.at(result, rem(2000 + zero_index, size)) |> elem(0) |> IO.inspect()
    num_3000 = Enum.at(result, rem(3000 + zero_index, size)) |> elem(0) |> IO.inspect()

    (num_1000 + num_2000 + num_3000) * 1
  end
end
