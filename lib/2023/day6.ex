# Advent of Code 2023 Day 6 - Wait For It
# https://adventofcode.com/2023/day/6

defmodule Aoc2023.Day6 do
  @dir "input/2023/"

  def q1(file_name \\ "day6.txt") do
    [time, distance] =
      File.read!(@dir <> file_name)
      |> String.split("\n")

    time = parse_input_line_q1(time, "Time:")
    distance = parse_input_line_q1(distance, "Distance:")

    Enum.zip(time, distance)
    |> Enum.map(fn {t, d} ->
      1..t |> find_ways_to_win(t, d)
    end)
    |> Enum.product()
  end

  defp find_ways_to_win(holding_time_range, total_time, distance) do
    holding_time_range
    |> Enum.reduce_while(0, fn holding, ways_to_win ->
      if (total_time - holding) * holding > distance do
        {:cont, ways_to_win + 1}
      else
        if ways_to_win == 0 do
          {:cont, ways_to_win}
        else
          {:halt, ways_to_win}
        end
      end
    end)
  end

  def q2(file_name \\ "day6.txt") do
    [time, distance] =
      File.read!(@dir <> file_name)
      |> String.split("\n")

    time = parse_input_line_q2(time, "Time:")
    distance = parse_input_line_q2(distance, "Distance:")

    # Holding time for winning is symmetric to mid point
    # Winning way is always even when total time is odd, vice versa
    # So temporarily exclude exatly-mid point to find winning range
    small_mid_point = if rem(time, 2) == 0, do: time / 2 - 1, else: div(time, 2)
    powered_offset = find_powered_offset(small_mid_point, 1, time, distance)

    (small_mid_point - powered_offset)..(small_mid_point - div(powered_offset, 2))
    |> find_ways_to_win(time, distance)
    |> Kernel.+(div(powered_offset, 2))
    |> Kernel.*(2)
    |> then(fn v ->
      if rem(time, 2) == 0, do: v + 1, else: v
    end)
  end

  # starting from `small_mid_point`, doubles offset for each recursive call
  # to roughly find threshold of winning
  # return value is first power-of-2 value lose the race
  defp find_powered_offset(small_mid_point, offset, time, distance) do
    holding = small_mid_point - offset

    if (time - holding) * holding > distance do
      find_powered_offset(small_mid_point, offset * 2, time, distance)
    else
      offset
    end
  end

  defp parse_input_line_q1(input_line, prefix) do
    input_line
    |> String.trim_leading(prefix)
    |> String.split(~r/\s+/, trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  defp parse_input_line_q2(input_line, prefix) do
    input_line
    |> String.trim_leading(prefix)
    |> String.replace(~r/\s+/, "")
    |> String.to_integer()
  end
end
