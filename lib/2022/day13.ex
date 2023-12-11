# Advent of Code 2022 Day 13 - Distress Signal
# https://adventofcode.com/2022/day/13
# Commentary: https://walnut-today.tistory.com/217

defmodule Aoc2022.Day13 do
  @dir "data/day13/"

  def q1(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n\n")
    |> Enum.with_index()
    |> Enum.map(fn {packets, i} ->
      packets
      |> String.split("\n")
      |> Enum.map(fn line ->
        {packet, _} = Code.eval_string(line)
        packet
      end)
      |> compare()
      |> IO.inspect(label: packets)
      |> then(fn v -> {v, i} end)
    end)
    |> Enum.filter(fn {v, _i} -> v == true end)
    |> Enum.map(fn {_v, i} -> i + 1 end)
    |> Enum.sum()
  end

  def q2(file_name \\ "q.txt") do
    packets =
      File.read!(@dir <> file_name)
      |> String.split("\n\n")
      |> Enum.flat_map(fn two_packets ->
        two_packets
        |> String.split("\n")
        |> Enum.map(fn line ->
          {packet, _} = Code.eval_string(line)
          packet
        end)
      end)
      |> Kernel.++([[[2]], [[6]]])
      |> Enum.sort(fn a, b -> compare([a, b]) end)

    divider_2 = packets |> Enum.find_index(fn v -> v == [[2]] end) |> Kernel.+(1)
    divider_6 = packets |> Enum.find_index(fn v -> v == [[6]] end) |> Kernel.+(1)

    divider_2 * divider_6
  end

  defp compare([[], []]), do: :pass

  defp compare([[], [_ | _]]), do: true

  defp compare([[_ | _], []]), do: false

  defp compare([[h1 | t1], [h1 | t2]]), do: compare([t1, t2])

  defp compare([[h1 | _], [h2 | _]]) when is_integer(h1) and is_integer(h2) and h1 < h2, do: true

  defp compare([[h1 | _], [h2 | _]]) when is_integer(h1) and is_integer(h2) and h1 > h2, do: false

  defp compare([[h1 | t1], [h2 | t2]]) do
    case compare([List.wrap(h1), List.wrap(h2)]) do
      true -> true
      :pass -> compare([t1, t2])
      false -> false
    end
  end
end
