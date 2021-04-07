defmodule VintageNetCan.CanConfig do
  @moduledoc """
  This is a helper module for VintageNet.Technology implementations that use
  IP shell Command.

  IP configuration is specified under the `:can` key in the configuration map.
  The `:can` method uses the following fields (only `bitrate` is required):
  * `:bitrate` - The number of bits per second transmitted.
  * `:sample_point` - The point in the bit time in which the logic level is read and interpreted.
  * `:tq` - Time Quanta.
  * `:prop_seg` - Propagation Segment, which exists to compensate for physical delays between nodes.
  * `:phase_seg1` - Phase Segment 1, used to compensate for edge phase errors on the bus.
  * `:phase_seg2` - Phase Segment 2, used to compensate for edge phase errors on the bus.
  * `:sjw` - Synchronization Jump Width.
  * `:berr_reporting` - Report bit errors ("on" or "off").
  * `:listen_only` - read only bus ("on" or "off").
  * `:loopback` - ("on" or "off").
  * `:triple_sampling` - ("on" or "off").
  * `:one_shot` - ("on" or "off").

  # Fixed data Rate parameters

  * `:fd` - Enables the Flexible Data Rate Mode, CAN FD, it accepts "on" or "off" value.
  * `:dbitrate` - The number of bits per second transmitted.
  * `:dsample_point` - The point in the bit time in which the logic level is read and interpreted.
  * `:dtq` - Time Quanta.
  * `:dprop_seg` - Propagation Segment, which exists to compensate for physical delays between nodes.
  * `:dphase_seg1` - Phase Segment 1, used to compensate for edge phase errors on the bus.
  * `:dphase_seg2` - Phase Segment 2, used to compensate for edge phase errors on the bus.
  * `:dsjw` - Synchronization Jump Width.

  For more information check the following references:
    * [Understanding Microchip’s CAN Module Bit Timing](http://ww1.microchip.com/downloads/en/appnotes/00754.pdf)
  """

  alias VintageNet.Interface.RawConfig
  alias VintageNet.Command

  @default_bitrate [1_000_000, 500_000, 250_000, 125_000, 62500]
  @default_ip_enabled_options ["on", "off"]
  @fd_keys [:dbitrate, :dsample_point, :dtq, :dprop_seg, :dphase_seg1, :dphase_seg2, :dswj]

  @ip_params_key %{
    bitrate: "bitrate",
    sample_point: "sample-point",
    tq: "tq",
    prop_seg: "prop-seg",
    phase_seg1: "phase-seg1",
    phase_seg2: "phase-seg2",
    sjw: "sjw",
    berr_reporting: "berr-reporting",
    listen_only: "listen-only",
    loopback: "loopback",
    triple_sampling: "triple-sampling",
    one_shot: "one-shot",
    fd: "fd",
    dbitrate: "dbitrate",
    dsample_point: "dsample-point",
    dtq: "dtq",
    dprop_seg: "dprop-seg",
    dphase_seg1: "dphase-seg1",
    dphase_seg2: "dphase-seg2",
    dsjw: "dsjw",
  }

  @doc """
  Validates the IP parameters in a configuration.
  """
  @spec normalize(map()) :: map()
  def normalize(%{can: ip_can_params} = config) do
    ip_can_params
    |> validate_bitrate()
    |> validate_sample_point()
    |> validate_tq()
    |> validate_prop_seg()
    |> validate_phase_seg1()
    |> validate_phase_seg2()
    |> validate_sjw()
    |> validate_berr_reporting()
    |> validate_listen_only()
    |> validate_loopback()
    |> validate_triple_sampling()
    |> validate_one_shot()
    |> validate_fd_enabled_with_fd_keys()
    |> validate_fd()
    |> validate_dbitrate()
    |> validate_dsample_point()
    |> validate_dtq()
    |> validate_dprop_seg()
    |> validate_dphase_seg1()
    |> validate_dphase_seg2()
    |> validate_dsjw()

    config
  end

  def normalize(config) do
    # No CAN IP configuration, set default: bitrate => 125kbps.
    Map.put(config, :can, %{bitrate: 125_000})
  end

  # Bitrate
  defp validate_bitrate(%{bitrate: bitrate} = config) when bitrate in @default_bitrate,
    do: config

  defp validate_bitrate(_other) do
    raise ArgumentError,
          "Specify or invalid bitrate, only default bitrate is supported #{
            inspect(@default_bitrate)
          }"
  end

  # Sample point
  defp validate_sample_point(%{sample_point: sample_point} = config)
       when 0.0 <= sample_point and sample_point <= 0.999,
       do: config

  defp validate_sample_point(%{sample_point: sample_point}) do
    raise ArgumentError,
          "Invalid sample point: #{inspect(sample_point)}, only float values between 0.0 <= sample point <= 0.999 are allowed"
  end

  # Sample point parameter is not provided.
  defp validate_sample_point(config), do: config

  # Time Quanta
  defp validate_tq(%{tq: tq} = config) when is_number(tq),
    do: config

  defp validate_tq(%{tq: tq}),
    do: raise(ArgumentError, "Invalid TQ: #{inspect(tq)}, only numbers are allowed")

  # Time Quanta parameter is not provided.
  defp validate_tq(config), do: config

  # Propagation Segment
  defp validate_prop_seg(%{prop_seg: prop_seg} = config) when prop_seg in 1..8,
    do: config

  defp validate_prop_seg(%{prop_seg: prop_seg}),
    do:
      raise(
        ArgumentError,
        "Invalid Propagation Segment: #{inspect(prop_seg)}, only integers between 1 <= prop_seg <= 8 are allowed"
      )

  # Propagation Segment parameter is not provided.
  defp validate_prop_seg(config), do: config

  # Phase Segment 1
  defp validate_phase_seg1(%{phase_seg1: phase_seg1} = config) when phase_seg1 in 1..8,
    do: config

  defp validate_phase_seg1(%{phase_seg1: phase_seg1}),
    do:
      raise(
        ArgumentError,
        "Invalid Phase Segment 1: #{inspect(phase_seg1)}, only integers between 1 <= phase_seg1 <= 8 are allowed"
      )

  # Phase Segment 1 parameter is not provided.
  defp validate_phase_seg1(config), do: config

  # Phase Segment 2
  defp validate_phase_seg2(%{phase_seg2: phase_seg2} = config) when phase_seg2 in 1..8,
    do: config

  defp validate_phase_seg2(%{phase_seg2: phase_seg2}),
    do:
      raise(
        ArgumentError,
        "Invalid Phase Segment 2: #{inspect(phase_seg2)}, only integers between 1 <= phase_seg2 <= 8 are allowed"
      )

  # Phase Segment 2 parameter is not provided.
  defp validate_phase_seg2(config), do: config

  # Synchronization Jump Width
  defp validate_sjw(%{sjw: sjw} = config) when sjw in 1..4,
    do: config

  defp validate_sjw(%{sjw: sjw}),
    do:
      raise(
        ArgumentError,
        "Invalid Synchronization Jump Width: #{inspect(sjw)}, only integers between 1 <= sjw <= 4 are allowed"
      )

  # Synchronization Jump Width parameter is not provided.
  defp validate_sjw(config), do: config

  # Bit error reporting enabled
  defp validate_berr_reporting(%{berr_reporting: berr_reporting} = config)
       when berr_reporting in @default_ip_enabled_options,
       do: config

  defp validate_berr_reporting(%{berr_reporting: berr_reporting}),
    do:
      raise(
        ArgumentError,
        "Invalid Bit error reporting enabled: #{inspect(berr_reporting)}, only \"on\" or \"off\" options are allowed"
      )

  # Bit error reporting enabled parameter is not provided.
  defp validate_berr_reporting(config), do: config

  # Listen only enabled
  defp validate_listen_only(%{listen_only: listen_only} = config)
       when listen_only in @default_ip_enabled_options,
       do: config

  defp validate_listen_only(%{listen_only: listen_only}),
    do:
      raise(
        ArgumentError,
        "Invalid Listen only enabled: #{inspect(listen_only)}, only \"on\" or \"off\" options are allowed"
      )

  # Listen only enabled parameter is not provided.
  defp validate_listen_only(config), do: config

  # Loopback enabled
  defp validate_loopback(%{loopback: loopback} = config)
       when loopback in @default_ip_enabled_options,
       do: config

  defp validate_loopback(%{loopback: loopback}),
    do:
      raise(
        ArgumentError,
        "Invalid Loopback enabled: #{inspect(loopback)}, only \"on\" or \"off\" options are allowed"
      )

  # Loopback enabled parameter is not provided.
  defp validate_loopback(config), do: config

  # Triple sampling enabled
  defp validate_triple_sampling(%{triple_sampling: triple_sampling} = config)
       when triple_sampling in @default_ip_enabled_options,
       do: config

  defp validate_triple_sampling(%{triple_sampling: triple_sampling}),
    do:
      raise(
        ArgumentError,
        "Invalid Triple sampling enabled: #{inspect(triple_sampling)}, only \"on\" or \"off\" options are allowed"
      )

  # Triple Sampling enabled parameter is not provided.
  defp validate_triple_sampling(config), do: config

  # One shot enabled
  defp validate_one_shot(%{one_shot: one_shot} = config)
       when one_shot in @default_ip_enabled_options,
       do: config

  defp validate_one_shot(%{one_shot: one_shot}),
    do:
      raise(
        ArgumentError,
        "Invalid One shot enabled: #{inspect(one_shot)}, only \"on\" or \"off\" options are allowed"
      )

  # One shot enabled parameter is not provided.
  defp validate_one_shot(config), do: config

  # If the :fd key is set to "off" or is not provided and another fd_keys are used, then raise an error.
  def validate_fd_enabled_with_fd_keys(config) do
    with true <- is_nil(config[:fd]) or config[:fd] == "off",
         keys <- Map.keys(config),
         true <- Enum.any?(keys, fn key -> key in @fd_keys end) do
      raise ArgumentError,
            "There are several FD keys in the IP parameters without enabling FD option, please set :fd key to \"on\""
    else
      _ ->
        config
    end
  end

  # Fixed Data Rate Mode Enabled
  defp validate_fd(%{fd: fd} = config) when fd in @default_ip_enabled_options,
    do: config

  defp validate_fd(%{fd: fd}),
    do:
      raise(
        ArgumentError,
        "Invalid FD Mode: #{inspect(fd)}, only \"on\" or \"off\" options are allowed"
      )

  # Fixed Data Rate Mode Enabled parameter is not provided.
  defp validate_fd(config), do: config

  # (FD) Bitrate
  defp validate_dbitrate(%{dbitrate: dbitrate} = config) when dbitrate in @default_bitrate,
    do: config

  defp validate_dbitrate(%{dbitrate: _dbitrate}) do
    raise ArgumentError,
          "Specify or invalid bitrate, only default bitrate is supported #{
            inspect(@default_bitrate)
          }"
  end

  # (FD) Bitrate parameter is not provided.
  defp validate_dbitrate(config), do: config

  # (FD) Sample point
  defp validate_dsample_point(%{dsample_point: dsample_point} = config)
       when 0.0 <= dsample_point and dsample_point <= 0.999,
       do: config

  defp validate_dsample_point(%{dsample_point: dsample_point}) do
    raise ArgumentError,
          "Invalid sample point: #{inspect(dsample_point)}, only float values between 0.0 <= dsample_point <= 0.999 are allowed"
  end

  # (FD) Sample point parameter is not provided.
  defp validate_dsample_point(config), do: config

  # (FD) Time Quanta
  defp validate_dtq(%{dtq: dtq} = config) when is_number(dtq),
    do: config

  defp validate_dtq(%{dtq: dtq}),
    do: raise(ArgumentError, "Invalid dTQ: #{inspect(dtq)}, only numbers are allowed")

  # (FD) Time Quanta parameter is not provided.
  defp validate_dtq(config), do: config

  # (FD) Propagation Segment
  defp validate_dprop_seg(%{dprop_seg: dprop_seg} = config) when dprop_seg in 1..8,
    do: config

  defp validate_dprop_seg(%{dprop_seg: dprop_seg}),
    do:
      raise(
        ArgumentError,
        "Invalid Propagation Segment: #{inspect(dprop_seg)}, only integers between 1 <= dprop_seg <= 8 are allowed"
      )

  # (FD) Propagation Segment parameter is not provided.
  defp validate_dprop_seg(config), do: config

  # (FD) Phase Segment 1
  defp validate_dphase_seg1(%{dphase_seg1: dphase_seg1} = config) when dphase_seg1 in 1..8,
    do: config

  defp validate_dphase_seg1(%{dphase_seg1: dphase_seg1}),
    do:
      raise(
        ArgumentError,
        "Invalid Phase Segment 1: #{inspect(dphase_seg1)}, only integers between 1 <= dphase_seg1 <= 8 are allowed"
      )

  # (FD) Phase Segment 1 parameter is not provided.
  defp validate_dphase_seg1(config), do: config

  # (FD) Phase Segment 2
  defp validate_dphase_seg2(%{dphase_seg2: dphase_seg2} = config) when dphase_seg2 in 1..8,
    do: config

  defp validate_dphase_seg2(%{dphase_seg2: dphase_seg2}),
    do:
      raise(
        ArgumentError,
        "Invalid Phase Segment 2: #{inspect(dphase_seg2)}, only integers between 1 <= dphase_seg2 <= 8 are allowed"
      )

  # (FD) Phase Segment 2 parameter is not provided.
  defp validate_dphase_seg2(config), do: config

  # (FD) Synchronization Jump Width
  defp validate_dsjw(%{dsjw: dsjw} = config) when dsjw in 1..4,
    do: config

  defp validate_dsjw(%{dsjw: dsjw}),
    do:
      raise(
        ArgumentError,
        "Invalid Synchronization Jump Width: #{inspect(dsjw)}, only integers between 1 <= dsjw <= 4 are allowed"
      )

  # (FD) Synchronization Jump Width parameter is not provided.
  defp validate_dsjw(config), do: config

  @doc """
  Add IP configuration commands for supporting CAN bus.
  """
  @spec add_config(RawConfig.t(), map(), keyword()) :: RawConfig.t()
  def add_config(
        %RawConfig{
          ifname: ifname,
          up_cmds: up_cmds,
          down_cmds: down_cmds
        } = raw_config,
        %{can: can_config},
        _opts
      ) do
      
    ip_cmd_params = ["link", "set", ifname, "up", "type", "can"] ++ build_can_params(can_config)
    new_up_cmds = up_cmds ++ [{:run, "ip", ip_cmd_params}]

    new_down_cmds = down_cmds ++ [{:run, "ip", ["link", "set", ifname, "down"]}]

    %RawConfig{
      raw_config
      | up_cmds: new_up_cmds,
        down_cmds: new_down_cmds
    }
  end

  def build_can_params(can_config) do
    Enum.reduce(can_config, [], fn({can_key, value}, acc) -> acc ++ [@ip_params_key[can_key], "#{value}"] end)
  end
end
