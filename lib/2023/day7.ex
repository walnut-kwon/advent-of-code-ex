# Advent of Code 2023 Day 7 - Camel Cards
# https://adventofcode.com/2023/day/7

defmodule Aoc2023.Day7 do
  @dir "input/2023/"

  @card_priority_q1 %{"A" => 14, "K" => 13, "Q" => 12, "J" => 11, "T" => 10}
  @card_priority_q2 %{"A" => 14, "K" => 13, "Q" => 12, "J" => 1, "T" => 10}

  def q1(file_name \\ "day7.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ")
      hand = hand |> String.graphemes()
      bid = String.to_integer(bid)

      {hand, calc_type_q1(hand), bid}
    end)
    |> with_rank(@card_priority_q1)
    |> Enum.map(fn {{_, _, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  def q2(file_name \\ "day7.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ")
      hand = hand |> String.graphemes()
      bid = String.to_integer(bid)

      {hand, calc_type_q2(hand), bid}
    end)
    |> with_rank(@card_priority_q2)
    |> Enum.map(fn {{_, _, bid}, rank} -> bid * rank end)
    |> Enum.sum()
  end

  defp calc_type_q1(hand) do
    freq = hand |> Enum.frequencies() |> Map.values() |> Enum.sort()

    case freq do
      [_] -> :type_7_five
      [1, 4] -> :type_6_four
      [2, 3] -> :type_5_full
      [1, 1, 3] -> :type_4_three
      [1, 2, 2] -> :type_3_two
      [1, 1, 1, 2] -> :type_2_one
      [_, _, _, _, _] -> :type_1_high
    end
  end

  defp calc_type_q2(hand) do
    freq_wo_j =
      hand |> Enum.reject(&(&1 == "J")) |> Enum.frequencies() |> Map.values() |> Enum.sort()

    case freq_wo_j do
      [] -> :type_7_five
      [_] -> :type_7_five
      [1, _] -> :type_6_four
      [2, _] -> :type_5_full
      [1, 1, _] -> :type_4_free
      [1, 2, 2] -> :type_3_two
      [1, 1, 1, _] -> :type_2_one
      [_, _, _, _, _] -> :type_1_high
    end
  end

  defp with_rank(hands_with_type, priority_map) do
    hands_with_type
    |> Enum.sort(fn {hand1, type1, _bid1}, {hand2, type2, _bid2} ->
      if type1 != type2 do
        type1 <= type2
      else
        compare_hand(hand1, hand2, priority_map)
      end
    end)
    |> Enum.with_index(1)
  end

  defp compare_hand([h1 | t1], [h2 | t2], priority_map) do
    h1_priority = priority(h1, priority_map)
    h2_priority = priority(h2, priority_map)

    if h1_priority == h2_priority,
      do: compare_hand(t1, t2, priority_map),
      else: h1_priority < h2_priority
  end

  defp priority(card, priority_map) do
    if Map.has_key?(priority_map, card), do: priority_map[card], else: String.to_integer(card)
  end
end
