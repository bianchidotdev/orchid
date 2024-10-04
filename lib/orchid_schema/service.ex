defmodule OrchidSchema.Service do
  use Ecto.Schema
  import Ecto.Changeset

  schema "services" do
    field(:name, :string)
    field(:count, :integer, default: 1)
    # TODO: add type of replica or daemon (maybe new names)

    field(:controller, Ecto.Enum,
      values: [Orchid.Docker.Controller],
      default: Orchid.Docker.Controller
    )

    embeds_many(:containers, OrchidSchema.Container)
  end

  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :count, :controller])
    |> cast_embed(:containers)
    |> validate_required([:name, :controller])
  end

  def runtime_changeset(service, attrs) do
    service
    |> cast(attrs, [])
    |> cast_embed(:containers, with: &OrchidSchema.Container.runtime_changeset/2)
  end
end
