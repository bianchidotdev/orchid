defmodule OrchidSchema.Cluster do
  use Ecto.Schema
  import Ecto.Changeset

  schema "clusters" do
    field :name, :string
    field :version, :string

    # TODO: migrate to extensible schema
    field :controller, :string
    # has_one :controller, OrchidSchema.Controller

    # has_one :proxy, OrchidSchema.Proxy
    # has_many :nodes, OrchidSchema.Node

    has_many :sources, OrchidSchema.Source
    has_many :services, OrchidSchema.Service

    timestamps()
  end

  def changeset(cluster, attrs) do
    cluster
    |> cast(attrs, [:name, :version, :controller])
    |> validate_required([:name, :version, :controller])
    |> cast_assoc(:services)
  end
end
