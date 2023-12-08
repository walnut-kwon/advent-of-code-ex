# Advent of Code 2021 Day 19 - Beacon Scanner
# https://adventofcode.com/2021/day/19
# Commentary: https://walnut-today.tistory.com/62

defmodule Aoc2021.Day19 do
  def parse_input(file_name \\ "input/day19.txt") do
    file_name
    |> File.read!()
    |> String.split("\n\n")
    |> Enum.map(fn scans ->
      ["--- scanner" <> _ | beacons] = String.split(scans, "\n")

      beacons
      |> Enum.map(fn beacon ->
        String.split(beacon, ",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
    end)
  end

  def run_q1() do
    scanners = parse_input()

    do_run_q1(scanners |> Enum.with_index(), %{})
    |> reduce()
    |> IO.inspect()
    |> Map.values()
    |> hd()
    |> MapSet.size()
  end

  # NOTE: q2 not solved
  def run_q2() do
    scanners = parse_input()

    do_run_q1(scanners |> Enum.with_index(), %{})
  end

  def do_run_q1([_], beacons), do: beacons

  def do_run_q1([{h, h_idx} | t] = _scanners, beacons) do
    new_beacons =
      t
      |> Enum.map(fn {scanner, idx} ->
        # |> IO.inspect()
        res = get_union_when_overlapped(h, scanner)

        if elem(res, 0) do
          IO.inspect("#{h_idx} * #{idx} => #{elem(res, 0)}")
          IO.inspect(MapSet.size(elem(res, 1)))
        end

        {res, idx}
      end)
      |> Enum.filter(fn {{overlapped?, _union}, _idx} -> overlapped? end)
      |> Enum.reduce(beacons, fn {{true, union}, idx}, acc ->
        Map.put(acc, [h_idx, idx], union)
      end)

    do_run_q1(t, new_beacons)
  end

  defp reduce(unions) when map_size(unions) == 1, do: unions

  defp reduce(unions) do
    IO.inspect(DateTime.utc_now())

    first_key =
      Map.keys(unions)
      |> Enum.sort_by(&length/1, :desc)
      |> hd()
      |> IO.inspect(label: "first_key")

    first_key_set = MapSet.new(first_key)

    unions
    |> Enum.filter(fn {k, _v} ->
      has_common_key? =
        MapSet.new(k)
        |> MapSet.intersection(MapSet.new(first_key))
        |> MapSet.size()
        |> Kernel.!=(0)

      k != first_key and has_common_key?
    end)
    |> Enum.sort_by(&length(elem(&1, 0)), :desc)
    |> hd()
    |> tap(fn {k, _v} -> IO.inspect(k) end)
    |> then(fn {k, v} ->
      if MapSet.subset?(MapSet.new(k), first_key_set) do
        unions
        |> Map.delete(k)
      else
        {true, union} =
          Map.get(unions, first_key)
          |> MapSet.to_list()
          |> get_union_when_overlapped(v |> MapSet.to_list())

        unions
        |> Map.delete(first_key)
        |> Map.delete(k)
        |> Map.put(Enum.uniq(k ++ first_key), union)
      end
    end)
    |> reduce()
  end

  defp get_union_when_overlapped(a, b) do
    a = a |> scanner_to_rel_coord()
    b = b |> scanner_to_rel_coord()

    a
    |> Enum.map(fn beacons_a_relative_to_point ->
      overlaps =
        b
        |> Enum.map(fn beacons_b_relative_to_point ->
          0..23
          |> Enum.map(fn orient ->
            beacons_b_relative_to_point
            |> MapSet.to_list()
            |> Enum.map(&orientation(&1, orient))
            |> MapSet.new()
          end)
          |> Enum.find(fn v ->
            MapSet.intersection(beacons_a_relative_to_point, v)
            |> MapSet.size()
            |> Kernel.>=(12)
          end)
        end)
        |> Enum.find(&(not is_nil(&1)))

      if is_nil(overlaps) do
        {false, nil}
      else
        MapSet.intersection(beacons_a_relative_to_point, overlaps) |> IO.inspect()
        {true, MapSet.union(beacons_a_relative_to_point, overlaps)}
      end
    end)
    |> Enum.find({false, nil}, &(elem(&1, 0) == true))
  end

  defp scanner_to_rel_coord(scanner) do
    scanner
    |> List.duplicate(length(scanner))
    |> Enum.zip(scanner)
    |> Enum.map(fn {beacons, base} ->
      Enum.map(beacons, fn beacon -> rel_coord(base, beacon) end)
      |> MapSet.new()
    end)
  end

  defp rel_coord({base_x, base_y, base_z}, {target_x, target_y, target_z}) do
    {target_x - base_x, target_y - base_y, target_z - base_z}
  end

  # +x를 바라보고 회전
  defp orientation({x, y, z}, 0), do: {x, y, z}
  defp orientation({x, y, z}, 1), do: {x, -z, y}
  defp orientation({x, y, z}, 2), do: {x, -y, -z}
  defp orientation({x, y, z}, 3), do: {x, z, -y}

  # -x를 바라보고 회전
  defp orientation({x, y, z}, 4), do: {-x, -y, z}
  defp orientation({x, y, z}, 5), do: {-x, -z, -y}
  defp orientation({x, y, z}, 6), do: {-x, y, -z}
  defp orientation({x, y, z}, 7), do: {-x, z, y}

  # +y를 바라보고 회전
  defp orientation({x, y, z}, 8), do: {y, -x, z}
  defp orientation({x, y, z}, 9), do: {y, z, x}
  defp orientation({x, y, z}, 10), do: {y, x, -z}
  defp orientation({x, y, z}, 11), do: {y, -z, -x}

  # -y를 바라보고 회전
  defp orientation({x, y, z}, 12), do: {-y, x, z}
  defp orientation({x, y, z}, 13), do: {-y, -z, x}
  defp orientation({x, y, z}, 14), do: {-y, -x, -z}
  defp orientation({x, y, z}, 15), do: {-y, z, -x}

  # +z를 바라보고 회전
  defp orientation({x, y, z}, 16), do: {z, y, -x}
  defp orientation({x, y, z}, 17), do: {z, x, y}
  defp orientation({x, y, z}, 18), do: {z, -y, x}
  defp orientation({x, y, z}, 19), do: {z, -x, -y}

  # -z를 바라보고 회전
  defp orientation({x, y, z}, 20), do: {-z, -y, -x}
  defp orientation({x, y, z}, 21), do: {-z, x, -y}
  defp orientation({x, y, z}, 22), do: {-z, y, x}
  defp orientation({x, y, z}, 23), do: {-z, -x, y}
end
