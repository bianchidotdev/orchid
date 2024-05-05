defmodule OrchidSchema.Node do
  use Ecto.Schema
  import Ecto.Changeset

  schema "nodes" do
    field :name, :string
    field :address, :string
    field :port, :integer
    field :cluster_id, :integer

    has_many :containers, OrchidSchema.Container

    timestamps()
  end
end
