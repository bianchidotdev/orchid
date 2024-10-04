defmodule Orchid.Scheduler do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  def deploy_service(service) do
    GenServer.call(__MODULE__, {:deploy_service, service}, 30_000)
  end

  @impl true
  def init(_cluster_source) do
    # synchronously load the cluster to ensure it's configured properly
    # {:ok, {cluster, services}} = Orchid.Cluster.load(cluster_source)
    # TODO: start up dynamic source syncers
    Phoenix.PubSub.subscribe(Orchid.PubSub, "cluster_reload")
    Phoenix.PubSub.subscribe(Orchid.PubSub, "service_reload")
    # Process.send(self(), :sync_services)
    # {:ok, %{cluster: cluster, services: services}}
    {:ok, %{}}
  end

  # @impl true
  # def handle_call(:get, _, state) do
  #   {:reply, state, state}
  # end

  @impl true
  def handle_info({:cluster_reload, source}, _state) do
    Logger.info("Reloading cluster from #{source}")
  end

  @impl true
  def handle_info({:service_source_reload, source}, _state) do
    Logger.info("Reloading services from #{source}")
  end

  @impl true
  def handle_info(:sync_services, _state) do
    Logger.info("Syncing services")
    # triggers deployments
  end

  # Pulls information from all nodes about fitness and running containers
  # Considers all containers running a different deployment hash as old
  # Pull image on all nodes that will run new containers
  # Immediate fail if can’t pull the image
  # Will first start new containers based on node fitness
  # It will start all new containers before updating proxy information
  # Validate health checks with manual requests (or rely on docker health checks?)
  # Then post new application routing config to proxy containers
  # Begin deleting old containers
  # Do not delete old images unless specifically configured
  @impl true
  # TODO: what type of method should this be?
  def handle_call({:deploy_service, service}, _from, state) do
    Logger.info("Deploying services")

    all_nodes = Orchid.Node.get_nodes()

    existing_service_containers =
      Enum.flat_map(all_nodes, fn node ->
        Orchid.Node.exec(node, Orchid.Service, :get_service, [service])
      end)

    target_nodes =
      all_nodes
      |> Enum.filter(&Orchid.Node.capable?(&1, service))
      |> Enum.sort_by(&Map.get(&1, :score), :desc)
      |> Stream.cycle()
      |> Stream.take(service.count)

    # Presently implemented in create_service
    # image_results =
    #   target_nodes
    #   |> Enum.uniq()
    #   |> Enum.map(fn node ->
    #     Orchid.Node.exec(node, Orchid.Service, :pull_images, [service])
    #   end)

    # true = Enum.all?(image_results, fn {res, _} -> res == :ok end)

    # TODO: perform in batches
    container_results =
      Enum.map(target_nodes, fn node ->
        Orchid.Node.exec(node, Orchid.Service, :create_service, [service])
      end)

    dbg()

    true = Enum.all?(container_results, fn {res, _} -> res == :ok end)
    # TODO: health check?

    # {:ok, _} = Orchid.Proxy.update_service(service)

    container_cleanup_results =
      existing_service_containers
      |> Enum.map(fn container ->
        Orchid.Node.exec(container.node, Orchid.Service, :destroy_container, [container])
      end)

    true = Enum.all?(container_cleanup_results, fn {res, _} -> res == :ok end)

    {:noreply, state}
  end
end
