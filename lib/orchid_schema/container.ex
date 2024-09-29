defmodule OrchidSchema.Container do
  use Ecto.Schema
  import Ecto.Changeset

  @required_fields ~w(name image id)a
  @optional_fields ~w(entrypoint command args env env_file ports mounts labels depends_on)a
  @configurable_fields @required_fields ++ @optional_fields
  @runtime_fields ~w(container_id state)a

  @primary_key false
  schema "containers" do
    field(:id, :string, primary_key: true, default: Ecto.UUID.generate())
    field(:service_id, :string)
    # service spec
    field(:name, :string)
    field(:image, :string)
    field(:entrypoint, {:array, :string})
    field(:command, {:array, :string})
    field(:args, {:array, :string})
    field(:env, {:array, :string})
    field(:env_file, {:array, :string})
    field(:ports, {:array, :string})
    field(:mounts, {:array, :string})
    field(:labels, :map)
    field(:depends_on, {:array, :string})
    # these might be adapter specific
    # field :network_mode, :string
    # field :restart_policy, :string
    # field :networks, {:array, :string}
    # field :healthcheck, :map, default: %{}

    # ephemeral fields
    field(:container_id, :string, virtual: true)
    field(:state, :map, virtual: true)

    belongs_to :node, OrchidSchema.Node
  end

  def changeset(container, attrs) do
    container
    |> cast(attrs, @configurable_fields)
    # TODO: embed state
    # |> cast_embed(:state)
    |> validate_required(@required_fields)
  end

  def runtime_changeset(container, attrs) do
    container
    |> cast(attrs, @runtime_fields)
  end

  def new(container) do
    {:ok, container} =
      %OrchidSchema.Container{}
      |> OrchidSchema.Container.changeset(container)
      |> Ecto.Changeset.apply_action(:insert)

    container
  end
end
