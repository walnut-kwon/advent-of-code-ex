# Advent of Code 2021 Day 23 - Amphipod
# https://adventofcode.com/2021/day/23
# Commentary: https://walnut-today.tistory.com/66

defmodule Aoc2021.Day23 do
  defstruct [:h_l, :h_ab, :h_bc, :h_cd, :h_r, :r_a, :r_b, :r_c, :r_d, :moves]

  @init %{
    h_l: [],
    h_ab: nil,
    h_bc: nil,
    h_cd: nil,
    h_r: [],
    r_a: ["C", "B"],
    r_b: ["D", "A"],
    r_c: ["D", "B"],
    r_d: ["A", "C"],
    moves: []
  }
  @room_depth Map.get(@init, :r_a) |> length()
  @room_pos %{
    h_l: 0,
    r_a: 0,
    h_ab: 1,
    r_b: 2,
    h_bc: 3,
    r_c: 4,
    h_cd: 5,
    r_d: 6,
    h_r: 6
  }
  @energy_by_t %{
    "A" => 1,
    "B" => 10,
    "C" => 100,
    "D" => 1000
  }

  @type t :: %__MODULE__{
          h_l: list(String.t()),
          h_ab: nil | String.t(),
          h_bc: nil | String.t(),
          h_cd: nil | String.t(),
          h_r: list(String.t()),
          r_a: list(String.t()),
          r_b: list(String.t()),
          r_c: list(String.t()),
          r_d: list(String.t()),
          moves: []
        }

  def run_q1() do
    do_run_q1([struct(Day23, @init)], 0)

    nil
  end

  defp complete?(map) do
    r_a = Map.get(map, :r_a)
    r_b = Map.get(map, :r_b)
    r_c = Map.get(map, :r_c)
    r_d = Map.get(map, :r_d)

    length(r_a) == @room_depth and Enum.all?(r_a, fn v -> v == "A" end) and
      length(r_b) == @room_depth and Enum.all?(r_b, fn v -> v == "B" end) and
      length(r_c) == @room_depth and Enum.all?(r_c, fn v -> v == "C" end) and
      length(r_d) == @room_depth and Enum.all?(r_d, fn v -> v == "D" end)
  end

  defp calc_energy(complete) do
    complete
    |> Map.get(:moves)
    |> Enum.reverse()
    |> Enum.reduce({struct(Day23, @init), 0}, fn {f, d}, {map, acc_energy} ->
      t =
        Map.get(map, f)
        |> then(fn
          l when is_list(l) -> List.first(l)
          v -> v
        end)

      new_map = move(f, d, map, t)

      room_depth_f =
        case f do
          value when value in [:r_a, :r_b, :r_c, :r_d] ->
            @room_depth - length(Map.get(map, f)) + 1

          value when value in [:h_l, :h_r] ->
            2 - length(Map.get(map, f)) + 1

          _ ->
            0
        end

      room_depth_d =
        case d do
          value when value in [:r_a, :r_b, :r_c, :r_d] ->
            @room_depth - length(Map.get(map, d))

          value when value in [:h_l, :h_r] ->
            2 - length(Map.get(map, d))

          _ ->
            0
        end

      dist =
        abs(@room_pos[f] - @room_pos[d])
        |> Kernel.+(room_depth_f)
        |> Kernel.+(room_depth_d)

      {new_map, acc_energy + dist * @energy_by_t[t]}
    end)
    |> elem(1)
  end

  @spec do_run_q1([%__MODULE__{}], integer()) :: [%__MODULE__{}]
  defp do_run_q1([], _depth) do
    IO.puts("ended")
    []
  end

  defp do_run_q1(map_candidates, depth) do
    possible_positions =
      %__MODULE__{} |> Map.keys() |> List.delete(:__struct__) |> List.delete(:moves)

    completes =
      map_candidates
      |> Enum.filter(&complete?/1)

    if completes != [] do
      IO.inspect(length(completes), label: "completed size")

      completes
      |> Enum.map(&calc_energy/1)
      |> Enum.min()
      |> IO.inspect()
    else
      map_candidates
      |> Enum.reject(&complete?/1)
      |> Enum.flat_map(fn map ->
        map
        |> Map.from_struct()
        |> Map.drop([:moves])
        |> Enum.map(fn
          {k, l} when is_list(l) ->
            if (k == :r_a and Enum.any?(l, &(&1 != "A"))) or
                 (k == :r_b and Enum.any?(l, &(&1 != "B"))) or
                 (k == :r_c and Enum.any?(l, &(&1 != "C"))) or
                 (k == :r_d and Enum.any?(l, &(&1 != "D"))) or
                 k in [:h_l, :h_r] do
              {k, l |> List.first()}
            else
              {k, nil}
            end

          {k, v} ->
            {k, v}
        end)
        |> Enum.reject(&(&1 |> elem(1) |> is_nil()))
        |> Enum.flat_map(fn {current_position, type} ->
          # 특정 하나의 개체가 이동 가능한 모든 경우 계산
          possible_positions
          |> Enum.map(fn p -> move(current_position, p, map, type) end)
          |> Enum.filter(fn v -> v != false end)
          |> then(fn candidates ->
            # r_a, r_b, r_c, r_d 로 향할 수 있는 경우가 존재하면 해당 경우를 우선해서 취함
            Enum.filter(candidates, fn candidate ->
              (Map.get(candidate, :moves) |> hd() |> elem(1)) in [:r_a, :r_b, :r_c, :r_d]
            end)
            |> then(fn
              [] -> candidates
              filtered_candidates -> filtered_candidates
            end)
          end)

          # |> IO.inspect(label: "#{current_position}, #{type}")
        end)
      end)
      |> tap(fn maps -> IO.puts("step #{depth} ended: #{length(maps)}") end)
      |> do_run_q1(depth + 1)
    end
  end

  # From hall_left
  @spec move(atom(), atom(), Day23.t(), String.t()) :: Day23.t()
  def move(:h_l = f, :r_a = d, %__MODULE__{r_a: r} = map, "A" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:h_l = f, :r_b = d, %__MODULE__{h_ab: nil, r_b: r} = map, "B" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:h_l = f, :r_c = d, %__MODULE__{h_ab: nil, h_bc: nil, r_c: r} = map, "C" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(
        :h_l = f,
        :r_d = d,
        %__MODULE__{h_ab: nil, h_bc: nil, h_cd: nil, r_d: r} = map,
        "D" = t
      ),
      do: move_lr_or_room_to_room(f, d, map, r, t)

  # From hall_ab
  def move(:h_ab = f, :r_a = d, %__MODULE__{r_a: r} = map, "A" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_ab = f, :r_b = d, %__MODULE__{r_b: r} = map, "B" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_ab = f, :r_c = d, %__MODULE__{h_bc: nil, r_c: r} = map, "C" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_ab = f, :r_d = d, %__MODULE__{h_bc: nil, h_cd: nil, r_d: r} = map, "D" = t),
    do: move_hall_to_room(f, d, map, r, t)

  # From hall_bc
  def move(:h_bc = f, :r_a = d, %__MODULE__{h_ab: nil, r_a: r} = map, "A" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_bc = f, :r_b = d, %__MODULE__{r_b: r} = map, "B" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_bc = f, :r_c = d, %__MODULE__{r_c: r} = map, "C" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_bc = f, :r_d = d, %__MODULE__{h_cd: nil, r_d: r} = map, "D" = t),
    do: move_hall_to_room(f, d, map, r, t)

  # From hall_cd
  def move(:h_cd = f, :r_a = d, %__MODULE__{h_ab: nil, h_bc: nil, r_a: r} = map, "A" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_cd = f, :r_b = d, %__MODULE__{h_bc: nil, r_b: r} = map, "B" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_cd = f, :r_c = d, %__MODULE__{r_c: r} = map, "C" = t),
    do: move_hall_to_room(f, d, map, r, t)

  def move(:h_cd = f, :r_d = d, %__MODULE__{r_d: r} = map, "D" = t),
    do: move_hall_to_room(f, d, map, r, t)

  # From hall_right
  def move(
        :h_r = f,
        :r_a = d,
        %__MODULE__{h_ab: nil, h_bc: nil, h_cd: nil, r_a: r} = map,
        "A" = t
      ),
      do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:h_r = f, :r_b = d, %__MODULE__{h_bc: nil, h_cd: nil, r_b: r} = map, "B" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:h_r = f, :r_c = d, %__MODULE__{h_cd: nil, r_c: r} = map, "C" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:h_r = f, :r_d = d, %__MODULE__{r_d: r} = map, "D" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  # From room_a
  def move(:r_a = f, :h_l = d, %__MODULE__{h_l: h} = map, t), do: move_room_to_lr(f, d, map, h, t)

  def move(:r_a = f, :h_ab = d, %__MODULE__{h_ab: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_a = f, :h_bc = d, %__MODULE__{h_ab: nil, h_bc: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_a = f, :h_cd = d, %__MODULE__{h_ab: nil, h_bc: nil, h_cd: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_a = f, :h_r = d, %__MODULE__{h_ab: nil, h_bc: nil, h_cd: nil, h_r: h} = map, t),
    do: move_room_to_lr(f, d, map, h, t)

  def move(:r_a = f, :r_b = d, %__MODULE__{h_ab: nil, r_b: r} = map, "B" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:r_a = f, :r_c = d, %__MODULE__{h_ab: nil, h_bc: nil, r_c: r} = map, "C" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(
        :r_a = f,
        :r_d = d,
        %__MODULE__{h_ab: nil, h_bc: nil, h_cd: nil, r_d: r} = map,
        "D" = t
      ),
      do: move_lr_or_room_to_room(f, d, map, r, t)

  # From room_b
  def move(:r_b = f, :h_l = d, %__MODULE__{h_l: h, h_ab: nil} = map, t),
    do: move_room_to_lr(f, d, map, h, t)

  def move(:r_b = f, :h_ab = d, %__MODULE__{h_ab: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_b = f, :h_bc = d, %__MODULE__{h_bc: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_b = f, :h_cd = d, %__MODULE__{h_bc: nil, h_cd: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_b = f, :h_r = d, %__MODULE__{h_bc: nil, h_cd: nil, h_r: h} = map, t),
    do: move_room_to_lr(f, d, map, h, t)

  def move(:r_b = f, :r_a = d, %__MODULE__{h_ab: nil, r_a: r} = map, "A" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:r_b = f, :r_c = d, %__MODULE__{h_bc: nil, r_c: r} = map, "C" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:r_b = f, :r_d = d, %__MODULE__{h_bc: nil, h_cd: nil, r_d: r} = map, "D" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  # From room_c
  def move(:r_c = f, :h_l = d, %__MODULE__{h_l: h, h_ab: nil, h_bc: nil} = map, t),
    do: move_room_to_lr(f, d, map, h, t)

  def move(:r_c = f, :h_ab = d, %__MODULE__{h_ab: nil, h_bc: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_c = f, :h_bc = d, %__MODULE__{h_bc: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_c = f, :h_cd = d, %__MODULE__{h_cd: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_c = f, :h_r = d, %__MODULE__{h_cd: nil, h_r: h} = map, t),
    do: move_room_to_lr(f, d, map, h, t)

  def move(:r_c = f, :r_a = d, %__MODULE__{h_ab: nil, h_bc: nil, r_a: r} = map, "A" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:r_c = f, :r_b = d, %__MODULE__{h_bc: nil, r_b: r} = map, "B" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:r_c = f, :r_d = d, %__MODULE__{h_cd: nil, r_d: r} = map, "D" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  # From room_d
  def move(:r_d = f, :h_l = d, %__MODULE__{h_l: h, h_ab: nil, h_bc: nil, h_cd: nil} = map, t),
    do: move_room_to_lr(f, d, map, h, t)

  def move(:r_d = f, :h_ab = d, %__MODULE__{h_ab: nil, h_bc: nil, h_cd: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_d = f, :h_bc = d, %__MODULE__{h_bc: nil, h_cd: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_d = f, :h_cd = d, %__MODULE__{h_cd: nil} = map, t),
    do: move_room_to_hall(f, d, map, t)

  def move(:r_d = f, :h_r = d, %__MODULE__{h_cd: nil, h_r: h} = map, t),
    do: move_room_to_lr(f, d, map, h, t)

  def move(
        :r_d = f,
        :r_a = d,
        %__MODULE__{h_ab: nil, h_bc: nil, h_cd: nil, r_a: r} = map,
        "A" = t
      ),
      do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:r_d = f, :r_b = d, %__MODULE__{h_bc: nil, h_cd: nil, r_b: r} = map, "B" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(:r_d = f, :r_c = d, %__MODULE__{h_cd: nil, r_c: r} = map, "C" = t),
    do: move_lr_or_room_to_room(f, d, map, r, t)

  def move(_, _, _map, _type) do
    # IO.puts("error!")
    false
  end

  defp move_lr_or_room_to_room(f, d, map, r, t) do
    if only?(r, t),
      do:
        map
        |> Map.update!(f, &Enum.drop(&1, 1))
        |> Map.update!(d, &[t | &1])
        |> Map.update!(:moves, &[{f, d} | &1]),
      else: false
  end

  defp move_hall_to_room(f, d, map, r, t) do
    if only?(r, t),
      do:
        map |> Map.put(f, nil) |> Map.update!(d, &[t | &1]) |> Map.update!(:moves, &[{f, d} | &1]),
      else: false
  end

  defp move_room_to_lr(f, d, map, h, t) do
    if length(h) < 2,
      do:
        map
        |> Map.update!(f, &Enum.drop(&1, 1))
        |> Map.update!(d, &[t | &1])
        |> Map.update!(:moves, &[{f, d} | &1]),
      else: false
  end

  defp move_room_to_hall(f, d, map, t) do
    map
    |> Map.update!(f, &Enum.drop(&1, 1))
    |> Map.put(d, t)
    |> Map.update!(:moves, &[{f, d} | &1])
  end

  @spec only?(list(), String.t()) :: boolean()
  defp only?(room, type), do: Enum.all?(room, &(&1 == type))
end
