defmodule Orchid.Models.ServiceConfig do
  defstruct [source: nil, controller: Orchid.Docker.Controllers, name: nil, desired_state: nil]

  def load(source) do
    %__MODULE__{source: source}
  end

  def valid?(config = %__MODULE__{}) do
    config.source != nil &&
      Regex.match?(~r/^[a-zA-Z0-9_-]+$/, config.name)
  end

  def diff(config = %__MODULE__{}, current_state) do
    desired_state = config.desired_state
    Enum.reduce(desired_state, %{}, fn {k, v}, acc ->
        if current_state[k] != v do
          Map.put(acc, k, v)
        else
          v
        end
      end)
  end
end
