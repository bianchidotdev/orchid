defmodule Orchid.Docker.Models.Container do
  defstruct id: nil,
            image: nil,
            name: nil,
            env: nil,
            user: nil,
            working_dir: nil,
            entrypoint: nil,
            command: nil,
            state: nil,
            status: nil,
            ports: nil,
            mounts: nil,
            network_settings: nil,
            labels: nil,
            created: nil

  # TODO: make this so much less manual
  def parse(container) do
    %__MODULE__{
      id: container["Id"],
      image: container["Image"],
      name: container["Names"],
      env: container["Env"],
      user: container["User"],
      working_dir: container["WorkingDir"],
      entrypoint: container["Entrypoint"],
      command: container["Cmd"],
      state: container["State"],
      status: container["Status"],
      ports: container["Ports"],
      mounts: container["Mounts"],
      network_settings: container["NetworkSettings"],
      labels: container["Labels"],
      created: container["Created"]
    }
  end

  # used for POSTs to docker engine
  def dump(config) do
    %{
      "Image" => config.image,
      "Names" => config.name,
      "Env" => config.env,
      "User" => config.user,
      "WorkingDir" => config.working_dir,
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
