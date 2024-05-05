# Deprecated
# defmodule Orchid.ServiceScheduler do
#   use GenServer

#   require Logger

#   def start_link() do
#     GenServer.start_link(__MODULE__, nil, name: __MODULE__)
#   end

#   def get() do
#     GenServer.call(__MODULE__, :get)
#   end

#   @impl true
#   def init(_) do
#     Phoenix.PubSub.subscribe(Orchid.PubSub, "service_creation")
#     Phoenix.PubSub.subscribe(Orchid.PubSub, "service_update")
#     Phoenix.PubSub.subscribe(Orchid.PubSub, "service_redeploy")
#     Phoenix.PubSub.subscribe(Orchid.PubSub, "service_deletion")
#     {:ok, %{}}
#   end

#   @impl true
#   def handle_call(:get, _, state) do
#     {:reply, state, state}
#   end

#   @impl true
#   def handle_info({:service_creation, service}, state) do
#     Logger.info("Creating service #{service.name}")
#     # TODO: fetch service
#     # service = Orchid.Repo.get_by(Orchid.Service, name: service_name)

#     # :global.trans(:"service.#{service_name}", fn ->
#     service.controller.create_service(service)
#     # end)

#     {:noreply, state}
#   end

#   @impl true
#   def handle_info({:service_update, service}, state) do
#     Logger.info("Updating service #{service.name}")

#     service.controller.update_service(service)

#     {:noreply, state}
#   end

#   @impl true
#   def handle_info(msg, state) do
#     Logger.warning("Unhandled message: #{inspect(msg)}")

#     {:noreply, state}
#   end
# end
