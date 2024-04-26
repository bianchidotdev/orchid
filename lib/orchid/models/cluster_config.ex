defmodule Orchid.Models.ClusterConfig do
  defstruct [
    source: nil,
    controller: Orchid.Docker.Controller,
    service_sources: [],
    interval: 60_000
  ]

  # jank way to convert a yaml-sourced map to a struct - maybe it's not so abnormal
  def new(%{"version" => "v0.1", "spec" => spec}) do
    spec
    |> Enum.reduce(%__MODULE__{}, fn {k, v}, acc -> Map.put(acc, String.to_existing_atom(k), v) end)
  end

  def new(_), do: raise("Invalid cluster config, must have version and spec keys")

  # TODO: what do we want this to do?
  def load(source) do
    Orchid.Source.fetch(source)
    %{source: source}
  end

  def valid?(config = %__MODULE__{}) do
    config.source != nil
  end
end
