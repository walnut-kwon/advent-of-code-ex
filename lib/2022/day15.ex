# Advent of Code 2022 Day 15 - Beacon Exclusion Zone
# https://adventofcode.com/2022/day/15
# Commentary: https://walnut-today.tistory.com/219

defmodule Aoc2022.Day15 do
  @dir "data/day15/"

  defmodule Sensor do
    defstruct [:sensor_x, :sensor_y, :beacon_x, :beacon_y, :distance]
  end

  def q1(file_name \\ "q.txt", y \\ 2_000_000) do
    sensors = build_sensors(file_name)

    min_x =
      sensors
      |> Enum.map(fn %Sensor{} = map -> map.sensor_x - map.distance end)
      |> Enum.min()
      |> IO.inspect(label: "min x")

    max_x =
      sensors
      |> Enum.map(fn %Sensor{} = map -> map.sensor_x + map.distance end)
      |> Enum.max()
      |> IO.inspect(label: "max x")

    min_x..max_x
    |> Enum.map(fn x ->
      sensors
      |> Enum.any?(fn %Sensor{} = map ->
        {map.beacon_x, map.beacon_y} != {x, y} and
          abs(map.sensor_x - x) + abs(map.sensor_y - y) <= map.distance
      end)
    end)
    |> Enum.count(fn v -> v end)
  end

  def q2(file_name \\ "q.txt", max_x_y \\ 4_000_000) do
    sensors = build_sensors(file_name)

    0..max_x_y
    |> Enum.find_value(fn y ->
      if rem(y, 1_000) == 0 do
        IO.puts("starting processing y=#{y}")
      end

      process(0, y, sensors, max_x_y)
      # |> IO.inspect(label: y)
      |> then(fn
        nil -> nil
        x -> {x, y}
      end)
    end)
    |> then(fn {x, y} ->
      IO.inspect(x, label: "x")
      IO.inspect(y, label: "y")
      x * 4_000_000 + y
    end)
  end

  defp process(x, _y, _, max_x_y) when x > max_x_y, do: nil

  defp process(x, y, sensors, max_x_y) do
    sensors
    |> Enum.find_value(fn %Sensor{} = map ->
      y_distance = abs(map.sensor_y - y)
      offset = map.distance - y_distance

      if offset >= 0 and x in (map.sensor_x - offset)..(map.sensor_x + offset) do
        map.sensor_x + offset + 1
      else
        nil
      end
    end)
    |> then(fn
      nil -> x
      new_x -> process(new_x, y, sensors, max_x_y)
    end)
  end

  defp build_sensors(file_name) do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.map(fn line ->
      [_, sensor_x, sensor_y, beacon_x, beacon_y] =
        Regex.run(
          ~r/^Sensor at x=(-?[0-9]+), y=(-?[0-9]+)\: closest beacon is at x=(-?[0-9]+), y=(-?[0-9]+)$/,
          line
        )

      %Sensor{
        sensor_x: String.to_integer(sensor_x),
        sensor_y: String.to_integer(sensor_y),
        beacon_x: String.to_integer(beacon_x),
        beacon_y: String.to_integer(beacon_y)
      }
      |> then(fn map ->
        Map.put(
          map,
          :distance,
          abs(map.sensor_x - map.beacon_x) + abs(map.sensor_y - map.beacon_y)
        )
      end)
    end)
  end
end
