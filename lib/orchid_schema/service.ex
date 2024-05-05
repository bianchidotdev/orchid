defmodule OrchidSchema.Service do
  use Ecto.Schema
  import Ecto.Changeset

  schema "services" do
    field :name, :string
    field :count, :integer, default: 1
    field :controller, Ecto.Enum, values: [Orchid.Docker.Controller], default: Orchid.Docker.Controller

    has_many :containers, OrchidSchema.Container
  end

  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :count, :controller])
    |> validate_required([:name, :controller])
  end
end
