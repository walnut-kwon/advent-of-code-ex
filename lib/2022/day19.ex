# Advent of Code 2022 Day 19 - Not Enough Minerals
# https://adventofcode.com/2022/day/19
# Commentary: https://walnut-today.tistory.com/223

defmodule Aoc2022.Day19 do
  @dir "data/day19/"

  def q1(file_name \\ "q.txt") do
    blueprints =
      File.read!(@dir <> file_name)
      |> String.split("\n")
      |> Enum.map(fn line ->
        [
          _,
          id,
          ore_cost_ore,
          clay_cost_ore,
          obs_cost_ore,
          obs_cost_clay,
          geode_cost_ore,
          geode_cost_obs
        ] =
          Regex.run(
            ~r/Blueprint ([0-9]+): Each ore robot costs ([0-9]+) ore. Each clay robot costs ([0-9]+) ore. Each obsidian robot costs ([0-9]+) ore and ([0-9]+) clay. Each geode robot costs ([0-9]+) ore and ([0-9]+) obsidian.$/,
            line
          )

        %{
          id: String.to_integer(id),
          ore_cost_ore: String.to_integer(ore_cost_ore),
          clay_cost_ore: String.to_integer(clay_cost_ore),
          obs_cost_ore: String.to_integer(obs_cost_ore),
          obs_cost_clay: String.to_integer(obs_cost_clay),
          geode_cost_ore: String.to_integer(geode_cost_ore),
          geode_cost_obs: String.to_integer(geode_cost_obs)
        }
      end)

    blueprints
    |> Enum.map(fn blueprint ->
      %{
        ore_cost_ore: ore_cost_ore,
        clay_cost_ore: clay_cost_ore,
        obs_cost_clay: obs_cost_clay,
        obs_cost_ore: obs_cost_ore,
        geode_cost_obs: geode_cost_obs,
        geode_cost_ore: geode_cost_ore
      } = blueprint

      1..24
      |> Enum.reduce(
        [
          {%{ore_robot: 1, clay_robot: 0, obs_robot: 0, geode_robot: 0},
           %{ore: 0, clay: 0, obs: 0, geode: 0}}
        ],
        fn i, candidates ->
          max_geode_robot =
            candidates
            |> Enum.max_by(fn {robots, _} -> robots.geode_robot end)
            |> elem(0)
            |> Map.get(:geode_robot)

          max_geode =
            candidates
            |> Enum.max_by(fn {_, resources} -> resources.geode end)
            |> elem(1)
            |> Map.get(:geode)

          candidates
          |> tap(fn _ ->
            # IO.inspect(candidates)
            IO.inspect(length(candidates), label: "Day #{i}")
          end)
          |> Enum.reject(fn {robots, resources} ->
            robots.geode_robot < max_geode_robot / 2 and resources.geode < max_geode / 2
          end)
          |> Enum.flat_map(fn {robots, resources} ->
            ore_action = if resources.ore >= ore_cost_ore, do: [:ore], else: []
            clay_action = if resources.ore >= clay_cost_ore, do: [:clay], else: []

            obs_action =
              if resources.clay >= obs_cost_clay and resources.ore >= obs_cost_ore,
                do: [:obs],
                else: []

            geode_action =
              if resources.obs >= geode_cost_obs and resources.ore >= geode_cost_ore,
                do: [:geode],
                else: []

            actions = [:skip] ++ obs_action ++ geode_action ++ ore_action ++ clay_action

            tmp_resources =
              resources
              |> Map.update!(:ore, &(&1 + robots.ore_robot))
              |> Map.update!(:clay, &(&1 + robots.clay_robot))
              |> Map.update!(:obs, &(&1 + robots.obs_robot))
              |> Map.update!(:geode, &(&1 + robots.geode_robot))

            Enum.map(actions, fn action ->
              case action do
                :skip ->
                  {robots, tmp_resources}

                :ore ->
                  {
                    robots |> Map.update!(:ore_robot, &(&1 + 1)),
                    tmp_resources |> Map.update!(:ore, &(&1 - ore_cost_ore))
                  }

                :clay ->
                  {
                    robots |> Map.update!(:clay_robot, &(&1 + 1)),
                    tmp_resources |> Map.update!(:ore, &(&1 - clay_cost_ore))
                  }

                :obs ->
                  {
                    robots |> Map.update!(:obs_robot, &(&1 + 1)),
                    tmp_resources
                    |> Map.update!(:ore, &(&1 - obs_cost_ore))
                    |> Map.update!(:clay, &(&1 - obs_cost_clay))
                  }

                :geode ->
                  {
                    robots |> Map.update!(:geode_robot, &(&1 + 1)),
                    tmp_resources
                    |> Map.update!(:ore, &(&1 - geode_cost_ore))
                    |> Map.update!(:obs, &(&1 - geode_cost_obs))
                  }
              end
            end)
          end)
          |> Enum.uniq()
        end
      )
      |> Enum.max_by(fn {_robots, resources} -> resources.geode end)
      |> elem(1)
      |> Map.get(:geode)
    end)
    |> Enum.with_index()
    |> Enum.map(fn {v, i} ->
      v * (i + 1)
    end)
    |> Enum.sum()
  end

  def q2(file_name \\ "q.txt") do
    blueprints =
      File.read!(@dir <> file_name)
      |> String.split("\n")
      |> Enum.map(fn line ->
        [
          _,
          id,
          ore_cost_ore,
          clay_cost_ore,
          obs_cost_ore,
          obs_cost_clay,
          geode_cost_ore,
          geode_cost_obs
        ] =
          Regex.run(
            ~r/Blueprint ([0-9]+): Each ore robot costs ([0-9]+) ore. Each clay robot costs ([0-9]+) ore. Each obsidian robot costs ([0-9]+) ore and ([0-9]+) clay. Each geode robot costs ([0-9]+) ore and ([0-9]+) obsidian.$/,
            line
          )

        %{
          id: String.to_integer(id),
          ore_cost_ore: String.to_integer(ore_cost_ore),
          clay_cost_ore: String.to_integer(clay_cost_ore),
          obs_cost_ore: String.to_integer(obs_cost_ore),
          obs_cost_clay: String.to_integer(obs_cost_clay),
          geode_cost_ore: String.to_integer(geode_cost_ore),
          geode_cost_obs: String.to_integer(geode_cost_obs)
        }
      end)

    blueprints
    |> Enum.take(3)
    |> Enum.map(fn blueprint ->
      %{
        ore_cost_ore: ore_cost_ore,
        clay_cost_ore: clay_cost_ore,
        obs_cost_clay: obs_cost_clay,
        obs_cost_ore: obs_cost_ore,
        geode_cost_obs: geode_cost_obs,
        geode_cost_ore: geode_cost_ore
      } = blueprint

      1..32
      |> Enum.reduce(
        [
          {%{ore_robot: 1, clay_robot: 0, obs_robot: 0, geode_robot: 0},
           %{ore: 0, clay: 0, obs: 0, geode: 0}}
        ],
        fn i, candidates ->
          max_geode_robot =
            candidates
            |> Enum.max_by(fn {robots, _} -> robots.geode_robot end)
            |> elem(0)
            |> Map.get(:geode_robot)

          max_geode =
            candidates
            |> Enum.max_by(fn {_, resources} -> resources.geode end)
            |> elem(1)
            |> Map.get(:geode)

          candidates
          |> tap(fn _ ->
            # IO.inspect(candidates)
            IO.inspect(length(candidates), label: "Day #{i}")
          end)
          |> Enum.reject(fn {robots, resources} ->
            robots.geode_robot < max_geode_robot and resources.geode < max_geode
          end)
          |> Enum.flat_map(fn {robots, resources} ->
            ore_action = if resources.ore >= ore_cost_ore, do: [:ore], else: []
            clay_action = if resources.ore >= clay_cost_ore, do: [:clay], else: []

            obs_action =
              if resources.clay >= obs_cost_clay and resources.ore >= obs_cost_ore,
                do: [:obs],
                else: []

            geode_action =
              if resources.obs >= geode_cost_obs and resources.ore >= geode_cost_ore,
                do: [:geode],
                else: []

            actions = [:skip] ++ obs_action ++ geode_action ++ ore_action ++ clay_action

            tmp_resources =
              resources
              |> Map.update!(:ore, &(&1 + robots.ore_robot))
              |> Map.update!(:clay, &(&1 + robots.clay_robot))
              |> Map.update!(:obs, &(&1 + robots.obs_robot))
              |> Map.update!(:geode, &(&1 + robots.geode_robot))

            Enum.map(actions, fn action ->
              case action do
                :skip ->
                  {robots, tmp_resources}

                :ore ->
                  {
                    robots |> Map.update!(:ore_robot, &(&1 + 1)),
                    tmp_resources |> Map.update!(:ore, &(&1 - ore_cost_ore))
                  }

                :clay ->
                  {
                    robots |> Map.update!(:clay_robot, &(&1 + 1)),
                    tmp_resources |> Map.update!(:ore, &(&1 - clay_cost_ore))
                  }

                :obs ->
                  {
                    robots |> Map.update!(:obs_robot, &(&1 + 1)),
                    tmp_resources
                    |> Map.update!(:ore, &(&1 - obs_cost_ore))
                    |> Map.update!(:clay, &(&1 - obs_cost_clay))
                  }

                :geode ->
                  {
                    robots |> Map.update!(:geode_robot, &(&1 + 1)),
                    tmp_resources
                    |> Map.update!(:ore, &(&1 - geode_cost_ore))
                    |> Map.update!(:obs, &(&1 - geode_cost_obs))
                  }
              end
            end)
          end)
          |> Enum.uniq()
        end
      )
      |> Enum.max_by(fn {_robots, resources} -> resources.geode end)
      |> elem(1)
      |> Map.get(:geode)
      |> IO.inspect()
    end)
    |> Enum.product()
  end
end
