defmodule Orchid.Service do
  # @require_deploy [
  #   :image
  # ]

  def reconcile(config) do
    case config.controller.get_service(config) do
      {:ok, :not_found} -> create_service(config)
      {:ok, current} -> update_service(config, current)
      {:error, reason} -> {:error, reason}
    end
  end

  def create_service(config) do
    config.controller.create_service(config)
  end

  def update_service(config, current) do
    {:ok, diffs} = Orchid.ServiceConfig.diff(config, current)
    Enum.any?(diffs, Enum)
    case Enum.any?(diffs) do
      true -> :ok # TODO: update service
      false -> :ok
    end
  end
end
