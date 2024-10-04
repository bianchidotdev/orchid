defmodule Orchid.Service do
  # def create_service(service_config) do
  #   %OrchidSchema.Service{}
  #   |> OrchidSchema.Service.changeset(service_config)
  #   |> Ecto.Changeset.apply_action(:insert)
  #   # |> Orchid.Repo.insert()
  #   |> case do
  #     # TODO: handle persistence and pass only service name/id
  #     {:ok, service} -> Phoenix.PubSub.broadcast(Orchid.PubSub, "service_creation", service)
  #     {:error, changeset} -> {:error, changeset}
  #   end
  # end

  def new(service) do
    {:ok, service} =
      %OrchidSchema.Service{}
      |> OrchidSchema.Service.changeset(service)
      |> Ecto.Changeset.apply_action(:insert)

    service

    # service
    # |> Enum.reduce(%OrchidSchema.Service{}, fn {k, v}, acc ->
    #   Map.put(acc, String.to_existing_atom(k), v)
    # end)
  end

  def get_service(%OrchidSchema.Service{} = service) do
    service.controller.get_service(service)
  end

  def create_service(%OrchidSchema.Service{} = service) do
    containers =
      Enum.map(service.containers, fn container ->
        # maybe just return changes?
        {:ok, container} = service.controller.create(container)
        %{id: container.id, container_id: container.container_id}
      end)

    {:ok, service} =
      service
      |> OrchidSchema.Service.runtime_changeset(%{containers: containers})
      |> Ecto.Changeset.apply_action(:update)

    {:ok, service}
  end

  # should be unneeded - is handled by create_service
  # def pull_images(%OrchidSchema.Service{} = service) do
  #   results =
  #     Enum.map(service.containers, fn container ->
  #       service.controller.pull_image(container["image"])
  #     end)

  #   dbg()

  #   if Enum.all?(results, fn
  #        {:ok, _} -> true
  #        {:error, _} -> false
  #      end) do
  #     {:ok, "Images pulled"}
  #   else
  #     {:error, "Failed to pull images"}
  #   end
  # end

  # def sync(%{} = service) do
  #   case reconcile(service) do
  #     {:ok, _} -> {:ok, "Service synced"}
  #     {:error, reason} -> {:error, reason}
  #   end
  # end

  # def reconcile(config) do
  #   case config.controller.get_service(config) do
  #     {:ok, :not_found} -> create_service(config)
  #     {:ok, current} -> update_service(config, current)
  #     {:error, reason} -> {:error, reason}
  #   end
  # end

  # def update_service(config, current) do
  #   {:ok, diffs} = Orchid.Models.ServiceConfig.diff(config, current)
  #   Enum.any?(diffs, Enum)

  #   case Enum.any?(diffs) do
  #     # TODO: update service
  #     true -> :ok
  #     false -> :ok
  #   end
  # # end

  # defp load(cluster, %{"name" => name, "spec" => spec}) do
  #   service = %__MODULE__{controller: cluster.controller, source: cluster.source}

  #   spec
  #   |> Enum.reduce(service, fn {k, v}, acc -> Map.put(acc, String.to_existing_atom(k), v) end)
  #   |> Map.put(:name, name)
  #   |> Map.put_new(:controller, cluster.controller)
  #   |> Map.put_new(:source, cluster.source)
  #   |> validate()
  # end

  # defp validate(%__MODULE__{} = service) do
  #   # TODO: actually validate
  #   {:ok, service}
  # end
end
