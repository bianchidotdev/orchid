defmodule Orchid.ClusterConfig do
  defstruct [source: nil]

  def valid?(config = %__MODULE__{}) do
    config.source != nil
  end
end
