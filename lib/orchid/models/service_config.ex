defmodule Orchid.Models.ServiceConfig do
  defstruct [
    source: nil,
    controller: Orchid.Docker.Controller,
    name: nil,
    containers: []]

  def new(cluster, %{"name" => name, "spec" => spec}) do
    service = %__MODULE__{controller: cluster.controller, source: cluster.source}
    spec
    |> Enum.reduce(service, fn {k, v}, acc -> Map.put(acc, String.to_existing_atom(k), v) end)
    |> Map.put(:name, name)
    |> Map.put_new(:controller, cluster.controller)
    |> Map.put_new(:source, cluster.source)
  end

  def valid?(%__MODULE__{} = config) do
    config.source != nil &&
      Regex.match?(~r/^[a-zA-Z0-9_-]+$/, config.name)
  end

  # def diff(config = %__MODULE__{}, current_state) do
  #   desired_state = config.desired_state
  #   Enum.reduce(desired_state, %{}, fn {k, v}, acc ->
  #       if current_state[k] != v do
  #         Map.put(acc, k, v)
  #       else
  #         v
  #       end
  #     end)
  # end
end
