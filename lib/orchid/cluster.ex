defmodule Orchid.Cluster do
  require Logger

  alias Orchid.{Service, Source}

  # TODO: should we use static data layer and provide input from the system?
  # Or maybe the cluster data should be loaded and stored in ETS on startup,
  # but the service data should be queried from the controller?

  # on_startup:
  # * load cluster config
  # * create cluster resource
  # * load service configs
  # * start dynamic supervisor for services
  # * create service resources triggering the dynamic workers

  # on_sync:
  # * load cluster config
  # * on_update

  # on_update:
  # * update cluster resource
  # * load service configs
  # * start dynamic supervisor for new services
  # * create service resources triggering the dynamic workers
  # * update service resources triggering the dynamic workers
  # * destroy service resources triggering the dynamic workers
  # * stop dynamic supervisor for removed services

  # important events:
  # * upstream cluster config changes
  # * upstream service config changes
  # * service stopped
  # * service unhealthy
  # * node lost

  # NOTE: I don't think we'll need these - cluster and service are just data structures that are fetchable when needed
  #   def create_cluster(cluster_config) do
  #     %OrchidSchema.Cluster{}
  #     |> OrchidSchema.Cluster.changeset(cluster_config)
  #     |> Ecto.Changeset.apply_action(:insert)
  #     # |> Orchid.Repo.insert()
  #     |> case do
  #       {:ok, cluster} -> {:ok, cluster}
  #       {:error, changeset} -> {:error, changeset}
  #     end
  #   end

  #   def update_cluster(cluster_config) do
  #     %OrchidSchema.Cluster{}
  #     |> OrchidSchema.Cluster.changeset(cluster_config)
  #     |> Ecto.Changeset.apply_action(:update)
  #     # |> Orchid.Repo.update()
  #     |> case do
  #       {:ok, cluster} -> {:ok, cluster}
  #       {:error, changeset} -> {:error, changeset}
  #     end
  #   end
  # end

  # NOTE: old hand-rolled cluster config loading - now using ecto schemas
  #   def sync() do
  #     # TODO: fix this way up
  #     source = %Source{
  #       type: Application.get_env(:orchid, :cluster_config_source_type),
  #       url: Application.get_env(:orchid, :cluster_config_source_url)
  #     }

  #     {:ok, {cluster, services}} = load(source)

  #     # TODO: switch to a dynamic supervisor
  #     Task.async_stream(services, &Service.sync(&1))
  #     |> Enum.to_list()
  #   end

  def load(source) do
    with {:ok, source_data} <- Source.fetch(source),
         {:ok, {cluster_config, service_configs}} <- Source.parse(source_data) do
      cluster =
        new(cluster_config)
        |> Map.put(:source, source)

      services =
        service_configs
        |> Enum.map(&Service.new/1)

      # TODO: load additional service configs
      # services =
      #   service_configs
      #   |> Enum.map(&Service.load(cluster, &1))
      #   |> Enum.filter(&ServiceConfig.valid?/1)

      {:ok, {cluster, services}}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  def new(%{"version" => "v0.1"} = cluster) do
    cluster
    |> Enum.reduce(%OrchidSchema.Cluster{}, fn {k, v}, acc ->
      Map.put(acc, String.to_existing_atom(k), v)
    end)
  end

  def new(_), do: raise("Invalid cluster config, must have version and spec keys")

  #   # TODO: validate
end
