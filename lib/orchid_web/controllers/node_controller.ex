defmodule OrchidWeb.NodeController do
  use OrchidWeb, :controller

  def index(conn, _params) do
    # TODO: execute on all nodes
    # nodes = [Node.self() |  Node.list(:connected)]
    {:ok, this_info} = Orchid.Docker.Controller.info()
    nodes_info = [{Node.self(), this_info}]
    render(conn, :index, nodes: nodes_info)
  end

  def show(conn, %{"node" => node}) do
    render(conn, :show, node: node)
  end
end
