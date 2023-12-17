# Advent of Code 2023 Day 10 - Pipe Maze
# https://adventofcode.com/2023/day/10

defmodule Aoc2023.Day10 do
  @dir "input/2023/"

  def q1(file_name \\ "day10.txt") do
    map =
      File.read!(@dir <> file_name)
      |> parse_map()

    {s_point, "S"} = Enum.find(map, fn {_k, v} -> v == "S" end)
    s_type = find_s_type(map, s_point)

    map = Map.put(map, s_point, s_type)
    loop = find_loop(map, s_point, [s_point])

    div(length(loop), 2)
  end

  def q2(file_name \\ "day10.txt") do
    map =
      File.read!(@dir <> file_name)
      |> parse_map()

    {s_point, "S"} = Enum.find(map, fn {_k, v} -> v == "S" end)
    s_type = find_s_type(map, s_point)

    map = Map.put(map, s_point, s_type)
    loop = find_loop(map, s_point, [s_point])

    width = Enum.filter(map, fn {{_x, y}, _} -> y == 0 end) |> length()
    height = Enum.filter(map, fn {{x, _y}, _} -> x == 0 end) |> length()

    # NOTE
    # Loop의 안쪽에서는 바깥으로 나가는 데에 반드시 홀수 개의 파이프와 교차해야 함
    # 따라서 동서남북으로 나누어 교차하는 파이프 수를 세되,
    # 꺾인 파이프(L 등)은 두 방향을 절반씩만 커버하므로 이를 분리해서 세기
    # 예를 들어, 북쪽으로 나가려고 할 때 북동쪽으로 나가서 교차하는 경우(L, F)와
    # 북서쪽으로 나가서 교차하는 경우(J, 7)를 분리해서 세어야 함

    0..(height - 1)
    |> Enum.flat_map(fn y ->
      0..(width - 1)
      |> Enum.filter(fn x ->
        if {x, y} in loop do
          false
        else
          north_east_pipes =
            Enum.count(loop, fn {p_x, p_y} ->
              p_x == x and p_y < y and map[{p_x, p_y}] in ["L", "F", "-"]
            end)

          north_west_pipes =
            Enum.count(loop, fn {p_x, p_y} ->
              p_x == x and p_y < y and map[{p_x, p_y}] in ["J", "7", "-"]
            end)

          south_east_pipes =
            Enum.count(loop, fn {p_x, p_y} ->
              p_x == x and p_y > y and map[{p_x, p_y}] in ["L", "F", "-"]
            end)

          south_west_pipes =
            Enum.count(loop, fn {p_x, p_y} ->
              p_x == x and p_y > y and map[{p_x, p_y}] in ["J", "7", "-"]
            end)

          west_north_pipes =
            Enum.count(loop, fn {p_x, p_y} ->
              p_x < x and p_y == y and map[{p_x, p_y}] in ["L", "J", "|"]
            end)

          west_south_pipes =
            Enum.count(loop, fn {p_x, p_y} ->
              p_x < x and p_y == y and map[{p_x, p_y}] in ["F", "7", "|"]
            end)

          east_north_pipes =
            Enum.count(loop, fn {p_x, p_y} ->
              p_x > x and p_y == y and map[{p_x, p_y}] in ["L", "J", "|"]
            end)

          east_south_pipes =
            Enum.count(loop, fn {p_x, p_y} ->
              p_x > x and p_y == y and map[{p_x, p_y}] in ["F", "7", "|"]
            end)

          if rem(north_east_pipes, 2) == 1 and rem(north_west_pipes, 2) == 1 and
               rem(south_east_pipes, 2) == 1 and rem(south_west_pipes, 2) == 1 and
               rem(west_north_pipes, 2) == 1 and rem(west_south_pipes, 2) == 1 and
               rem(east_north_pipes, 2) == 1 and rem(east_south_pipes, 2) == 1 do
            true
          else
            false
          end
        end
      end)
      |> Enum.map(fn x -> {x, y} end)
    end)
    |> length()
  end

  defp parse_map(file_content) do
    file_content
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {line, y} ->
      line
      |> String.graphemes()
      |> Enum.with_index()
      |> Enum.map(fn {c, x} ->
        {{x, y}, c}
      end)
    end)
    |> Map.new()
  end

  defp find_s_type(map, {x, y}) do
    west? = Map.has_key?(map, {x - 1, y}) and map[{x - 1, y}] in ["-", "L", "F"]
    east? = Map.has_key?(map, {x + 1, y}) and map[{x + 1, y}] in ["-", "J", "7"]
    north? = Map.has_key?(map, {x, y - 1}) and map[{x, y - 1}] in ["|", "7", "F"]
    south? = Map.has_key?(map, {x, y + 1}) and map[{x, y + 1}] in ["|", "L", "J"]

    cond do
      north? and south? -> "|"
      north? and west? -> "J"
      north? and east? -> "L"
      south? and west? -> "7"
      south? and east? -> "F"
      west? and east? -> "-"
      true -> "."
    end
  end

  defp find_loop(_map, starting_point, [starting_point, _ | _] = loop) do
    loop
  end

  defp find_loop(map, starting_point, [{x, y} = point | _] = loop) do
    next_point_candidates =
      case map[point] do
        "|" -> [{x, y - 1}, {x, y + 1}]
        "-" -> [{x - 1, y}, {x + 1, y}]
        "L" -> [{x + 1, y}, {x, y - 1}]
        "J" -> [{x - 1, y}, {x, y - 1}]
        "7" -> [{x - 1, y}, {x, y + 1}]
        "F" -> [{x + 1, y}, {x, y + 1}]
      end

    next_point = Enum.find(next_point_candidates, fn p -> p not in loop end)

    if is_nil(next_point) do
      loop
    else
      find_loop(map, starting_point, [next_point | loop])
    end
  end
end
