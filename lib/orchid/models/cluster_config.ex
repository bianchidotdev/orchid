defmodule Orchid.Models.ClusterConfig do
  defstruct [source: nil, interval: 60_000]

  def load(source) do
    Orchid.Source.fetch(source)
    %{source: source}
  end

  def valid?(config = %__MODULE__{}) do
    config.source != nil
  end
end
