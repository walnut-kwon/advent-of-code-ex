# Advent of Code 2022 Day 17 - Pyroclastic Flow
# https://adventofcode.com/2022/day/17
# Commentary: https://walnut-today.tistory.com/221

defmodule Aoc2022.Day17 do
  @dir "data/day17/"

  defmodule Block do
    defstruct [:x, :y, :type]
  end

  @chamber_width 7
  @block_width %{
    0 => 4,
    1 => 3,
    2 => 3,
    3 => 1,
    4 => 2
  }
  @block_height %{
    0 => 1,
    1 => 3,
    2 => 3,
    3 => 4,
    4 => 2
  }

  def q1(file_name \\ "q.txt", target_block_count \\ 2022) do
    File.read!(@dir <> file_name)
    |> String.graphemes()
    |> Stream.cycle()
    |> Enum.reduce_while(
      {0, %Block{x: 2, y: 3, type: 0}, List.duplicate(MapSet.new([-1]), @chamber_width)},
      fn
        jet, {block_count, block, chamber} ->
          # IO.write(jet)

          if block.y < -1 do
            Kernel.exit(0)
          end

          {res, block} =
            block
            |> move(jet, chamber)
            # |> IO.inspect()
            |> fall(chamber)

          # |> IO.inspect()

          # IO.inspect(chamber)

          if res == :rest do
            new_chamber = rest(block, chamber) |> prune_chamber()
            max_height = new_chamber |> Enum.map(&Enum.max(&1)) |> Enum.max()

            if block_count + 1 == target_block_count do
              {:halt, new_chamber}
            else
              # IO.inspect(new_chamber)
              # IO.write(":: #{inspect(new_chamber)}\n")

              new_block = %Block{
                x: 2,
                y: max_height + @block_height[next_block(block)] + 3,
                type: next_block(block)
              }

              {:cont, {block_count + 1, new_block, new_chamber}}
            end
          else
            {:cont, {block_count, block, chamber}}
          end
      end
    )
    |> IO.inspect()
    |> Enum.map(&Enum.max(&1))
    |> Enum.max()
    |> Kernel.+(1)
  end

  def q2(file_name \\ "q.txt", target_block_count \\ 1_000_000_000_000) do
    cycle = 1745
    cycle_start = 805
    height_gap = 2738
    _height_start = 1261

    cycle_count = div(target_block_count - cycle_start, cycle) |> IO.inspect(label: "cycle_count")
    cycle_rem = rem(target_block_count - cycle_start, cycle) |> IO.inspect(label: "cycle_rem")

    height_gap * cycle_count + q1(file_name, cycle_start + cycle_rem)
  end

  defp move(block, jet, chamber) do
    if movable?(block, jet, chamber) do
      case jet do
        ">" -> %{block | x: block.x + 1}
        "<" -> %{block | x: block.x - 1}
      end
    else
      block
    end
  end

  @spec chamber_column(list(MapSet.t()), integer()) :: MapSet.t()
  defp chamber_column(chamber, index) when is_integer(index) do
    Enum.at(chamber, index)
  end

  @spec chamber_column(list(MapSet.t()), Range.t()) :: MapSet.t()
  defp chamber_column(chamber, a..b) do
    Enum.slice(chamber, a..b)
  end

  defp movable?(%Block{x: x, type: type} = b, ">", chamber) do
    x < @chamber_width - @block_width[type] and type_movable?(b, ">", chamber)
  end

  defp movable?(%Block{x: x} = b, "<", chamber) do
    x > 0 and type_movable?(b, "<", chamber)
  end

  defp type_movable?(%Block{x: x, y: y, type: 0}, ">", chamber) do
    not (chamber_column(chamber, x + @block_width[0]) |> MapSet.member?(y))
  end

  defp type_movable?(%Block{x: x, y: y, type: 1}, ">", chamber) do
    not (chamber_column(chamber, x + 2) |> MapSet.member?(y)) and
      not (chamber_column(chamber, x + 3) |> MapSet.member?(y - 1)) and
      not (chamber_column(chamber, x + 2) |> MapSet.member?(y - 2))
  end

  defp type_movable?(%Block{x: x, y: y, type: 2}, ">", chamber) do
    column = chamber_column(chamber, x + @block_width[2])
    (y - 2)..y |> Enum.all?(&(not MapSet.member?(column, &1)))
  end

  defp type_movable?(%Block{x: x, y: y, type: 3}, ">", chamber) do
    column = chamber_column(chamber, x + @block_width[3])
    (y - 3)..y |> Enum.all?(&(not MapSet.member?(column, &1)))
  end

  defp type_movable?(%Block{x: x, y: y, type: 4}, ">", chamber) do
    column = chamber_column(chamber, x + @block_width[4])
    (y - 1)..y |> Enum.all?(&(not MapSet.member?(column, &1)))
  end

  defp type_movable?(%Block{x: x, y: y, type: 0}, "<", chamber) do
    not (chamber_column(chamber, x - 1) |> MapSet.member?(y))
  end

  defp type_movable?(%Block{x: x, y: y, type: 1}, "<", chamber) do
    not (chamber_column(chamber, x) |> MapSet.member?(y)) and
      not (chamber_column(chamber, x - 1) |> MapSet.member?(y - 1)) and
      not (chamber_column(chamber, x) |> MapSet.member?(y - 2))
  end

  defp type_movable?(%Block{x: x, y: y, type: 2}, "<", chamber) do
    not (chamber_column(chamber, x + 1) |> MapSet.member?(y)) and
      not (chamber_column(chamber, x + 1) |> MapSet.member?(y - 1)) and
      not (chamber_column(chamber, x - 1) |> MapSet.member?(y - 2))
  end

  defp type_movable?(%Block{x: x, y: y, type: 3}, "<", chamber) do
    column = chamber_column(chamber, x - 1)
    (y - 3)..y |> Enum.all?(&(not MapSet.member?(column, &1)))
  end

  defp type_movable?(%Block{x: x, y: y, type: 4}, "<", chamber) do
    column = chamber_column(chamber, x - 1)
    (y - 1)..y |> Enum.all?(&(not MapSet.member?(column, &1)))
  end

  defp fall(block, chamber) do
    new_block = %{block | y: block.y - 1}

    if rest?(new_block, chamber) do
      {:rest, block}
    else
      {:ok, new_block}
    end
  end

  defp rest?(%Block{x: x, y: y, type: 0}, chamber) do
    Enum.slice(chamber, x..(x + 3))
    |> Enum.flat_map(&Enum.filter(&1, fn v -> v <= y end))
    |> Enum.max()
    |> Kernel.==(y)
  end

  defp rest?(%Block{x: x, y: y, type: 1}, chamber) do
    chamber_column(chamber, x) |> Enum.filter(fn v -> v <= y - 1 end) |> Enum.max() == y - 1 or
      chamber_column(chamber, x + 1) |> Enum.filter(fn v -> v <= y - 2 end) |> Enum.max() == y - 2 or
      chamber_column(chamber, x + 2) |> Enum.filter(fn v -> v <= y - 1 end) |> Enum.max() == y - 1
  end

  defp rest?(%Block{x: x, y: y, type: 2}, chamber) do
    chamber_column(chamber, x..(x + 2))
    |> Enum.flat_map(&Enum.filter(&1, fn v -> v <= y - 2 end))
    |> Enum.max()
    |> Kernel.==(y - 2)
  end

  defp rest?(%Block{x: x, y: y, type: 3}, chamber) do
    chamber_column(chamber, x)
    |> Enum.filter(fn v -> v <= y - 3 end)
    |> Enum.max()
    |> Kernel.==(y - 3)
  end

  defp rest?(%Block{x: x, y: y, type: 4}, chamber) do
    chamber_column(chamber, x..(x + 1))
    |> Enum.flat_map(&Enum.filter(&1, fn v -> v <= y - 1 end))
    |> Enum.max()
    |> Kernel.==(y - 1)
  end

  defp rest(%Block{x: x, y: y, type: type} = _block, chamber) do
    # IO.inspect(block)

    pre =
      if x == 0,
        do: [],
        else: chamber_column(chamber, 0..(x - 1)//1)

    # |> IO.inspect(label: "pre")

    post = chamber_column(chamber, (x + @block_width[type])..(@chamber_width - 1)//1)
    # |> IO.inspect(label: "post")

    mid = chamber_column(chamber, x..(x + @block_width[type] - 1))

    new_mid =
      case type do
        0 ->
          mid |> Enum.map(fn column -> MapSet.put(column, y) end)

        1 ->
          [
            MapSet.put(Enum.at(mid, 0), y - 1),
            MapSet.union(Enum.at(mid, 1), MapSet.new(y..(y - 2))),
            MapSet.put(Enum.at(mid, 2), y - 1)
          ]

        2 ->
          [
            MapSet.put(Enum.at(mid, 0), y - 2),
            MapSet.put(Enum.at(mid, 1), y - 2),
            MapSet.union(Enum.at(mid, 2), MapSet.new(y..(y - 2)))
          ]

        3 ->
          Enum.map(mid, fn column -> MapSet.union(column, MapSet.new(y..(y - 3))) end)

        4 ->
          Enum.map(mid, fn column -> MapSet.union(column, MapSet.new(y..(y - 1))) end)
      end

    pre ++ new_mid ++ post
  end

  defp next_block(%Block{type: type}) do
    rem(type + 1, 5)
  end

  defp prune_chamber(chamber) do
    min_of_max_value = chamber |> Enum.map(&Enum.max/1) |> Enum.min()

    Enum.map(chamber, fn %MapSet{} = column ->
      column |> MapSet.to_list() |> Enum.reject(&(&1 < min_of_max_value)) |> MapSet.new()
    end)
  end
end
