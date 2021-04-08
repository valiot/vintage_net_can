`VintageNetCan` adds support to `VintageNet` for CAN bus
connections, through IP and Socketcand commands.

Assuming that your device has a CAN bus hardware and drivers, all you need to do is add
`:vintage_net_can` to your `mix` dependencies like this:

```elixir
def deps do
  [
    {:vintage_net_can, github: "valiot/vintage_net_can", targets: @all_targets}
  ]
end
```

## Using

The CAN bus overlays and drivers are not shipped by default in the official Nerves Targets,
you can follow the next [slides](https://www.slideshare.net/brien_wankel/customize-your-car-an-adventure-in-using-elixir-and-nerves-to-hack-your-vehicles-electronics-network) to add all requirements or check the following [Nerves Custom System](https://github.com/valiot/valiot_system_rpi3).

Basically, the following options were added:
```
# linux-xxx.defconfig
CONFIG_CAN=y
CONFIG_CAN_MCP251X=y

# nerves_defconfig 
BR2_PACKAGE_LIBSOCKETCAN=y
BR2_PACKAGE_CAN_UTILS=y
BR2_PACKAGE_IPROUTE2=y
BR2_PACKAGE_SOCKETCAND=y

```

CAN bus interfaces typically have names like `"can0"`, `"can1"`, etc.
when using Nerves.

An example of the most basic CAN bus configuration is:

```elixir
config :vintage_net,
  config: [
    {
      "can0",
      %{
        type: VintageNetCan,
        can: %{bitrate: 500_000}
      }
    }
  ]
```

You can also set the configuration at runtime:

```elixir
iex> VintageNet.configure("can0", %{type: VintageNetCan, can: %{bitrate: 500_000}})
:ok
```
## FD Mode

Depending on your hardware this mode may or may not be available. An example of a CAN FD configuration is:

```elixir
config :vintage_net,
  config: [
    {
      "can0",
      %{
        type: VintageNetCan,
        can: %{
            bitrate: 500_000,
            fd: "on",
            dbitrate: 1_000_000,
            berr_reporting: "on"
          }
      }
    }
  ]
```

## Socketcand

`VintageNetCan` also provides access to CAN interfaces on a machine via a network interface by using [socketcand] deamon
The communication protocol uses a TCP/IP connection and a specific protocol to transfer CAN frames and control commands. 

Here's a CAN & Socketcand configuration:

```elixir
iex> VintageNet.configure("can0", %{
    type: VintageNetCan,
    can: %{bitrate: 500_000},
    socket: %{
      port: 29536,
      can_interfaces: ["can0"],
      linked_interface: "lo",
    }
  })
:ok
```

In the above, the CAN interface is exposed by link it to the Local Loopback interface (`lo`) using the 29536 port.

To see all possible parameters, please refer to the following references:
  * [SocketCand](https://github.com/linux-can/socketcand).
  * `VintageNetCan.SocketCanConfig`.
  * `VintageNetCan.CanConfig`.


## Properties

There are CAN-specific properties. See `vintage_net` for the
default set of properties for all interface types.
