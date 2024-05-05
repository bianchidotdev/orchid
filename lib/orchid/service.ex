defmodule Orchid.Service do
  defstruct source: nil,
            controller: Orchid.Docker.Controller,
            name: nil,
            containers: []

  # @require_deploy [
  #   :image
  # ]

  def create_service(service_config) do
    %OrchidSchema.Service{}
    |> OrchidSchema.Service.changeset(service_config)
    |> Ecto.Changeset.apply_action(:insert)
    # |> Orchid.Repo.insert()
    |> case do
      # TODO: handle persistence and pass only service name/id
      {:ok, service} -> Phoenix.PubSub.broadcast(Orchid.PubSub, "service_creation", service)
      {:error, changeset} -> {:error, changeset}
    end
  end

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
