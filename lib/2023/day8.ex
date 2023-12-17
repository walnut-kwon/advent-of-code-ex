# Advent of Code 2023 Day 8 - Haunted Wasteland
# https://adventofcode.com/2023/day/8

defmodule Aoc2023.Day8 do
  @dir "input/2023/"

  def q1(file_name \\ "day8.txt") do
    [instructions, _ | network] =
      File.read!(@dir <> file_name)
      |> String.split("\n")

    instructions = String.graphemes(instructions) |> Stream.cycle()

    network =
      network
      |> Map.new(fn line ->
        [[_, dest, left, right]] = Regex.scan(~r/([A-Z]{3}) = \(([A-Z]{3}), ([A-Z]{3})\)/, line)
        {dest, {left, right}}
      end)

    Enum.reduce_while(instructions, {"AAA", 0}, fn inst, {now, step} ->
      next = next_node(network, now, inst)

      if next == "ZZZ" do
        {:halt, {next, step + 1}}
      else
        {:cont, {next, step + 1}}
      end
    end)
  end

  defp next_node(network, now, inst) do
    if inst == "L" do
      elem(network[now], 0)
    else
      elem(network[now], 1)
    end
  end

  def q2(file_name \\ "day8.txt") do
    [instructions, _ | network] =
      File.read!(@dir <> file_name)
      |> String.split("\n")

    instructions = String.graphemes(instructions) |> Stream.cycle()

    network =
      network
      |> Map.new(fn line ->
        [[_, dest, left, right]] = Regex.scan(~r/([A-Z]{3}) = \(([A-Z]{3}), ([A-Z]{3})\)/, line)
        {dest, {left, right}}
      end)

    starting_nodes =
      network
      |> Map.keys()
      |> Enum.filter(&String.ends_with?(&1, "A"))
      |> Enum.map(&{&1, 0})

    Enum.reduce_while(instructions, {starting_nodes, 0}, fn inst, {current_nodes, step} ->
      next_nodes =
        Enum.map(current_nodes, fn {current_node, cycle_step} ->
          next_node = next_node(network, current_node, inst)

          if next_node |> String.ends_with?("Z") do
            {next_node, step + 1}
          else
            {next_node, cycle_step}
          end
        end)

      if Enum.all?(next_nodes, fn {_, node_step} -> node_step != 0 end) do
        {:halt, {next_nodes, step + 1}}
      else
        {:cont, {next_nodes, step + 1}}
      end
    end)
    |> elem(0)
    |> Enum.map(&elem(&1, 1))
    |> lcm()
  end

  defp lcm(numbers) do
    gcd = Enum.reduce(numbers, &Integer.gcd/2)

    Enum.reduce(numbers, fn a, b -> div(a * b, gcd) end)
  end
end
