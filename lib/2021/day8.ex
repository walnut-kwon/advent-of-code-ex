# Advent of Code 2021 Day 8 - Seven Segment Search
# https://adventofcode.com/2021/day/8
# Commentary: https://walnut-today.tistory.com/49

defmodule Aoc2021.Day8 do
  @mapping_by_number %{
    MapSet.new([:top, :top_right, :bot_right, :bot, :bot_left, :top_left]) => 0,
    MapSet.new([:top_right, :bot_right]) => 1,
    MapSet.new([:top, :top_right, :mid, :bot_left, :bot]) => 2,
    MapSet.new([:top, :top_right, :mid, :bot_right, :bot]) => 3,
    MapSet.new([:top_left, :top_right, :mid, :bot_right]) => 4,
    MapSet.new([:top, :top_left, :mid, :bot_right, :bot]) => 5,
    MapSet.new([:top, :top_left, :mid, :bot_left, :bot_right, :bot]) => 6,
    MapSet.new([:top, :top_right, :bot_right]) => 7,
    MapSet.new([:top, :top_left, :top_right, :mid, :bot_left, :bot_right, :bot]) => 8,
    MapSet.new([:top, :top_left, :top_right, :mid, :bot_right, :bot]) => 9
  }

  def parse_input do
    path = "input/day8.txt"

    File.read!(path)
    |> String.split("\n")
    |> Enum.map(fn row ->
      row
      |> String.split(" | ")
      |> Enum.map(&String.split(&1, " "))
    end)
  end

  def run_q1 do
    digits =
      parse_input()
      |> Enum.map(fn [_pattern, digit] -> digit end)
      |> List.flatten()

    digits
    |> Enum.count(fn digit -> String.length(digit) in [2, 3, 4, 7] end)
  end

  def run_q2 do
    parse_input()
    |> Enum.map(fn [pattern, digit] ->
      mapping_by_pos = %{
        top: nil,
        top_left: nil,
        top_right: nil,
        mid: nil,
        bot_left: nil,
        bot_right: nil,
        bot: nil
      }

      # finding top
      digit_1 = find_digit_by_number_of_segment(pattern, 2) |> hd()
      digit_7 = find_digit_by_number_of_segment(pattern, 3) |> hd()
      digit_4 = find_digit_by_number_of_segment(pattern, 4) |> hd()

      mapping_by_pos =
        Map.put(mapping_by_pos, :top, MapSet.difference(digit_7, digit_1) |> first())

      # finding top_right, bot_right
      [seg5_cand1, seg5_cand2, seg5_cand3] = find_digit_by_number_of_segment(pattern, 6)

      segs_abfg =
        seg5_cand1
        |> MapSet.intersection(seg5_cand2)
        |> MapSet.intersection(seg5_cand3)

      mapping_by_pos =
        Map.put(mapping_by_pos, :top_right, MapSet.difference(digit_1, segs_abfg) |> first())

      mapping_by_pos =
        Map.put(
          mapping_by_pos,
          :bot_right,
          MapSet.delete(digit_1, mapping_by_pos.top_right) |> first()
        )

      # finding top_left
      mapping_by_pos =
        Map.put(
          mapping_by_pos,
          :top_left,
          MapSet.intersection(segs_abfg, digit_4)
          |> MapSet.delete(mapping_by_pos.bot_right)
          |> first()
        )

      # finding mid
      mapping_by_pos =
        Map.put(
          mapping_by_pos,
          :mid,
          digit_4
          |> MapSet.delete(mapping_by_pos.top_right)
          |> MapSet.delete(mapping_by_pos.top_left)
          |> MapSet.delete(mapping_by_pos.bot_right)
          |> first()
        )

      # finding bot
      mapping_by_pos =
        Map.put(
          mapping_by_pos,
          :bot,
          segs_abfg
          |> MapSet.delete(mapping_by_pos.top)
          |> MapSet.delete(mapping_by_pos.top_left)
          |> MapSet.delete(mapping_by_pos.bot_right)
          |> first()
        )

      # finding bot_left
      mapping_by_pos =
        Map.put(
          mapping_by_pos,
          :bot_left,
          ["a", "b", "c", "d", "e", "f", "g"]
          |> Kernel.--(Map.values(mapping_by_pos))
          |> List.first()
        )

      map_to_digit(mapping_by_pos, digit)
    end)
    |> Enum.sum()
  end

  @spec find_digit_by_number_of_segment(list(String.t()), integer()) :: list(MapSet.t())
  defp find_digit_by_number_of_segment(pattern, number_of_segment) do
    pattern
    |> Enum.filter(fn p -> String.length(p) == number_of_segment end)
    |> Enum.map(fn p -> p |> String.codepoints() |> MapSet.new() end)
  end

  defp first(mapset) do
    mapset |> MapSet.to_list() |> List.first()
  end

  defp map_to_digit(mapping_by_pos, digit) do
    mapping_by_seg = Enum.map(mapping_by_pos, fn {k, v} -> {v, k} end) |> Enum.into(%{})

    Enum.map(digit, fn d ->
      key =
        d |> String.codepoints() |> Enum.map(fn seg -> mapping_by_seg[seg] end) |> MapSet.new()

      @mapping_by_number[key]
    end)
    |> Integer.undigits()
  end
end
