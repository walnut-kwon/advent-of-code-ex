# Advent of Code 2021 Day 20 - Trench Map
# https://adventofcode.com/2021/day/20
# Commentary: https://walnut-today.tistory.com/63

defmodule Aoc2021.Day20 do
  def parse_input(file_name) do
    [algorithm, original_image] =
      file_name
      |> File.read!()
      |> String.split("\n\n")

    original_image =
      original_image
      |> String.split("\n")
      |> Enum.map(&String.codepoints/1)

    image_map = original_image |> nested_list_to_map()

    w = original_image |> hd() |> length()
    h = original_image |> length()

    {algorithm, image_map, w, h}
  end

  defp nested_list_to_map(nested_list) do
    nested_list
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, row_index} ->
      row
      |> Enum.with_index()
      |> Enum.map(fn {val, col_index} ->
        {{col_index, row_index}, val}
      end)
    end)
    |> Enum.into(%{})
  end

  def run_q1(file_name \\ "input/day20.txt", count) do
    {algorithm, image_map, width, height} = parse_input(file_name)

    offset = 3

    {result_image, w_s..w_e, h_s..h_e} =
      do_run_q1(
        algorithm,
        image_map,
        (0 - offset)..(width + offset - 1),
        (0 - offset)..(height + offset - 1),
        count
      )

    # |> IO.inspect()

    resulting_w_range = (w_s + offset)..(w_e - offset)
    resulting_h_range = (h_s + offset)..(h_e - offset)

    trimmed_result_image =
      result_image
      |> Enum.filter(fn {{x, y}, _v} ->
        x in resulting_w_range and y in resulting_h_range
      end)
      |> Enum.into(%{})

    print_image(trimmed_result_image, resulting_w_range, resulting_h_range)
    |> IO.puts()

    Enum.count(trimmed_result_image, fn {_k, v} -> v == "#" end)
  end

  defp do_run_q1(_, image_map, w_range, h_range, 0), do: {image_map, w_range, h_range}

  defp do_run_q1(algorithm, image_map, w_s..w_e, h_s..h_e, count) do
    IO.inspect(count)
    new_w_range = (w_s - 1)..(w_e + 1)
    new_h_range = (h_s - 1)..(h_e + 1)

    new_image_map =
      for y <- new_h_range,
          x <- new_w_range,
          into: %{},
          do: {{x, y}, get_alg(algorithm, image_map, {x, y}, count)}

    # print_image(new_image_map, new_w_range, new_h_range)
    # |> IO.puts()

    do_run_q1(algorithm, new_image_map, new_w_range, new_h_range, count - 1)
  end

  defp get_alg(algorithm, image_map, {x, y}, count) do
    idx =
      [
        {x - 1, y - 1},
        {x, y - 1},
        {x + 1, y - 1},
        {x - 1, y},
        {x, y},
        {x + 1, y},
        {x - 1, y + 1},
        {x, y + 1},
        {x + 1, y + 1}
      ]
      |> Enum.map(&get_pixel(image_map, &1, count))
      |> Enum.join("")
      |> String.to_integer(2)

    String.at(algorithm, idx)
  end

  defp get_pixel(image_map, point, count) do
    default = if rem(count, 2) == 1, do: "#", else: "."
    if Map.get(image_map, point, default) == "#", do: 1, else: 0
  end

  defp print_image(image_map, w_range, h_range) do
    h_range
    |> Enum.map(fn y ->
      w_range
      |> Enum.map(fn x ->
        if get_pixel(image_map, {x, y}, 0) == 1, do: "#", else: "."
      end)
      |> Enum.join("")
    end)
    |> Enum.join("\n")
  end
end
