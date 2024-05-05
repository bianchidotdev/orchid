defmodule Orchid.Docker.Models.Container do
  use Ecto.Schema
  # TODO: make this so much less manual
  def parse(container) do
    struct(OrchidSchema.Container, %{
      id: container["Id"],
      image: container["Image"],
      name: container["Names"],
      command: container["Command"],
      state: container["State"],
      status: container["Status"],
      ports: container["Ports"],
      mounts: container["Mounts"],
      labels: container["Labels"],
      created_at: container["Created"]
    })
  end

  def parse_from_inspect(container) do
    dbg()
    struct(OrchidSchema.Container, %{
      id: container["Id"],
      image: container["Config"]["Image"],
      name: container["Name"],
      env: container["Config"]["Env"],
      working_dir: container["Config"]["WorkingDir"],
      entrypoint: container["Config"]["Entrypoint"],
      command: container["Config"]["Cmd"],
      state: container["State"]["Status"],
      status: container["State"]["Status"],
      ports: container["NetworkSettings"]["Ports"],
      mounts: container["Mounts"],
      labels: container["Config"]["Labels"],
      created_at: container["Created"]
    })
  end

  # used for POSTs to docker engine
  def dump(config) do
    %{
      "Image" => config.image,
      "Names" => config.name,
      "Env" => config.env,
      "Entrypoint" => config.entrypoint,
      "Cmd" => config.command,
      "Ports" => config.ports,
      "Mounts" => config.mounts,
      "Labels" => config.labels
    }
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end
end
