# Advent of Code 2022 Day 24 - Blizzard Basin
# https://adventofcode.com/2022/day/24
# Commentary: https://walnut-today.tistory.com/228

defmodule Aoc2022.Day24 do
  @dir "data/day24/"

  def q1(file_name \\ "q.txt") do
    {map, map_width, map_height} = build_map(file_name)

    run(map, [{0, 1}], {map_height - 1, map_width - 2}, map_width, map_height, 0)
    |> elem(1)
  end

  def q2(file_name \\ "q.txt") do
    {map, map_width, map_height} = build_map(file_name)

    {new_map, min1} =
      run(map, [{0, 1}], {map_height - 1, map_width - 2}, map_width, map_height, 0)

    {new_map, min2} =
      run(new_map, [{map_height - 1, map_width - 2}], {0, 1}, map_width, map_height, 0)

    {_new_map, min3} =
      run(new_map, [{0, 1}], {map_height - 1, map_width - 2}, map_width, map_height, 0)

    min1 + min2 + min3
  end

  defp build_map(file_name) do
    str =
      File.read!(@dir <> file_name)
      |> String.split("\n")

    map =
      str
      |> Enum.with_index()
      |> Enum.flat_map(fn {row, i} ->
        String.graphemes(row)
        |> Enum.with_index()
        |> Enum.reject(fn {v, _} -> v == "." end)
        |> Enum.map(fn {col, j} -> {{i, j}, [col]} end)
      end)
      |> Map.new()

    map_width = hd(str) |> String.length()
    map_height = length(str)

    {map, map_width, map_height}
  end

  defp run(map, current_positions, target, map_width, map_height, minutes) do
    if target in current_positions or minutes >= 1000 do
      {map, minutes}
    else
      new_map = move_blizzard(map, map_width, map_height)

      new_positions =
        current_positions
        |> Enum.flat_map(fn current_pos ->
          get_candidates(new_map, current_pos, map_width, map_height)
        end)
        |> Enum.uniq()

      run(new_map, new_positions, target, map_width, map_height, minutes + 1)
    end
  end

  defp move_blizzard(map, map_width, map_height) do
    Enum.reduce(map, %{}, fn {{row, col}, dirs} = _bliz, acc ->
      Enum.reduce(dirs, acc, fn dir, acc2 ->
        case dir do
          "#" ->
            {row, col}

          ">" ->
            if Map.get(map, {row, col + 1}) == ["#"] do
              {row, 1}
            else
              {row, col + 1}
            end

          "<" ->
            if Map.get(map, {row, col - 1}) == ["#"] do
              {row, map_width - 2}
            else
              {row, col - 1}
            end

          "^" ->
            if Map.get(map, {row - 1, col}) == ["#"] do
              {map_height - 2, col}
            else
              {row - 1, col}
            end

          "v" ->
            if Map.get(map, {row + 1, col}) == ["#"] do
              {1, col}
            else
              {row + 1, col}
            end
        end
        |> then(fn new_pos ->
          Map.update(acc2, new_pos, [dir], fn v -> [dir | v] end)
        end)
      end)
    end)
  end

  defp get_candidates(map, {row, col} = current_pos, map_width, map_height) do
    [current_pos, {row - 1, col}, {row + 1, col}, {row, col - 1}, {row, col + 1}]
    |> Enum.reject(fn {r, c} -> r < 0 or c < 0 or r >= map_height or c >= map_width end)
    |> Enum.filter(fn {r, c} -> not Map.has_key?(map, {r, c}) end)
  end
end
