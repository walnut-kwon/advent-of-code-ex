# Advent of Code 2021 Day 3 - Binary Diagnostic
# https://adventofcode.com/2021/day/3
# Commentary: https://walnut-today.tistory.com/44

defmodule Aoc2021.Day3 do
  def parse_input do
    path = "input/day3.txt"

    File.read!(path)
    |> String.split("\n")
  end

  def run_q1 do
    input = parse_input()

    bit_length = input |> hd() |> String.length()

    bit_frequencies =
      0..(bit_length - 1)
      |> Enum.map(fn pos -> calculate_bit_frequency(input, pos) end)

    gamma_rate =
      bit_frequencies
      |> Enum.map(&most_common_bit/1)
      |> list_to_binary()

    epsilon_rate =
      bit_frequencies
      |> Enum.map(&least_common_bit/1)
      |> list_to_binary()

    gamma_rate * epsilon_rate
  end

  def run_q2 do
    input = parse_input()

    oxygen = do_run_q2(input, 0, &most_common_bit/1)
    co2 = do_run_q2(input, 0, &least_common_bit/1)

    oxygen * co2
  end

  defp do_run_q2([number], _, _) do
    number |> String.graphemes() |> list_to_binary()
  end

  defp do_run_q2(numbers, pos, predicate_to_keep_bit) do
    keeping_bit =
      numbers
      |> calculate_bit_frequency(pos)
      |> predicate_to_keep_bit.()

    numbers
    |> Enum.filter(fn number -> String.at(number, pos) == keeping_bit end)
    |> do_run_q2(pos + 1, predicate_to_keep_bit)
  end

  defp calculate_bit_frequency(input, pos) do
    input
    |> Enum.reduce(
      {0, 0},
      fn
        bit, {zero_count, one_count} ->
          String.at(bit, pos)
          |> then(fn
            "0" -> {zero_count + 1, one_count}
            "1" -> {zero_count, one_count + 1}
          end)
      end
    )
  end

  defp list_to_binary(binary_list) do
    binary_list
    |> List.to_charlist()
    |> List.to_integer(2)
  end

  defp most_common_bit({zero, one}) when zero > one, do: "0"
  defp most_common_bit({zero, one}) when zero <= one, do: "1"

  defp least_common_bit({zero, one}) when zero > one, do: "1"
  defp least_common_bit({zero, one}) when zero <= one, do: "0"
end
