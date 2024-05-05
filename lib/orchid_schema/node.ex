defmodule OrchidSchema.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :name, :string
    field :system_info, :map

    has_many :containers, OrchidSchema.Container

    timestamps()
  end

  def changeset(node, attrs) do
    node
    |> cast(attrs, [:name ])
    |> validate_required([:name])
  end
end
