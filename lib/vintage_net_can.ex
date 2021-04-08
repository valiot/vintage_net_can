defmodule VintageNetCan do
  @behaviour VintageNet.Technology

  alias VintageNet.Interface.RawConfig
  alias VintageNetCan.{CanConfig, SocketCanConfig}

  @moduledoc """
  Support for common CAN interface configurations
  Configurations for this technology are maps with a `:type` field set to
  `VintageNetCan`. The following additional fields are supported:
  * `:can` - IP command options for CAN. See VintageNet.CanConfig.
  * `:socket` - SocketCan daemon options (Optional). See VintageNet.SocketCanConfig.

  An example with only CAN configuration is:
  ```elixir
  %{type: VintageNetCan, can: %{bitrate: 500000, loopback: "on"}}
  ```

  To see all available option, execute the following shell command:

  ```bash
  ip link set can0 type can -h
  ```

  An example with CAN bus and SocketCand configuration is:
  ```elixir
  %{
    type: VintageNetCan,
    can: %{bitrate: 500000, loopback: "on"},
    socket: %{
      port: 29536,
      can_interfaces: ["can0"],
      linked_interface: "lo",
    }
  }
  ```
  """

  @impl VintageNet.Technology
  def normalize(%{type: __MODULE__} = config) do
    config
    |> CanConfig.normalize()
    |> SocketCanConfig.normalize()
  end

  @impl VintageNet.Technology
  def to_raw_config(
        ifname,
        %{type: __MODULE__, socket: %{interfaces: interfaces, linked_interface: linked_interface}} =
          config,
        opts
      ) do
    normalized_config = normalize(config)

    %RawConfig{
      ifname: ifname,
      type: __MODULE__,
      source_config: normalized_config,
      required_ifnames: Enum.uniq([ifname, linked_interface] ++ interfaces)
    }
    |> CanConfig.add_config(normalized_config, opts)
    |> SocketCanConfig.add_config(normalized_config, opts)
  end

  @impl VintageNet.Technology
  def to_raw_config(ifname, %{type: __MODULE__} = config, opts) do
    normalized_config = normalize(config)

    %RawConfig{
      ifname: ifname,
      type: __MODULE__,
      source_config: normalized_config,
      required_ifnames: [ifname]
    }
    |> CanConfig.add_config(normalized_config, opts)
    |> SocketCanConfig.add_config(normalized_config, opts)
  end

  @impl VintageNet.Technology
  def ioctl(_ifname, _command, _args) do
    {:error, :unsupported}
  end

  @impl VintageNet.Technology
  def check_system(_opts) do
    # TODO
    :ok
  end
end
