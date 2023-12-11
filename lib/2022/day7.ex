# Advent of Code 2022 Day 7 - No Space Left On Device
# https://adventofcode.com/2022/day/7
# Commentary: https://walnut-today.tistory.com/211

defmodule Aoc2022.Day7 do
  @dir "data/day7/"

  defmodule Fil do
    defstruct [:name, size: 0]
  end

  defmodule Dir do
    defstruct [:name, files: %{}, size: 0]
  end

  def q1(file_name \\ "q.txt") do
    File.read!(@dir <> file_name)
    |> String.split("$ ", trim: true)
    |> Enum.map(&String.trim/1)
    |> build_tree()
    |> Map.to_list()
    |> hd()
    |> calculate_dir_size()
    |> elem(1)
    |> get_dir_list()
    |> find_under_and_sum()
  end

  def q2(file_name \\ "q.txt") do
    entire_tree =
      File.read!(@dir <> file_name)
      |> String.split("$ ", trim: true)
      |> Enum.map(&String.trim/1)
      |> build_tree()
      |> Map.to_list()
      |> hd()
      |> calculate_dir_size()
      |> elem(1)

    current_free_space = (70_000_000 - entire_tree.size) |> IO.inspect()
    to_be_freed = (30_000_000 - current_free_space) |> IO.inspect()

    entire_tree
    |> get_dir_list()
    |> Enum.sort_by(fn %Dir{} = dir -> dir.size end)
    |> Enum.find(fn %Dir{} = dir ->
      dir.size > to_be_freed
    end)
  end

  defp build_tree(command_str_list) do
    command_str_list
    |> Enum.reduce({%{"/" => %Dir{name: "/"}}, ["/"]}, fn command_str, {acc, current_dir} ->
      commands = String.split(command_str, "\n", trim: true)

      operation = hd(commands) |> String.split(" ")

      case operation do
        ["cd", "/"] ->
          {acc, ["/"]}

        ["cd", ".."] ->
          {acc, tl(current_dir)}

        ["cd", dir] ->
          {acc, [dir | current_dir]}

        ["ls"] ->
          contents =
            tl(commands)
            |> Enum.map(&String.split(&1, " "))
            |> Enum.map(fn
              ["dir", dir_name] ->
                {dir_name, %Dir{name: dir_name}}

              [size, file_name] ->
                {file_name, %Fil{name: file_name, size: String.to_integer(size)}}
            end)
            |> Enum.into(%{})

          key =
            Enum.reverse(current_dir)
            |> Enum.intersperse(:files)
            |> Enum.map(fn k -> Access.key(k) end)

          {update_in(acc, key, fn %Dir{} = dir -> %{dir | files: contents} end), current_dir}
      end
    end)
    |> elem(0)
  end

  defp calculate_dir_size({dir_name, %Dir{} = dir}) do
    files =
      Enum.map(dir.files, fn
        {_, %Dir{}} = subdir_tuple ->
          calculate_dir_size(subdir_tuple)

        {_, %Fil{}} = file_tuple ->
          file_tuple
      end)
      |> Enum.into(%{})

    total_size = files |> Enum.map(fn {_, f} -> f.size end) |> Enum.sum()

    {dir_name, %Dir{dir | files: files, size: total_size}}
  end

  defp get_dir_list(%Dir{} = dir) do
    [
      dir
      | dir.files
        |> Enum.flat_map(fn
          {_, %Dir{} = subdir} ->
            get_dir_list(subdir)

          {_, %Fil{}} ->
            []
        end)
    ]
  end

  defp find_under_and_sum(dir_list) do
    dir_list
    |> Enum.filter(fn %Dir{} = d -> d.size <= 100_000 end)
    |> Enum.map(fn %Dir{} = d -> d.size end)
    |> Enum.sum()
  end
end
