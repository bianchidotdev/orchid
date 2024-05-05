defmodule OrchidSchema.Service do
  use Ecto.Schema
  import Ecto.Changeset

  schema "services" do
    field :name, :string
    field :count, :integer, default: 1

    has_many :containers, OrchidSchema.Container
  end

  def changeset(service, attrs) do
    service
    |> cast(attrs, [:name, :count])
    |> validate_required([:name])
  end
end
