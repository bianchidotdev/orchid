defmodule Orchid.Docker.Controller do
  require Logger

  alias Orchid.Docker.Controller

  def info() do
    {:ok, resp} = Req.get(client(), url: "/info")
    {:ok, resp.body}
  end

  def create_service(config) do
    # probably do some parsing and mutations here to get docker specific config
    with {:ok, _} <- Controller.Image.create_image(config.image),
      {:ok, resp} <- Controller.Container.create(config) do
        {:ok, resp}
      else
        err -> err
    end
  end

  def get_service() do
    %{}
  end

  def client() do
    # Req.new(base_url: "http://oci", unix_socket: "/var/run/docker.sock")
    Req.new(base_url: "http://localhost:2376")
    |> Req.Request.append_response_steps(
      decode_multiplexed_stream: &decode_vnd_docker_multiplexed_stream/1
    )
  end

  def handle_resp(resp = %Req.Response{}) do
    case resp.status do
      status when status in 200..299 -> {:ok, resp}
      status when status in 400..599 -> {:error, resp.body}
      true -> {:error, "Unknown error"}
    end
  end

  # used for logs
  # returns keyword list of [stdout: "log data", stderr: "log data"]
  defp decode_vnd_docker_multiplexed_stream(
         {request,
          %{
            headers: %{"content-type" => ["application/vnd.docker.multiplexed-stream"]},
            body: body
          } =
            response}
       ) do
    decoded = process_logs_response(body)
    {request, %{response | body: decoded}}
  end

  defp decode_vnd_docker_multiplexed_stream({request, response}) do
    {request, response}
  end

  # credit to https://github.com/uhoreg from ex_remote_dockers
  defp process_logs_response(""), do: []

  # the format for the body is described at
  # https://docs.docker.com/engine/api/v1.35/#operation/ContainerAttach
  defp process_logs_response(
         # header
         <<
           stream_type,
           0,
           0,
           0,
           length::size(32),
           # data
           data::binary-size(length),
           # other streams
           rest::binary
         >>
       ) do
    type =
      case stream_type do
        0 -> :stdin
        1 -> :stdout
        2 -> :stderr
      end

    [{type, data} | process_logs_response(rest)]
  end

  defp process_logs_response(content) do
    Logger.warning("Unexpected log format - #{IO.inspect(content)}")
    content
  end
end
