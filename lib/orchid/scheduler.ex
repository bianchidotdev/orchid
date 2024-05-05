defmodule Orchid.Scheduler do
  use GenServer

  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(cluster_source) do
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
  def handle_info({:cluster_reload, source}, state) do
    Logger.info("Reloading cluster from #{source}")
  end

  def handle_info({:service_source_reload, source}, state) do
    Logger.info("Reloading services from #{source}")
  end

  def handle_info(:sync_services, _state) do
    nodes = NodeManager.get_nodes()
    node_info = Enum.map(nodes, fn node -> Orchid.Node.get_info(node) end)

    Logger.info("Syncing services")
  end
end
