# Advent of Code 2021 Day 14 - Extended Polymerization
# https://adventofcode.com/2021/day/14
# Commentary: https://walnut-today.tistory.com/56

defmodule Aoc2021.Day14 do
  def parse_input do
    [initial_template, _ | rules_list] =
      "input/day14.txt"
      |> File.read!()
      |> String.split("\n")

    rules =
      rules_list
      |> Enum.map(fn r ->
        [bef, aft] = r |> String.split(" -> ")

        {bef, [String.at(bef, 0) <> aft, aft <> String.at(bef, 1)]}
      end)
      |> Enum.into(%{})

    {initial_template, rules}
  end

  def run_q12(count) do
    {initial_template, rules} = parse_input()

    template_freq =
      initial_template
      |> String.codepoints()
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.frequencies()

    letter_freq =
      initial_template
      |> String.codepoints()
      |> Enum.frequencies()

    step_new({template_freq, letter_freq}, rules, count)
  end

  defp step_new({_template_freq, letter_freq}, _, 0) do
    letter_freq
    |> Map.values()
    |> Enum.min_max()
    |> then(fn {min, max} -> max - min end)
  end

  defp step_new({template_freq, letter_freq}, rules, count) do
    template_freq
    |> Enum.reduce({%{}, letter_freq}, fn {token, freq}, {tem_acc, let_acc} ->
      new_tem_acc =
        if Map.has_key?(rules, token) do
          rules[token]
          |> Enum.reduce(tem_acc, fn aft, tem_acc2 ->
            Map.update(tem_acc2, aft, freq, &(&1 + freq))
          end)
        else
          Map.update(tem_acc, token, freq, &(&1 + freq))
        end

      new_let_acc =
        if Map.has_key?(rules, token) do
          new_char = rules[token] |> hd() |> String.at(1)
          Map.update(let_acc, new_char, freq, &(&1 + freq))
        else
          let_acc
        end

      {new_tem_acc, new_let_acc}
    end)
    |> step_new(rules, count - 1)
  end
end
