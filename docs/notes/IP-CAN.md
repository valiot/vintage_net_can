# CAN bus with SocketCAN Configuration

This is the typical CAN bus with 500 Kbps setup.

```bash
ip link set can0 up type can bitrate 500000 loopback on
```

This command will expose the CAN bus on the 28600 port attached 
to the loopback interface.

```bash
socketcand -v -i can0 -p 28600 -l lo -d -n
```

IP supports the following parameters:

```bash
Usage: ip link set DEVICE type can
      [ bitrate BITRATE [ sample-point SAMPLE-POINT] ] |
      [ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1
        phase-seg2 PHASE-SEG2 [ sjw SJW ] ]

      [ dbitrate BITRATE [ dsample-point SAMPLE-POINT] ] |
      [ dtq TQ dprop-seg PROP_SEG dphase-seg1 PHASE-SEG1
        dphase-seg2 PHASE-SEG2 [ dsjw SJW ] ]

      [ loopback { on | off } ]
      [ listen-only { on | off } ]
      [ triple-sampling { on | off } ]
      [ one-shot { on | off } ]
      [ berr-reporting { on | off } ]
      [ fd { on | off } ]

      [ restart-ms TIME-MS ]
      [ restart ]

      Where: BITRATE  := { 1..1000000 }
                SAMPLE-POINT  := { 0.000..0.999 }
                TQ            := { NUMBER }
                PROP-SEG      := { 1..8 }
                PHASE-SEG1    := { 1..8 }
                PHASE-SEG2    := { 1..8 }
                SJW           := { 1..4 }
                RESTART-MS    := { 0 | NUMBER }
```

## Required programs

* Busybox ip
* can-utils
* socketcand (optional)

## Config files

N/A

## Tested

```elixir
iex(1)>VintageNet.configure("can0", %{can: %{bitrate: 500000}, type: VintageNetCan})
:ok
19:31:09.455 [debug] VintageNet(can0): :configured -> internal configure (VintageNetCan)
:ok

19:31:09.455 [info]  Child VintageNet.Interface of Supervisor {VintageNet.Interface.Registry, {VintageNet.Interface.Supervisor, "can0"}} started
Pid: #PID<0.1608.0>
Start Call: VintageNet.Interface.start_link("can0")
Restart: :permanent
Shutdown: 5000
Type: :worker
                                 
19:31:09.484 [info]  IPv6: ADDRCONF(NETDEV_CHANGE): can0: link becomes ready

iex(2)> ifconfig
lo: flags=[:up, :loopback, :running]
    inet 127.0.0.1  netmask 255.0.0.0
    inet ::1  netmask ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    hwaddr 00:00:00:00:00:00

can0: flags=[:up, :running]

iex(3)> VintageNet.deconfigure("can0")                                               
:ok
iex(4)> ifconfig
lo: flags=[:up, :loopback, :running]
    inet 127.0.0.1  netmask 255.0.0.0
    inet ::1  netmask ffff:ffff:ffff:ffff:ffff:ffff:ffff:ffff
    hwaddr 00:00:00:00:00:00

can0: flags=[]
                                 
```
