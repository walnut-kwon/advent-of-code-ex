# Advent of Code 2022 Day 10 - Cathode-Ray Tube
# https://adventofcode.com/2022/day/10
# Commentary: https://walnut-today.tistory.com/214

defmodule Aoc2022.Day10 do
  @dir "data/day10/"

  defmodule CPU do
    defstruct x: 1, cycle: 0, signal_str: []
  end

  def q1(file_name \\ "q.txt") do
    signal_check_point = [20, 60, 100, 140, 180, 220]

    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn inst ->
      String.split(inst, " ")
      |> then(fn
        ["addx", n] -> {:addx, 2, String.to_integer(n)}
        ["noop"] -> {:noop, 1}
      end)
    end)
    |> Enum.reduce(%CPU{}, fn
      {:noop, tick}, %CPU{x: x, cycle: cycle, signal_str: signal} = acc ->
        if Enum.any?(signal_check_point, fn point -> cycle < point and cycle + tick >= point end) do
          %{acc | cycle: cycle + tick, signal_str: [x | signal]}
        else
          %{acc | cycle: cycle + tick}
        end

      {:addx, tick, operand}, %CPU{x: x, cycle: cycle, signal_str: signal} = acc ->
        cond do
          Enum.any?(signal_check_point, fn point -> cycle < point and cycle + tick >= point end) ->
            %{
              acc
              | x: x + operand,
                cycle: cycle + tick,
                signal_str: [x | signal]
            }

          true ->
            %{acc | x: x + operand, cycle: cycle + tick}
        end
    end)
    |> Map.get(:signal_str)
    |> Enum.reverse()
    |> Enum.zip(signal_check_point)
    |> Enum.map(fn {a, b} -> a * b end)
    |> Enum.sum()
  end

  def q2(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn inst ->
      String.split(inst, " ")
      |> then(fn
        ["addx", n] -> {:addx, 2, String.to_integer(n)}
        ["noop"] -> {:noop, 1}
      end)
    end)
    |> Enum.reduce(%CPU{}, fn
      {:noop, tick}, %CPU{x: x, cycle: cycle} = acc ->
        print(cycle, x)

        %{acc | cycle: cycle + tick}

      {:addx, tick, operand}, %CPU{x: x, cycle: cycle} = acc ->
        0..(tick - 1)
        |> Enum.each(fn i -> print(cycle + i, x) end)

        %{acc | x: x + operand, cycle: cycle + tick}
    end)
    |> tap(fn _ -> IO.puts("") end)
  end

  defp print(cycle, x) do
    screen_width = 40

    if rem(cycle, screen_width) == 0 do
      IO.write("\n")
    end

    if rem(cycle, screen_width) in (x - 1)..(x + 1) do
      IO.write("#")
    else
      IO.write(".")
    end
  end
end
