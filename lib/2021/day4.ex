# Advent of Code 2021 Day 4 - Giant Squid
# https://adventofcode.com/2021/day/4
# Commentary: https://walnut-today.tistory.com/45

defmodule Aoc2021.Day4 do
  @board_size 5

  def parse_input do
    path = "input/day4.txt"

    [draws_raw, _ | boards_raw] =
      File.read!(path)
      |> String.split("\n")

    draws = draws_raw |> drawed_numbers()

    boards =
      boards_raw
      |> Enum.chunk_every(@board_size + 1)
      |> Enum.map(&Enum.take(&1, @board_size))
      |> Enum.map(&parse_board/1)

    {draws, boards}
  end

  @spec drawed_numbers(String.t()) :: list(number())
  defp drawed_numbers(called_number_line) do
    called_number_line
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  @spec parse_board(list(String.t())) :: list(list({number(), boolean()}))
  defp parse_board(five_line_input) do
    five_line_input
    |> Enum.map(fn line ->
      line
      |> String.trim()
      |> String.split(~r{\s+})
      |> Enum.map(&{String.to_integer(&1), false})
    end)
  end

  @spec run_q1 :: number
  def run_q1 do
    {draws, boards} = parse_input()

    do_run_q1(draws, boards)
  end

  @spec run_q2 :: number
  def run_q2 do
    {draws, boards} = parse_input()

    do_run_q2(draws, boards)
  end

  @spec do_run_q1(list(number), list(list(number))) :: number
  defp do_run_q1([current_draw | upcoming_draws], boards) do
    boards_after = bingo_single_step(boards, current_draw)

    bingo_won = Enum.find(boards_after, &is_bingo/1)

    if is_nil(bingo_won) do
      do_run_q1(upcoming_draws, boards_after)
    else
      sum_of_unmarked(bingo_won) * current_draw
    end
  end

  @spec do_run_q2(list(number), list(list(number))) :: number
  defp do_run_q2([current_draw | upcoming_draws], boards) do
    boards_after = bingo_single_step(boards, current_draw)

    bingo_won = Enum.find(boards_after, &is_bingo/1)

    cond do
      is_nil(bingo_won) ->
        do_run_q2(upcoming_draws, boards_after)

      length(boards) == 1 ->
        sum_of_unmarked(bingo_won) * current_draw

      true ->
        do_run_q2(upcoming_draws, Enum.reject(boards_after, &is_bingo/1))
    end
  end

  @spec bingo_single_step(list(list(number)), number) :: list(list(number))
  defp bingo_single_step(boards, current_draw) do
    boards
    |> Enum.map(fn board ->
      board
      |> Enum.map(fn row ->
        row
        |> Enum.map(fn
          {^current_draw, _} -> {current_draw, true}
          any -> any
        end)
      end)
    end)
  end

  defp is_bingo(board) do
    raw_matched =
      board
      |> Enum.any?(fn row ->
        Enum.all?(row, fn {_, matched?} -> matched? end)
      end)

    col_matched =
      board
      |> Enum.map(fn row ->
        row
        |> Enum.with_index()
        |> Enum.filter(fn {{_value, matched?}, _idx} -> matched? end)
        |> Enum.map(&elem(&1, 1))
        |> MapSet.new()
      end)
      |> Enum.reduce(MapSet.new(0..(@board_size - 1)), fn matched_col, acc ->
        MapSet.intersection(matched_col, acc)
      end)
      |> MapSet.size()
      |> Kernel.>=(1)

    raw_matched or col_matched
  end

  defp sum_of_unmarked(board) do
    board
    |> Enum.map(fn row ->
      row
      |> Enum.reject(fn {_value, matched?} -> matched? end)
      |> Enum.map(&elem(&1, 0))
      |> Enum.sum()
    end)
    |> Enum.sum()
  end
end
