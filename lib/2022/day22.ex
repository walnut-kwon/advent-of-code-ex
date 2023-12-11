# Advent of Code 2022 Day 22 - Monkey Map
# https://adventofcode.com/2022/day/22
# Commentary: https://walnut-today.tistory.com/226

defmodule Aoc2022.Day22 do
  @dir "data/day22/"

  def q1(file_name \\ "q.txt") do
    [map_str, directions_str] =
      File.read!(@dir <> file_name)
      |> String.split("\n\n")

    map = build_map(map_str) |> IO.inspect()
    dir = build_direction(directions_str)

    init_pos = Enum.sort_by(map, fn {k, _v} -> k end) |> hd() |> elem(0) |> IO.inspect()
    init_dir = :right

    IO.puts("Start at #{elem(init_pos, 0)}, #{elem(init_pos, 1)}, direction: #{init_dir}")

    go(map, init_pos, init_dir, dir, :normal)
  end

  def q2(file_name \\ "q.txt") do
    [map_str, directions_str] =
      File.read!(@dir <> file_name)
      |> String.split("\n\n")

    map = build_map(map_str) |> IO.inspect()
    dir = build_direction(directions_str)

    init_pos = Enum.sort_by(map, fn {k, _v} -> k end) |> hd() |> elem(0) |> IO.inspect()
    init_dir = :right

    IO.puts("Start at #{elem(init_pos, 0)}, #{elem(init_pos, 1)}, direction: #{init_dir}")

    go(map, init_pos, init_dir, dir, :cube)
  end

  defp build_map(map_str) do
    String.split(map_str, "\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      String.graphemes(row)
      |> Enum.with_index()
      |> Enum.reject(fn {col, _} -> col == " " end)
      |> Enum.map(fn {col, j} -> {{i + 1, j + 1}, col} end)
    end)
    |> Enum.into(%{})
  end

  defp build_direction(directions_str) do
    Regex.scan(~r/(([0-9]+)(L|R|X))/, directions_str <> "X")
    |> Enum.map(fn [_, _, step, dir] -> {String.to_integer(step), dir} end)
    |> IO.inspect()
  end

  defp go(_map, {row, col}, dir, [], _) do
    dir_point =
      case dir do
        :right -> 0
        :down -> 1
        :left -> 2
        :up -> 3
      end

    row * 1000 + col * 4 + dir_point
  end

  defp go(map, {row, col}, dir, [{0, turn} | t] = _directions, mode) do
    new_dir =
      case {dir, turn} do
        {dir, "X"} -> dir
        {:right, "R"} -> :down
        {:right, "L"} -> :up
        {:left, "R"} -> :up
        {:left, "L"} -> :down
        {:up, "R"} -> :right
        {:up, "L"} -> :left
        {:down, "R"} -> :left
        {:down, "L"} -> :right
      end

    IO.puts("Turn at #{row}, #{col}, new direction: #{new_dir}")

    go(map, {row, col}, new_dir, t, mode)
  end

  defp go(map, {row, col}, dir, [{step, turn} | t] = _directions, mode) do
    next_pos =
      case dir do
        :right -> {row, col + 1}
        :left -> {row, col - 1}
        :up -> {row - 1, col}
        :down -> {row + 1, col}
      end

    step_check_result = step_check(map, next_pos, dir, mode)

    if step_check_result == :rock do
      go(map, {row, col}, dir, [{0, turn} | t], mode)
    else
      {:ok, real_next_pos, real_next_dir} = step_check_result
      go(map, real_next_pos, real_next_dir, [{step - 1, turn} | t], mode)
    end
  end

  defp step_check(map, {row, col} = next_pos, dir, :normal) do
    real_next_pos =
      if Map.has_key?(map, next_pos) do
        next_pos
      else
        case dir do
          :right ->
            Enum.filter(map, fn {{r, _c}, _v} -> r == row end)
            |> Enum.sort_by(fn {k, _v} -> k end)

          :left ->
            Enum.filter(map, fn {{r, _c}, _v} -> r == row end)
            |> Enum.sort_by(fn {k, _v} -> k end, :desc)

          :up ->
            Enum.filter(map, fn {{_r, c}, _v} -> c == col end)
            |> Enum.sort_by(fn {k, _v} -> k end, :desc)

          :down ->
            Enum.filter(map, fn {{_r, c}, _v} -> c == col end)
            |> Enum.sort_by(fn {k, _v} -> k end)
        end
        |> hd()
        |> elem(0)
      end

    if Map.get(map, real_next_pos) == "#" do
      :rock
    else
      {:ok, real_next_pos, dir}
    end
  end

  defp step_check(map, {row, col} = next_pos, dir, :cube) do
    {real_next_pos, real_next_dir} =
      if Map.has_key?(map, next_pos) do
        {next_pos, dir}
      else
        case dir do
          :right ->
            case row do
              v when v in 1..50 -> {{151 - row, 100}, :left}
              v when v in 51..100 -> {{50, row + 50}, :up}
              v when v in 101..150 -> {{151 - row, 150}, :left}
              v when v in 151..200 -> {{150, row - 100}, :up}
            end

          :left ->
            case row do
              v when v in 1..50 -> {{151 - row, 1}, :right}
              v when v in 51..100 -> {{101, row - 50}, :down}
              v when v in 101..150 -> {{151 - row, 51}, :right}
              v when v in 151..200 -> {{1, row - 100}, :down}
            end

          :up ->
            case col do
              v when v in 1..50 -> {{col + 50, 51}, :right}
              v when v in 51..100 -> {{col + 100, 1}, :right}
              v when v in 101..150 -> {{200, col - 100}, :up}
            end

          :down ->
            case col do
              v when v in 1..50 -> {{1, col + 100}, :down}
              v when v in 51..100 -> {{col + 100, 50}, :left}
              v when v in 101..150 -> {{col - 50, 100}, :left}
            end
        end
      end

    if Map.get(map, real_next_pos) == "#" do
      :rock
    else
      {:ok, real_next_pos, real_next_dir}
    end
  end
end
