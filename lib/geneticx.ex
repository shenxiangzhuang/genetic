defmodule Geneticx do
  @moduledoc """
  Documentation for `Geneticx`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Geneticx.hello()
      :world

  """
  def hello do
    :world
  end

  @doc """
  Run the genetic algorithm
  """
  def run(fitness_function, genotype, max_fitness, opts \\ []) do
    population = initialize(genotype)

    population
    |> evolve(fitness_function, genotype, max_fitness, opts)
  end

  @doc """
  The core algorithm
  """
  def evolve(population, fitness_function, genotype, max_fitness, opts \\ []) do
    population = evaluate(population, fitness_function)
    best = hd(population)
    IO.write("\r[#{DateTime.utc_now()}]Current Best: #{fitness_function.(best)}")

    if fitness_function.(best) == max_fitness do
      best
    else
      population
      |> select(opts)
      |> crossover(opts)
      |> mutation(opts)
      |> evolve(fitness_function, genotype, max_fitness, opts)
    end
  end

  @doc """
  Initialize the population with genotype
  """
  def initialize(genotype, opts \\ []) do
    population_size = Keyword.get(opts, :population_size, 100)
    for _ <- 1..population_size, do: genotype.()
  end

  @doc """
  Evaluate the population with the fitness function
  """
  def evaluate(population, fitness_function) do
    population
    |> Enum.sort_by(fitness_function, :desc)
  end

  @doc """
  Select the parents for the next generation
  """
  def select(population, _opts \\ []) do
    population
    |> Enum.chunk_every(2)
    |> Enum.map(&List.to_tuple(&1))
  end

  @doc """
  Crossover to generate the children
  """
  def crossover(population, _opts \\ []) do
    population
    |> Enum.reduce(
      [],
      fn {p1, p2}, acc ->
        cx_point = :rand.uniform(length(p1))
        {h1, t1} = Enum.split(p1, cx_point)
        {h2, t2} = Enum.split(p2, cx_point)
        {c1, c2} = {h1 ++ t2, h2 ++ t1}
        [c1, c2 | acc]
      end
    )
  end

  @doc """
  Mutate the children randomly
  """
  def mutation(population, _opts \\ []) do
    population
    |> Enum.map(fn chromosome ->
      if :rand.uniform() < 0.05 do
        Enum.shuffle(chromosome)
      else
        chromosome
      end
    end)
  end
end
