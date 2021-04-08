defmodule VintageNetCan.SocketCanConfig do
  @moduledoc """
  This is a helper module for VintageNet.Technology implementations that use
  SocketCand daemon that provides access to CAN interfaces on a machine via a network interface. 

  SocketCand paramters are specified under the `:socket` key in the configuration map.
  The `:socket` method uses the following fields:
  * `:can_interfaces` - The list of SocketCAN interfaces the daemon shall provide access.
  * `:port` - The listening port.
  * `:linked_interface` - The interface linked to the daemon.
  * `:no_beacon` - deactivates the discovery beacon (set `true` to disable); default: `false`.

  For more information check the following reference:
    * [SocketCand](https://github.com/linux-can/socketcand)
  """

  alias VintageNet.Interface.RawConfig
  alias VintageNet.Command

  @socket_can_params_key %{
    can_interfaces: "--interfaces",
    port: "--port",
    linked_interface: "--listen",
    no_beacon: "--no-beacon"
  }

  @doc """
  Validates the IP parameters in a configuration.
  """
  @spec normalize(map()) :: map()
  def normalize(%{socket: socket_can_params} = config) do
    socket_can_params
    |> validate_can_interfaces()
    |> validate_port()
    |> validate_linked_interface()
    |> validate_no_beacon()

    config
  end

  def normalize(config) do
    # No SocketCand parameters, leave the config untouched.
    config
  end

  # Can Interfaces
  defp validate_can_interfaces(%{can_interfaces: can_interfaces} = config)
       when is_list(can_interfaces) do
    with available_interfaces <- VintageNet.all_interfaces(),
         true <- all_can_interfaces_must_be_available(can_interfaces, available_interfaces) do
      config
    else
      _ ->
        raise ArgumentError,
              "There is at least a CAN Interface unavailable: #{inspect(can_interfaces)}"
    end
  end

  defp validate_can_interfaces(config),
    do:
      raise(
        ArgumentError,
        "Invalid CAN Interface: #{inspect(config)}, it must be a list of interface names (string)"
      )

  defp all_can_interfaces_must_be_available(can_interfaces, available_interfaces) do
    Enum.all?(can_interfaces, fn interface -> interface in available_interfaces end)
  end

  # Port
  defp validate_port(%{port: port} = config) when is_integer(port) and port > 0,
    do: config

  defp validate_port(config),
    do:
      raise(
        ArgumentError,
        "Invalid Port: #{inspect(config)}, only positive integers are allowed."
      )

  # Linked Interface
  defp validate_linked_interface(%{linked_interface: linked_interface} = config)
       when is_binary(linked_interface) do
    with available_interfaces <- VintageNet.all_interfaces(),
         true <- all_can_interfaces_must_be_available([linked_interface], available_interfaces) do
      config
    else
      _ ->
        raise ArgumentError, "The linked interface is not available: #{inspect(linked_interface)}"
    end
  end

  defp validate_linked_interface(config),
    do:
      raise(
        ArgumentError,
        "The linked interface is required, SocketCand Parameters: #{inspect(config)}"
      )

  # No Beacon
  defp validate_no_beacon(%{no_beacon: no_beacon} = config) when is_boolean(no_beacon),
    do: config

  defp validate_no_beacon(%{no_beacon: no_beacon}),
    do:
      raise(ArgumentError, "Invalid no_beacon: #{inspect(no_beacon)}, only booleans are allowed")

  # Sample point parameter is not provided.
  defp validate_no_beacon(config),
    do: config

  @doc """
  Add socketcand configuration commands to provide access to CAN interfaces via a network interface.
  """
  @spec add_config(RawConfig.t(), map(), keyword()) :: RawConfig.t()
  def add_config(
        %RawConfig{child_specs: child_specs} = raw_config,
        %{socket: socket_can_config},
        _opts
      ) do
    new_child_specs =
      with socketcand_exec <- get_executable(),
           false <- is_nil(socketcand_exec),
           socketcand_params <- build_socketcand_params(socket_can_config) do
        child_specs ++
          [
            Supervisor.child_spec(
              {MuonTrap.Daemon,
               [
                 socketcand_exec,
                 ["-v", "-d"] ++ socketcand_params,
                 Command.add_muon_options(
                   stderr_to_stdout: true,
                   log_output: :debug,
                   log_prefix: "(#{__MODULE__}) "
                 )
               ]},
              id: :socketcand
            )
          ]
      else
        _ ->
          raise ArgumentError, "Socketcand command not found"
      end

    %RawConfig{raw_config | child_specs: new_child_specs}
  end

  def add_config(raw_config, _can_config, _opts) do
    # No SocketCand parameters, leave the config untouched.
    raw_config
  end

  defp get_executable(), do: Elixir.System.find_executable("socketcand")

  defp build_socketcand_params(socket_can_config) do
    Enum.reduce(socket_can_config, [], fn {socket_can_key, value}, acc ->
      cond do
        socket_can_key == :no_beacon and value ->
          acc ++ [@socket_can_params_key[socket_can_key]]

        socket_can_key == :no_beacon and not value ->
          acc ++ []

        true ->
          acc ++ [@socket_can_params_key[socket_can_key], "#{value}"]
      end
    end)
  end
end
