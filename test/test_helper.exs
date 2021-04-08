defmodule Utils do
  @moduledoc false

  @spec default_opts() :: keyword()
  def default_opts() do
    Application.get_all_env(:vintage_net)
  end

  @spec socket_can_child_spec(VintageNet.ifname(), String.t(), integer()) ::
          Supervisor.child_spec()
  def socket_can_child_spec(can_interfaces, interface, port) do
    %{
      id: :socketcand,
      restart: :permanent,
      shutdown: 500,
      start:
        {MuonTrap.Daemon, :start_link,
         [
           "/usr/bin/socketcand",
           [
             "-v",
             "-d",
             "--interfaces",
             "#{can_interfaces}",
             "--listen",
             "#{interface}",
             "--port",
             "#{port}"
           ],
           [
             stderr_to_stdout: true,
             log_output: :debug,
             log_prefix: "(Elixir.VintageNetCan.SocketCanConfig) "
           ]
         ]},
      type: :worker
    }
  end
end

ExUnit.start()
