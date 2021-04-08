defmodule VintageNetCanTest do
  use ExUnit.Case
  alias VintageNet.Interface.RawConfig
  alias VintageNetCan, as: CAN
  alias VintageNetCan.{SocketCanConfig, CanConfig}

  test "CAN validation" do
    bad_config = %{can: %{bitrate: 103}}

    assert_raise(
      ArgumentError,
      "Specify or invalid bitrate, only default bitrate is supported [1000000, 500000, 250000, 125000, 62500]",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{can: %{bitrate: 1_000_000, sample_point: 103}}

    assert_raise(
      ArgumentError,
      "Invalid sample point: 103, only float values between 0.0 <= sample point <= 0.999 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{can: %{bitrate: 1_000_000, sample_point: 0.103, tq: "error"}}

    assert_raise(ArgumentError, "Invalid TQ: \"error\", only numbers are allowed", fn ->
      CanConfig.normalize(bad_config)
    end)

    bad_config = %{can: %{bitrate: 1_000_000, sample_point: 0.103, tq: 103, prop_seg: "error"}}

    assert_raise(
      ArgumentError,
      "Invalid Propagation Segment: \"error\", only integers between 1 <= prop_seg <= 8 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{bitrate: 1_000_000, sample_point: 0.103, tq: 103, prop_seg: 1, phase_seg1: "error"}
    }

    assert_raise(
      ArgumentError,
      "Invalid Phase Segment 1: \"error\", only integers between 1 <= phase_seg1 <= 8 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Phase Segment 2: \"error\", only integers between 1 <= phase_seg2 <= 8 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Synchronization Jump Width: \"error\", only integers between 1 <= sjw <= 4 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Bit error reporting enabled: \"error\", only \"on\" or \"off\" options are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Listen only enabled: \"error\", only \"on\" or \"off\" options are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Loopback enabled: \"error\", only \"on\" or \"off\" options are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Triple sampling enabled: \"error\", only \"on\" or \"off\" options are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid One shot enabled: \"error\", only \"on\" or \"off\" options are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid FD Mode: \"error\", only \"on\" or \"off\" options are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 103
      }
    }

    assert_raise(
      ArgumentError,
      "Specify or invalid bitrate, only default bitrate is supported [1000000, 500000, 250000, 125000, 62500]",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "off",
        dbitrate: 1_000_000
      }
    }

    assert_raise(
      ArgumentError,
      "There are several FD keys in the IP parameters without enabling FD option, please set :fd key to \"on\"",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 1_000_000,
        dsample_point: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid sample point: \"error\", only float values between 0.0 <= dsample_point <= 0.999 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 1_000_000,
        dsample_point: 0.103,
        dtq: "error"
      }
    }

    assert_raise(ArgumentError, "Invalid dTQ: \"error\", only numbers are allowed", fn ->
      CanConfig.normalize(bad_config)
    end)

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 1_000_000,
        dsample_point: 0.103,
        dtq: 103,
        dprop_seg: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Propagation Segment: \"error\", only integers between 1 <= dprop_seg <= 8 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 1_000_000,
        dsample_point: 0.103,
        dtq: 103,
        dprop_seg: 1,
        dphase_seg1: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Phase Segment 1: \"error\", only integers between 1 <= dphase_seg1 <= 8 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 1_000_000,
        dsample_point: 0.103,
        dtq: 103,
        dprop_seg: 1,
        dphase_seg1: 1,
        dphase_seg2: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Phase Segment 2: \"error\", only integers between 1 <= dphase_seg2 <= 8 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    bad_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 1_000_000,
        dsample_point: 0.103,
        dtq: 103,
        dprop_seg: 1,
        dphase_seg1: 1,
        dphase_seg2: 1,
        dsjw: "error"
      }
    }

    assert_raise(
      ArgumentError,
      "Invalid Synchronization Jump Width: \"error\", only integers between 1 <= dsjw <= 4 are allowed",
      fn -> CanConfig.normalize(bad_config) end
    )

    good_config = %{
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 1_000_000,
        dsample_point: 0.103,
        dtq: 103,
        dprop_seg: 1,
        dphase_seg1: 1,
        dphase_seg2: 1,
        dsjw: 1
      }
    }

    assert CanConfig.normalize(good_config) == good_config
  end

  test "SocketCAN validation" do
    bad_config = %{socket: %{port: 4048, can_interfaces: ["can1"], linked_interface: "wlan0"}}
    assert_raise(ArgumentError, "There is at least a CAN Interface unavailable: [\"can1\"]", fn -> SocketCanConfig.normalize(bad_config) end)

    bad_config = %{socket: %{port: -4048, can_interfaces: ["can0"], linked_interface: "wlan0"}}
    assert_raise(ArgumentError, "Invalid Port: #{inspect(bad_config.socket)}, only positive integers are allowed.", fn -> SocketCanConfig.normalize(bad_config) end)

    bad_config = %{socket: %{port: 4048, can_interfaces: ["can0"], linked_interface: "wlan1"}}
    assert_raise(ArgumentError, "The linked interface is not available: \"wlan1\"", fn -> SocketCanConfig.normalize(bad_config) end)

    bad_config = %{socket: %{port: 4048, can_interfaces: ["can0"], linked_interface: "wlan0", no_beacon: 1}}
    assert_raise(ArgumentError, "Invalid no_beacon: 1, only booleans are allowed", fn -> SocketCanConfig.normalize(bad_config) end)

    good_config = %{socket: %{port: 4048, can_interfaces: ["can0"], linked_interface: "wlan0", no_beacon: true}}
    assert SocketCanConfig.normalize(good_config) == good_config
  end

  test "Create a CAN configuration" do
    can_config = %{can: %{bitrate: 500000}, type: CAN}

    output = %RawConfig{
      ifname: "can0",
      type: CAN,
      source_config: can_config,
      required_ifnames: ["can0"],
      child_specs: [],
      down_cmds: [{:run, "ip", ["link", "set", "can0", "down"]}],
      up_cmds: [{:run, "ip", ["link", "set", "can0", "up", "type", "can", "bitrate", "500000"]}]
    }

    assert output == CAN.to_raw_config("can0", can_config, Utils.default_opts())
  end

  test "Create a complete CAN configuration" do
    can_config =  %{
      type: CAN,
      can: %{
        bitrate: 1_000_000,
        sample_point: 0.103,
        tq: 103,
        prop_seg: 1,
        phase_seg1: 1,
        phase_seg2: 2,
        sjw: 4,
        berr_reporting: "on",
        listen_only: "on",
        loopback: "on",
        triple_sampling: "off",
        one_shot: "on",
        fd: "on",
        dbitrate: 1_000_000,
        dsample_point: 0.103,
        dtq: 103,
        dprop_seg: 1,
        dphase_seg1: 1,
        dphase_seg2: 1,
        dsjw: 1
      }
    }

    desired_can_params = [
      "link",
      "set",
      "can0",
      "up",
      "type",
      "can",
      "berr-reporting",
      "on",
      "bitrate",
      "1000000",
      "dbitrate",
      "1000000",
      "dphase-seg1",
      "1",
      "dphase-seg2",
      "1",
      "dprop-seg",
      "1",
      "dsample-point",
      "0.103",
      "dsjw",
      "1",
      "dtq",
      "103",
      "fd",
      "on",
      "listen-only",
      "on",
      "loopback",
      "on",
      "one-shot",
      "on",
      "phase-seg1",
      "1",
      "phase-seg2",
      "2",
      "prop-seg",
      "1",
      "sample-point",
      "0.103",
      "sjw",
      "4",
      "tq",
      "103",
      "triple-sampling",
      "off"
    ]


    output = %RawConfig{
      ifname: "can0",
      type: CAN,
      source_config: can_config,
      required_ifnames: ["can0"],
      child_specs: [],
      down_cmds: [{:run, "ip", ["link", "set", "can0", "down"]}],
      up_cmds: [{:run, "ip", desired_can_params}]
    }

    assert output == CAN.to_raw_config("can0", can_config, Utils.default_opts())
  end

  test "Create a CAN & SocketCAN configuration" do
    can_config = %{can: %{bitrate: 500000}, socket: %{port: 4048, can_interfaces: ["can0"], linked_interface: "wlan0"}, type: CAN}

    output = %RawConfig{
      ifname: "can0",
      type: CAN,
      source_config: can_config,
      required_ifnames: ["can0"],
      child_specs: [Utils.socket_can_child_spec("can0", "wlan0", 4048)],
      down_cmds: [{:run, "ip", ["link", "set", "can0", "down"]}],
      up_cmds: [{:run, "ip", ["link", "set", "can0", "up", "type", "can", "bitrate", "500000"]}]
    }

    assert output == CAN.to_raw_config("can0", can_config, Utils.default_opts())
  end
end
