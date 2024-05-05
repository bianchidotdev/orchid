defmodule Orchid.Scheduler do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
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

  @impl true
  def handle_info({:deploy_service, service}, state) do
    Logger.info("Deploying services")

    target_nodes = Orchid.Node.get_nodes()
    |> Enum.filter(&(Orchid.Node.capable?(&1, service)))
    |> Enum.sort_by(&(Map.get(&1, :score)), :desc)
    |> Stream.cycle()
    |> Stream.take(service.count)

    Enum.map(target_nodes, fn node ->
      Orchid.Node.deploy_service(node, service)
    end)

    {:noreply, state}
  end
end
