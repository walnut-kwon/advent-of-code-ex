# Advent of Code 2023 Day 1 - Trebuchet?!
# https://adventofcode.com/2023/day/1

defmodule Aoc2023.Day1 do
  @dir "input/2023/"

  def q1(file_name \\ "day1.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      digits = String.replace(line, ~r/[a-z]+/, "")
      first_digit = String.first(digits)
      last_digit = String.last(digits)

      (first_digit <> last_digit)
      |> String.to_integer()
    end)
    |> Enum.sum()
  end

  def q2(file_name \\ "day1.txt") do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> scan_digits([])
      |> digits_word_to_number()
      |> then(fn digits ->
        String.to_integer(List.first(digits) <> List.last(digits))
      end)
    end)
    |> Enum.sum()
  end

  def scan_digits("", digits), do: Enum.reverse(digits)

  def scan_digits(string, digits) do
    case Regex.run(
           ~r/[1-9]|one|two|three|four|five|six|seven|eight|nine/,
           string,
           return: :index
         ) do
      [{offset, length}] ->
        scan_digits(String.slice(string, offset + 1, 9999), [
          String.slice(string, offset, length) | digits
        ])

      nil ->
        Enum.reverse(digits)
    end
  end

  defp digits_word_to_number(digits) do
    digit_map = %{
      "one" => "1",
      "two" => "2",
      "three" => "3",
      "four" => "4",
      "five" => "5",
      "six" => "6",
      "seven" => "7",
      "eight" => "8",
      "nine" => "9"
    }

    digits
    |> Enum.map(fn digit ->
      cond do
        Map.has_key?(digit_map, digit) -> digit_map[digit]
        true -> digit
      end
    end)
  end
end
