defmodule Orchid.Docker.Controller.Container do
  require Logger
  alias Orchid.Docker.Controller

  @container_query_opts [:all, :limit, :size, :filters]

  ### Container Management

  def create(config = %OrchidSchema.Container{}, _docker_opts \\ %{}) do
    body =
      Orchid.Docker.Models.Container.dump(config)
      |> Map.merge(%{Labels: %{"orchid.managed" => "true", "orchid.service" => config.name}})

    {:ok, resp} =
      Req.post(Controller.client(),
        url: "/containers/create",
        params: [name: config.name],
        json: body
      )

    # TODO: return container ID
    Controller.handle_resp(resp)
  end

  def start(container_id) do
    {:ok, resp} = Req.post(Controller.client(), url: "/containers/#{container_id}/start")
    Controller.handle_resp(resp)
  end

  def stop(container_id) do
    {:ok, resp} = Req.post(Controller.client(), url: "/containers/#{container_id}/stop")
    Controller.handle_resp(resp)
  end

  def inspect(container_id) do
    {:ok, resp} = Req.get(Controller.client(), url: "/containers/#{container_id}/json")
    Controller.handle_resp(resp)
  end

  def delete(container_id) do
    {:ok, resp} = Req.delete(Controller.client(), url: "/containers/#{container_id}")
    Controller.handle_resp(resp)
  end

  # TODO: ensure we are able to know exactly which containers are managed by orchid

  def list_all(opts \\ []) do
    opts = Keyword.merge(opts, all: true)
    list(opts)
  end

  def list_managed(opts \\ []) do
    # TODO: make filters more composable
    # opts = Keyword.merge(opts, filters: %{label: %{:"orchid.managed" => true}})
    opts = Keyword.merge(opts, all: true, filters: %{label: ["orchid.managed=true"]})
    list(opts)
  end

  def list(opts \\ []) do
    query_opts =
      Keyword.filter(opts, fn {k, _v} -> Enum.member?(@container_query_opts, k) end)
      |> Keyword.update(:filters, nil, &Jason.encode!/1)

    {:ok, resp} = Req.get(Controller.client(), url: "containers/json", params: query_opts)
    {:ok, %{body: containers}} = Controller.handle_resp(resp)
    containers_with_details = Enum.map(containers, &(inspect_container(&1["Id"])))
    Enum.map(containers_with_details, &Orchid.Docker.Models.Container.parse_from_inspect/1)
  end

  def inspect_container(container_id) do
    {:ok, resp} = Req.get(Controller.client(), url: "/containers/#{container_id}/json")
    {:ok, %{body: container}} = Controller.handle_resp(resp)
    container
  end

  ### Additional calls

  @doc """
  Get the logs of a container.
  Options can be:
  - `stdout:` (boolean) Return logs from `stdout`
  - `stderr:` (boolean) Return logs from `stderr`
  - `since:` (integer) Only return logs since this time, as a UNIX timestamp
  - `until:` (integer) Only return logs before this time, as a UNIX timestamp
  - `timestamps:` (boolean) Add timestamps to every log line
  - `tail:` (integer) Only return this number of log lines from the end of the logs
  """
  def logs(container_id, opts) do
    opts = Keyword.merge([stdout: true, stderr: true, timestamps: true], opts)

    {:ok, resp} =
      Req.get(Controller.client(),
        url: "/containers/#{container_id}/logs",
        params: opts
      )

    Controller.handle_resp(resp)
  end
end
