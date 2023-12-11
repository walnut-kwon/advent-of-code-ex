# Advent of Code 2022 Day 23 - Unstable Diffusion
# https://adventofcode.com/2022/day/23
# Commentary: https://walnut-today.tistory.com/227

defmodule Aoc2022.Day23 do
  @dir "data/day23/"

  def q1(file_name \\ "q.txt", round_count \\ 10) do
    elves = build_elves_mapset(file_name)

    policy = [:n, :s, :w, :e]

    1..round_count
    |> Enum.reduce({elves, policy}, fn _, {acc_elves, acc_policy} ->
      {round(acc_elves, acc_policy), tl(acc_policy) ++ [hd(acc_policy)]}
    end)
    |> elem(0)
    |> found_empty_tile()
  end

  def q2(file_name \\ "q.txt") do
    elves = build_elves_mapset(file_name)

    policy = [:n, :s, :w, :e]

    infinite_round(elves, policy, 1)
    |> tap(fn {_, round_count} -> IO.puts("Stopped at round #{round_count}") end)
    |> elem(1)
  end

  defp build_elves_mapset(file_name) do
    File.read!(@dir <> file_name)
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, i} ->
      String.graphemes(row)
      |> Enum.with_index()
      |> Enum.filter(fn {v, _} -> v == "#" end)
      |> Enum.map(fn {_col, j} -> {i, j} end)
    end)
    |> MapSet.new()
  end

  defp infinite_round(elves, policy, round_count) do
    new_elves = round(elves, policy)

    if elves == new_elves do
      {elves, round_count}
    else
      infinite_round(new_elves, tl(policy) ++ [hd(policy)], round_count + 1)
    end
  end

  defp round(elves, policy) do
    proposal =
      Enum.reduce(elves, %{}, fn elf, acc ->
        # |> IO.inspect(label: "movable_dir")
        movable_dir = Enum.find(policy, &movable?(elves, &1, elf))

        elf_new_pos =
          if not is_nil(movable_dir) do
            move(movable_dir, elf)
          else
            elf
          end

        # IO.puts(inspect(elf) <> " moves to " <> inspect(elf_new_pos))

        acc
        |> Map.update(elf_new_pos, [elf], fn e -> [elf | e] end)

        # |> IO.inspect(label: inspect(elf))
      end)

    proposal
    |> Enum.flat_map(fn {new_pos, old_pos_list} ->
      if length(old_pos_list) == 1 do
        [new_pos]
      else
        old_pos_list
      end
    end)
    |> MapSet.new()
  end

  defp movable?(elves, dir, {row, col} = _elf) do
    alone? =
      not MapSet.member?(elves, {row - 1, col - 1}) and
        not MapSet.member?(elves, {row - 1, col}) and
        not MapSet.member?(elves, {row - 1, col + 1}) and
        not MapSet.member?(elves, {row + 1, col - 1}) and
        not MapSet.member?(elves, {row + 1, col}) and
        not MapSet.member?(elves, {row + 1, col + 1}) and
        not MapSet.member?(elves, {row, col - 1}) and
        not MapSet.member?(elves, {row, col + 1})

    if alone? do
      false
    else
      case dir do
        :n ->
          not MapSet.member?(elves, {row - 1, col - 1}) and
            not MapSet.member?(elves, {row - 1, col}) and
            not MapSet.member?(elves, {row - 1, col + 1})

        :s ->
          not MapSet.member?(elves, {row + 1, col - 1}) and
            not MapSet.member?(elves, {row + 1, col}) and
            not MapSet.member?(elves, {row + 1, col + 1})

        :w ->
          not MapSet.member?(elves, {row - 1, col - 1}) and
            not MapSet.member?(elves, {row, col - 1}) and
            not MapSet.member?(elves, {row + 1, col - 1})

        :e ->
          not MapSet.member?(elves, {row - 1, col + 1}) and
            not MapSet.member?(elves, {row, col + 1}) and
            not MapSet.member?(elves, {row + 1, col + 1})
      end
    end
  end

  defp move(dir, {row, col} = _elf) do
    case dir do
      :n -> {row - 1, col}
      :s -> {row + 1, col}
      :w -> {row, col - 1}
      :e -> {row, col + 1}
    end
  end

  defp found_empty_tile(elves) do
    min_row = Enum.min_by(elves, fn {row, _col} -> row end) |> elem(0)
    max_row = Enum.max_by(elves, fn {row, _col} -> row end) |> elem(0)
    min_col = Enum.min_by(elves, fn {_row, col} -> col end) |> elem(1)
    max_col = Enum.max_by(elves, fn {_row, col} -> col end) |> elem(1)

    min_row..max_row
    |> Enum.map(fn row ->
      min_col..max_col
      |> Enum.count(fn col -> not MapSet.member?(elves, {row, col}) end)
    end)
    |> Enum.sum()
  end
end
