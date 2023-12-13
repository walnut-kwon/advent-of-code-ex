# Advent of Code 2023 Day 4 - Scratchcards
# https://adventofcode.com/2023/day/4

defmodule Aoc2023.Day4 do
  @dir "input/2023/"

  def q1(file_name \\ "day4.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn card ->
      {_id, winning_numbers, your_numbers} = parse_card(card)

      match_count = MapSet.intersection(winning_numbers, your_numbers) |> MapSet.size()

      case match_count do
        0 -> 0
        n -> :math.pow(2, n - 1)
      end
    end)
    |> Enum.sum()
  end

  def q2(file_name \\ "day4.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.reduce(%{1 => 1}, fn card, acc ->
      {card_id, winning_numbers, your_numbers} = parse_card(card)

      match_count = MapSet.intersection(winning_numbers, your_numbers) |> MapSet.size()
      acc = Map.put_new(acc, card_id, 1)

      1..match_count//1
      |> Enum.reduce(acc, fn offset, acc2 ->
        next_card = card_id + offset
        Map.update(acc2, next_card, 1 + acc2[card_id], fn val -> val + acc2[card_id] end)
      end)
    end)
    |> Map.values()
    |> Enum.sum()
  end

  defp parse_card("Card" <> card) do
    card = String.trim(card)
    [card_id, numbers] = String.split(card, ": ")
    card_id = String.to_integer(card_id)

    [winning_numbers, your_numbers] =
      numbers
      |> String.split(" | ")

    winning_numbers = parse_numbers(winning_numbers)
    your_numbers = parse_numbers(your_numbers)

    {card_id, winning_numbers, your_numbers}
  end

  defp parse_numbers(number_str) do
    number_str
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer/1)
    |> MapSet.new()
  end
end
