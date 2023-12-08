# Advent of Code 2021 Day 24 - Arithmetic Logic Unit
# https://adventofcode.com/2021/day/24
# Commentary: https://walnut-today.tistory.com/67

defmodule Aoc2021.Day24 do
  def parse_input(file_name) do
    file_name
    |> File.read!()
    |> String.split("\n")
    |> Enum.map(&String.split(&1, " "))
  end

  def run_q1(file_name \\ "input/day24.txt") do
    bindings = %{
      "w" => 0,
      "x" => 0,
      "y" => 0,
      "z" => 0
    }

    records = %{
      "w" => [],
      "x" => [],
      "y" => [],
      "z" => []
    }

    instructions = parse_input(file_name)

    # 11_111_111_111_111..11_111_111_112_311

    # 12자리
    # 111_111_111_111..111_111_111_199
    # |> Enum.map(fn v -> v * 100 + 11 end)

    71_111_591_396_151..71_111_591_396_151
    |> Enum.map(fn model_no ->
      Integer.digits(model_no)
    end)
    |> Enum.reject(fn model_no -> 0 in model_no end)
    |> Enum.each(fn model_no ->
      instructions
      |> Enum.reduce({bindings, records, model_no}, fn
        ["inp", var], {acc_bindings, records, [input | acc_model_no]} ->
          new_bindings = Map.put(acc_bindings, var, input)
          new_records = Map.update!(records, var, &[{:in, var} | &1])

          {new_bindings, new_records, acc_model_no}

        ["add", a, b], {acc_bindings, records, acc_model_no} ->
          new_bindings =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(acc_bindings, a, &(&1 + v))

              :error ->
                Map.update!(acc_bindings, a, &(&1 + Map.get(acc_bindings, b)))
            end

          new_records =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(records, a, &[{:ad, v} | &1])

              :error ->
                Map.update!(records, a, &[{:ad, "#{b}=#{Map.get(acc_bindings, b)}"} | &1])
            end

          {new_bindings, new_records, acc_model_no}

        ["mul", a, "0"], {acc_bindings, records, acc_model_no} ->
          inspect_records(records, label: "#{a}=0")

          new_bindings = Map.put(acc_bindings, a, 0)
          new_records = Map.put(records, a, [])

          {new_bindings, new_records, acc_model_no}

        ["mul", a, b], {acc_bindings, records, acc_model_no} ->
          new_bindings =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(acc_bindings, a, &(&1 * v))

              :error ->
                Map.update!(acc_bindings, a, &(&1 * Map.get(acc_bindings, b)))
            end

          new_records =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(records, a, &[{:mu, v} | &1])

              :error ->
                Map.update!(records, a, &[{:mu, "#{b}=#{Map.get(acc_bindings, b)}"} | &1])
            end

          {new_bindings, new_records, acc_model_no}

        ["div", a, b], {acc_bindings, records, acc_model_no} ->
          new_bindings =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(acc_bindings, a, &div(&1, v))

              :error ->
                Map.update!(acc_bindings, a, &div(&1, Map.get(acc_bindings, b)))
            end

          new_records =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(records, a, &[{:di, v} | &1])

              :error ->
                Map.update!(records, a, &[{:di, "#{b}=#{Map.get(acc_bindings, b)}"} | &1])
            end

          {new_bindings, new_records, acc_model_no}

        ["mod", a, b], {acc_bindings, records, acc_model_no} ->
          new_bindings =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(acc_bindings, a, &rem(&1, v))

              :error ->
                Map.update!(acc_bindings, a, &rem(&1, Map.get(acc_bindings, b)))
            end

          new_records =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(records, a, &[{:mo, v} | &1])

              :error ->
                Map.update!(records, a, &[{:mo, "#{b}=#{Map.get(acc_bindings, b)}"} | &1])
            end

          {new_bindings, new_records, acc_model_no}

        ["eql", a, b], {acc_bindings, records, acc_model_no} ->
          new_bindings =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(acc_bindings, a, &equal?(&1, v))

              :error ->
                Map.update!(acc_bindings, a, &equal?(&1, Map.get(acc_bindings, b)))
            end

          new_records =
            case Integer.parse(b) do
              {v, _} when is_integer(v) ->
                Map.update!(records, a, &[{:eq, v} | &1])

              :error ->
                Map.update!(records, a, &[{:eq, "#{b}=#{Map.get(acc_bindings, b)}"} | &1])
            end

          {new_bindings, new_records, acc_model_no}
      end)
      |> tap(fn {result, _records, []} ->
        model_no = Integer.undigits(model_no)

        x = if(rem(model_no, 100) in [51, 62, 73, 84, 95], do: 0, else: 1)

        y = if(rem(model_no, 100) in [51, 62, 73, 84, 95], do: 0, else: rem(model_no, 10) + 5)

        z =
          if(rem(model_no, 100) in [51, 62, 73, 84, 95],
            do: 3_007_898 + div(model_no - 11_111_111_111_111, 100),
            else: 78_205_348 + div(rem(model_no, 1000) - 111, 100) * 26 + y
          )

        prediction = %{"w" => rem(model_no, 10), "x" => x, "y" => y, "z" => z}

        IO.inspect(result,
          label: model_no,
          syntax_colors: [number: :yellow, string: :green, atom: :red]
        )

        # inspect_records(records)

        if(prediction != result) do
          prediction
          |> Enum.filter(fn {k, v} -> Map.get(result, k) != v end)
          |> Enum.into(%{})
          |> IO.inspect(
            label: "prediction    ",
            syntax_colors: [number: :yellow, string: :green, atom: :red]
          )
        end
      end)
    end)
  end

  defp equal?(a, a), do: 1
  defp equal?(_, _), do: 0

  defp inspect_records(records, opts) do
    label = Keyword.get(opts, :label, "")

    records
    |> Enum.map(fn {k, v} -> {k, Enum.reverse(v)} end)
    |> IO.inspect(
      syntax_colors: [number: :yellow, string: :green, atom: :red],
      label: label,
      width: 180
    )
  end
end
