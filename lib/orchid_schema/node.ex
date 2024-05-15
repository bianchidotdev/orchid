defmodule OrchidSchema.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :name, :any, virtual: true
    field :system_info, :map
    field :score, :integer, virtual: true

    # has_many :containers, OrchidSchema.Container

    timestamps()
  end

  def changeset(node, attrs) do
    node
    |> cast(attrs, [:name, :system_info])
    |> validate_required([:name])
    |> calculate_fitness_score()
  end

  defp calculate_fitness_score(changeset) do
    # node = Ecto.Changeset.apply_changes(changeset)
    # total_memory = Map.get(node.system_info, :total_memory)
    # available_memory = Map.get(node.system_info, :available_memory)
    # total_cpu = Map.get(node.system_info, :total_cpu)
    # available_cpu = Map.get(node.system_info, :available_cpu)

    # # Calculate the fitness score as the average of the ratios of available memory and CPU to total memory and CPU,
    # # adjusted by the resource usage of the containers.
    # normalized_memory_usage = container_memory_usage / total_memory
    # normalized_cpu_usage = container_cpu_usage / total_cpu

    # # Prioritize systems with more overall capacity by adding the total memory and CPU to the score.
    # score = (memory_score + cpu_score) / 2 + total_memory + total_cpu
    # put_change(changeset, :score, score)
    put_change(changeset, :score, 0)
  end
end
