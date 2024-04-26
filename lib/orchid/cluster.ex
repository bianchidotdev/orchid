defmodule Orchid.Cluster do
  require Logger

  alias Orchid.Models.{ClusterConfig,ServiceConfig}
  alias Orchid.{Source,Service}

  def sync() do
    # TODO: fix this way up
    source = %Source{
      type: Application.get_env(:orchid, :cluster_config_source_type),
      url: Application.get_env(:orchid, :cluster_config_source_url)
    }
    {:ok, source_data} = Source.fetch(source)
    {:ok, {cluster_config, service_configs}} = Source.parse(source_data)
    cluster = ClusterConfig.new(cluster_config)
    |> Map.put(:source, source)
    services = service_configs
    |> Enum.map(&(ServiceConfig.new(cluster, &1)))
    |> dbg()
    |> Enum.filter(&ServiceConfig.valid?/1)

    # TODO: switch to a dynamic supervisor
    Task.async_stream(services, &(Service.sync(&1)))
    |> Enum.to_list()
  end
end
