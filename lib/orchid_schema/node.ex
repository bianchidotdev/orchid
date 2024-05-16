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
    node = Ecto.Changeset.apply_changes(changeset)
    total_memory = get_in(node.system_info, [:system_memory, :total_memory])
    free_memory = get_in(node.system_info, [:system_memory, :free_memory])
    cpu_count = get_in(node.system_info, [:cpu_data, :count])
    cpu_avg_15 = get_in(node.system_info, [:cpu_data, :avg15])

    # sketch of the fitness score calculation
    # 1 core = 33% max cpu score
    # 2 cores = 60% max cpu score
    # 8 cores = 88% max cpu score
    # logarithmic scale to 1
    normalized_cpu_usage = (1 - (1 / (0.5 + cpu_count))) * cpu_avg_15
    # total memory usage
    # 1GB = 33% max memory score
    # 2GB = 60% max memory score
    # 8GB = 88% max memory score
    # memory score is crap since systems have less reported free memory
    # than they actually have access to
    memory_gb = total_memory / 1024 / 1024 / 1024
    normalize_memory_usage = (1 - (1 / (0.5 + memory_gb))) * (free_memory / total_memory)

    # Prioritize systems with more overall capacity by adding the total memory and CPU to the score.
    score = (normalize_memory_usage + normalized_cpu_usage) / 2
    put_change(changeset, :score, score)
  end
end
