defmodule Orchid.Cluster do
  alias Orchid.Models.ClusterConfig
  alias Orchid.Source

  def sync() do
    source_props = %{
      type: Application.get_env(:orchid, :cluster_config_source_type),
      url: Application.get_env(:orchid, :cluster_config_source_url)
    }
    {:ok, source} = Source.fetch(source_props)
    {:ok, {cluster_config, service_configs}} = Source.parse()
    {:ok, cluster_config} = ClusterConfig.load(source)
    if ClusterConfig.valid?(cluster_config) do
      #
    else
      {:error, "Invalid cluster config"}
    end

    Task.async_stream(cluster_config.services, &Orchid.Service.sync/1)
  end
end
