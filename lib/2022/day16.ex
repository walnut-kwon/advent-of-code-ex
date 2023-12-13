# Advent of Code 2022 Day 16 - Proboscidea Volcanium
# https://adventofcode.com/2022/day/16
# Commentary: https://walnut-today.tistory.com/220

defmodule Aoc2022.Day16 do
  @dir "data/day16/"

  defmodule Action do
    defstruct [:current, :destination, :next_action_min]
  end

  def q1(file_name \\ "q.txt") do
    valve_map = build_valve_map(file_name)
    distance_map = build_distance_map(valve_map)

    move(
      valve_map,
      distance_map,
      30,
      %Action{current: "AA", next_action_min: 30},
      nil,
      0,
      %{}
    )
  end

  def q2(file_name \\ "q.txt") do
    valve_map = build_valve_map(file_name)
    distance_map = build_distance_map(valve_map)

    move(
      valve_map,
      distance_map,
      26,
      %Action{current: "AA", next_action_min: 26},
      %Action{current: "AA", next_action_min: 26},
      0,
      %{}
    )
  end

  defp build_valve_map(file_name) do
    File.read!(@dir <> file_name)
    |> String.split("\n", trim: true)
    |> Map.new(fn line ->
      [_, valve_name, rate, _, lead_to] =
        Regex.run(
          ~r/^Valve ([A-Z]+) has flow rate=([0-9]+); (tunnels lead to valves|tunnel leads to valve) (.*)$/,
          line
        )

      {valve_name, %{rate: String.to_integer(rate), lead_to: lead_to |> String.split(", ")}}
    end)
  end

  defp build_distance_map(valve_map) do
    has_flows =
      valve_map
      |> Map.filter(fn {_k, v} -> v.rate > 0 end)
      |> Map.keys()
      |> Kernel.++(["AA"])

    has_flows
    |> Map.new(fn k ->
      {k, Map.new(has_flows, fn d -> {d, get_distance(valve_map, k, d)} end)}
    end)
  end

  defp move(_, _, min_last, _, _, total_flow, _) when min_last <= 0, do: total_flow

  defp move(
         valve_map,
         distance_map,
         min_last,
         human = %Action{current: current, next_action_min: min_last},
         elephant,
         total_flow,
         opened
       ) do
    candidates =
      valve_map
      |> Map.filter(fn {k, v} -> v.rate > 0 and not Map.has_key?(opened, k) end)
      |> Map.map(fn {k, v} ->
        # IO.inspect("#{current} #{k}")

        v
        |> Map.put(:distance, distance_map[current][k])
        |> Map.put(:score, (min_last - distance_map[current][k]) * v.rate)
      end)
      |> Map.filter(fn {_k, v} -> v.score > 0 end)
      |> Enum.sort_by(fn {_k, v} -> v.score end, :desc)

    if candidates == [] do
      total_flow
      |> IO.inspect(label: "opened")
    else
      candidates
      |> Enum.filter(fn {_k, v} ->
        v.score >= elem(hd(candidates), 1).score / 3
      end)
      |> tap(fn cand ->
        opened
        |> Enum.sort_by(fn {_k, v} -> v end, :desc)
        |> IO.inspect(label: "opened")

        cand
        |> Enum.map(fn {k, v} -> {k, Map.take(v, [:distance, :rate, :score])} end)
        |> IO.inspect(label: "#{min_last} minutes last")
      end)
      |> Enum.map(fn {k, v} ->
        move(
          valve_map,
          distance_map,
          min_last,
          human
          |> Map.merge(%{current: k, destination: k, next_action_min: min_last - v.distance}),
          elephant,
          total_flow + v.score,
          Map.put(opened, k, "H#{min_last - v.distance}")
        )
      end)
      |> Enum.max()
    end
  end

  defp move(
         valve_map,
         distance_map,
         min_last,
         human,
         elephant = %Action{current: current, next_action_min: min_last},
         total_flow,
         opened
       ) do
    candidates =
      valve_map
      |> Map.filter(fn {k, v} -> v.rate > 0 and not Map.has_key?(opened, k) end)
      |> Map.map(fn {k, v} ->
        # IO.inspect("#{current} #{k}")

        v
        |> Map.put(:distance, distance_map[current][k])
        |> Map.put(:score, (min_last - distance_map[current][k]) * v.rate)
      end)
      |> Map.filter(fn {_k, v} -> v.score > 0 end)
      |> Enum.sort_by(fn {_k, v} -> v.score end, :desc)

    if candidates == [] do
      total_flow
      |> IO.inspect(label: "opened")
    else
      candidates
      |> Enum.filter(fn {_k, v} ->
        v.score >= elem(hd(candidates), 1).score / 2
      end)
      |> tap(fn cand ->
        opened
        |> Enum.sort_by(fn {_k, v} -> v end, :desc)
        |> IO.inspect(label: "opened")

        cand
        |> Enum.map(fn {k, v} -> {k, Map.take(v, [:distance, :rate, :score])} end)
        |> IO.inspect(label: "#{min_last} minutes last")
      end)
      |> Enum.map(fn {k, v} ->
        move(
          valve_map,
          distance_map,
          min_last,
          human,
          elephant
          |> Map.merge(%{current: k, destination: k, next_action_min: min_last - v.distance}),
          total_flow + v.score,
          Map.put(opened, k, "E#{min_last - v.distance}")
        )
      end)
      |> Enum.max()
    end
  end

  defp move(
         value_map,
         distance_map,
         min_last,
         human,
         elephant,
         total_flow,
         opened
       ) do
    move(
      value_map,
      distance_map,
      min_last - 1,
      human,
      elephant,
      total_flow,
      opened
    )
  end

  defp get_distance(_valve_map, from, from), do: 0

  defp get_distance(valve_map, from, dest) do
    do_get_distance(valve_map, [[from]], dest)
  end

  defp do_get_distance(valve_map, pathes, dest) do
    new_pathes =
      pathes
      |> Enum.flat_map(fn path ->
        valve_map[hd(path)].lead_to
        |> Enum.map(fn l ->
          [l | path]
        end)
      end)

    if Enum.any?(new_pathes, fn path -> hd(path) == dest end) do
      hd(new_pathes) |> length()
    else
      do_get_distance(valve_map, new_pathes, dest)
    end
  end
end
