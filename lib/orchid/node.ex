defmodule Orchid.Node do
  def get_nodes() do
    Node.list([:this, :connected])
    |> Enum.map(&new/1)
  end

  def new(node) do
    attrs = %{
      name: node,
      system_info: system_info(node)
      # TODO: containers
    }
    {:ok, struct} = %OrchidSchema.Node{}
    |> OrchidSchema.Node.changeset(attrs)
    |> Ecto.Changeset.apply_action(:insert)
    struct
  end

  def capable?(_node, _service) do
    # TODO
    true
  end

  def exec(node, module, function, args) do
    :rpc.call(node.name, module, function, args)
  end

  def deploy_service(node, service) do
    :rpc.call(node.name, Orchid.Service, :create_service, [service])
  end

  def system_info(node) do
    %{
      node: node,
      beam_info: Phoenix.LiveDashboard.SystemInfo.fetch_system_info(node, nil, Orchid),
      os_info: Phoenix.LiveDashboard.SystemInfo.fetch_os_mon_info(node)
    }
    |> calculate_system_info()
  end

  def calculate_system_info(%{node: node, beam_info: beam_info, os_info: os_info}) do
    cpu_data = calculate_cpu_data(os_info)
    %{
      node: node,
      system_architecture: beam_info.system_info.system_architecture,
      elixir_version: beam_info.system_info.elixir_version,
      app_version: beam_info.system_info.app_version,
      uptime: beam_info.system_usage.uptime,
      orchid_memory: beam_info.system_usage.memory,
      system_memory: os_info.system_mem,
      cpu_data: cpu_data
    }
  end

  defp calculate_cpu_data(%{cpu_avg1: num1, cpu_avg5: num5, cpu_avg15: num15} = os_mon)
       when is_number(num1) and is_number(num5) and is_number(num15) do
    count = length(os_mon.cpu_per_core)

    %{
      count: count,
      load1: rup(num1),
      load5: rup(num5),
      load15: rup(num15),
      avg1: rup_avg(num1, count),
      avg5: rup_avg(num5, count),
      avg15: rup_avg(num15, count)
    }
  end

  defp calculate_cpu_data(_), do: nil

  defp rup(value), do: Float.ceil(value / 256, 2)

  defp rup_avg(_value, 0), do: 0
  defp rup_avg(value, count), do: Float.ceil(value / 256 / count, 2)
end
