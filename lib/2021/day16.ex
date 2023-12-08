# Advent of Code 2021 Day 16 - Packet Decoder
# https://adventofcode.com/2021/day/16
# Commentary: https://walnut-today.tistory.com/58

defmodule Aoc2021.Day16 do
  defmodule Packet do
    defstruct [:version, :type, :value]
  end

  def run_q1_with_file(file_name \\ "input/day16.txt") do
    file_name
    |> File.read!()
    |> run_q1()
  end

  def run_q2_with_file(file_name \\ "input/day16.txt") do
    file_name
    |> File.read!()
    |> run_q2()
  end

  def run_q1(raw_input) do
    raw_input
    |> Base.decode16!()
    |> parse_packet([], nil)
    |> elem(0)
    |> hd()
    |> calculate_version()
  end

  def run_q2(raw_input) do
    raw_input
    |> Base.decode16!()
    |> parse_packet([], nil)
    |> elem(0)
    |> hd()
    |> operation()
  end

  def parse_packet(remainder, acc, remaining_count) when length(acc) == remaining_count do
    {acc |> Enum.reverse(), remainder}
  end

  def parse_packet(
        <<packet_version::size(3), 4::size(3), payload::bits>>,
        acc,
        remaining_count
      ) do
    {value, remainder} = parse_payload(payload, <<>>)

    # IO.inspect(value, label: "4-value")
    # IO.inspect(remainder, label: "4-remainder")

    packet = %Packet{value: format_result(value), version: packet_version, type: 4}

    parse_packet(remainder, [packet | acc], remaining_count)
  end

  def parse_packet(
        <<
          packet_version::size(3),
          packet_type::size(3),
          0::size(1),
          payload_length::size(15),
          payload::bits-size(payload_length),
          remainder::bits
        >>,
        acc,
        remaining_count
      ) do
    {subpacket, _new_remainder} = parse_packet(payload, [], nil)

    packet = %Packet{
      version: packet_version,
      type: packet_type,
      value: subpacket
    }

    parse_packet(remainder, [packet | acc], remaining_count)
  end

  def parse_packet(
        <<
          packet_version::size(3),
          packet_type::size(3),
          1::size(1),
          payload_count::size(11),
          payload::bits
        >>,
        acc,
        remaining_count
      ) do
    {subpacket, remainder} = parse_packet(payload, [], payload_count)

    packet = %Packet{
      version: packet_version,
      type: packet_type,
      value: subpacket
    }

    parse_packet(remainder, [packet | acc], remaining_count)
  end

  def parse_packet(remainder, acc, _), do: {acc |> Enum.reverse(), remainder}

  def parse_payload(<<0::size(1), data::bits-size(4), remainder::bits>>, result) do
    {<<result::bits, data::bits>>, remainder}
  end

  def parse_payload(<<1::size(1), data::bits-size(4), remainder::bits>>, result) do
    parse_payload(remainder, <<result::bits, data::bits>>)
  end

  defp format_result(result) do
    result
    |> pad_result()
    |> Base.encode16()
    |> String.to_integer(16)
  end

  defp pad_result(result) when bit_size(result) |> rem(8) == 0, do: result

  defp pad_result(result) do
    padding = 8 - (bit_size(result) |> rem(8))
    <<0::size(padding), result::bits>>
  end

  defp calculate_version(%Packet{value: [], version: v}), do: v

  defp calculate_version(%Packet{value: value, version: v}) when is_integer(value), do: v

  defp calculate_version(%Packet{value: packets, version: v}) do
    packets |> Enum.map(&calculate_version/1) |> Enum.sum() |> Kernel.+(v)
  end

  def operation(%Packet{type: 4, value: value}), do: value

  def operation(%Packet{value: value, type: 0}), do: Enum.map(value, &operation/1) |> Enum.sum()

  def operation(%Packet{value: value, type: 1}),
    do: Enum.map(value, &operation/1) |> Enum.product()

  def operation(%Packet{value: value, type: 2}), do: Enum.map(value, &operation/1) |> Enum.min()

  def operation(%Packet{value: value, type: 3}), do: Enum.map(value, &operation/1) |> Enum.max()

  def operation(%Packet{value: [v1, v2], type: 5}),
    do: if(operation(v1) > operation(v2), do: 1, else: 0)

  def operation(%Packet{value: [v1, v2], type: 6}),
    do: if(operation(v1) < operation(v2), do: 1, else: 0)

  def operation(%Packet{value: [v1, v2], type: 7}),
    do: if(operation(v1) == operation(v2), do: 1, else: 0)
end
