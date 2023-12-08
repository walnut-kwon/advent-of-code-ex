# Advent of Code 2021 Day 12 - Passage Pathing
# https://adventofcode.com/2021/day/12
# Commentary: https://walnut-today.tistory.com/53

defmodule Aoc2021.Day12 do
  def parse_input do
    "input/day12.txt"
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(fn r ->
      r
      |> String.split("-")
    end)
  end

  def run_q1() do
    caves = parse_input()

    [["start"]]
    |> do_run(caves, :q1)
    |> length()
  end

  def run_q2() do
    caves = parse_input()

    [["start"]]
    |> do_run(caves, :q2)
    |> length()
  end

  defp do_run(paths, caves, q) do
    if Enum.all?(paths, fn [endpoint | _] -> endpoint == "end" end) do
      paths
    else
      paths
      |> Enum.map(fn path -> move_ahead(path, caves, q) end)
      |> flat_single_depth()
      |> do_run(caves, q)
    end
  end

  defp move_ahead(["end" | _] = path, _caves, _), do: [path]

  defp move_ahead(path, caves, q) do
    visitable_caves =
      path
      |> visitable_caves(caves, q)

    if visitable_caves == [] do
      []
    else
      visitable_caves
      |> Enum.map(fn p ->
        [p | path]
      end)
    end
  end

  defp visitable_caves([from | _] = path, caves, q) do
    caves
    |> Enum.filter(fn [s, t] ->
      (s == from and visitable?(t, path, q)) or
        (t == from and visitable?(s, path, q))
    end)
    |> Enum.map(fn
      [^from, t] -> t
      [s, ^from] -> s
    end)
  end

  defp visitable?("start", _path, _), do: false

  defp visitable?(cave, path, :q1) do
    if not small_cave?(cave) do
      true
    else
      if cave not in path do
        true
      else
        false
      end
    end
  end

  defp visitable?(cave, path, :q2) do
    if not small_cave?(cave) do
      true
    else
      if cave not in path do
        true
      else
        has_twice_visited =
          path
          |> Enum.filter(&small_cave?/1)
          |> Enum.frequencies()
          |> Map.values()
          |> Enum.any?(&(&1 == 2))

        if has_twice_visited do
          false
        else
          true
        end
      end
    end
  end

  defp small_cave?(cave), do: String.downcase(cave) == cave

  defp flat_single_depth(list) do
    Enum.reduce(list, [], fn sublist, acc -> sublist ++ acc end)
  end
end
