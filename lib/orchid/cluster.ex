defmodule Orchid.Cluster do
  alias Orchid.Models.ClusterConfig

  def sync() do
    {:ok, cluster_config} = ClusterConfig.load()
    if ClusterConfig.valid?(cluster_config) do
      #
    else
      {:error, "Invalid cluster config"}
    end

    Task.async_stream(cluster_config.services, &Orchid.Service.sync/1)
  end
end
