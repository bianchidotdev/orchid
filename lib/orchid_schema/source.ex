defimpl String.Chars, for: OrchidSchema.Source do
  def to_string(source) do
    url_path = [source.url, source.path]
    |> Enum.reject(&is_nil/1)
    |> Path.join()
"<#{__MODULE__}>: (#{source.type}) #{url_path}"
  end
end

defmodule OrchidSchema.Source do
  use Ecto.Schema
  import Ecto.Changeset

  schema "sources" do
    field :type, Ecto.Enum, values: [:git, :http, :file, :none]
    field :url, :string
    field :path, :string, default: "/orchid.yaml"
    field :git_ref, :string, default: "main"

    field :last_sha, :binary
    field :last_synced_at, :utc_datetime_usec

    field :resource_type, Ecto.Enum, values: [:cluster, :service]
    belongs_to :cluster, OrchidSchema.Cluster
    belongs_to :service, OrchidSchema.Service

    timestamps()
  end

  def changeset(source, attrs) do
    source
    |> cast(attrs, [:type, :url, :path, :last_sha, :last_synced_at, :resource_type])
    |> validate_required([:type, :resource_type])
    |> validate_type_consistency()
    |> validate_type_attributes()
    |> put_sha()
  end

  defp validate_type_attributes(%{changes: %{type: :git}} = changeset) do
    validate_required(changeset, [:url, :path, :git_ref])
  end

  defp validate_type_attributes(%{changes: %{type: :http}} = changeset) do
    validate_required(changeset, [:url])
  end

  defp validate_type_attributes(%{changes: %{type: :file}} = changeset) do
    validate_required(changeset, [:path])
  end

  defp validate_type_attributes(changeset), do: changeset

  # allow type to be set once
  defp validate_type_consistency(%{data: %{type: nil}} = changeset), do: changeset
  defp validate_type_consistency(%{data: %{type: source_type}, changes: %{type: change_type}} = changeset) when source_type != change_type do
    changeset
    |> add_error(:type, "Source type cannot change")
  end
  defp validate_type_consistency(changeset), do: changeset

  defp put_sha(changeset) do
    dbg()
    sha = :crypto.hash(:sha256, :erlang.term_to_binary(changeset.data))
    change(changeset, last_sha: sha)
  end
end
