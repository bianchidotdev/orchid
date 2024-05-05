defmodule Orchid.Docker.Controller.Image do
  alias Orchid.Docker.Controller
  # pulls a docker image
  # NOTE: response is multiple json objects which are not parsed by standard req parsing
  def create_image(reference) do
    {:ok, resp} =
      Req.post(Controller.client(),
        url: "/images/create",
        params: [fromImage: reference],
        into: fn {:data, data}, {req, resp} ->
          # it seems like we sometimes get mutliple lines within a single data blob
          parsed =
            data
            |> String.split("\n")
            |> Stream.map(&String.trim/1)
            |> Stream.reject(&(&1 == ""))
            |> Stream.map(&Jason.decode!/1)
            |> Enum.to_list()

          {:cont,
           {req,
            Map.update(resp, :body, [], fn
              # hack to handle initial state
              "" -> parsed
              # I know I should not be appending to the list, but that's what's easiest here
              body -> body ++ parsed
            end)}}
        end
      )

    Controller.handle_resp(resp)
  end
end
