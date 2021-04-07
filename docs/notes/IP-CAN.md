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
* socketcand
* can-utils

## Config files

N/A

## Tested

No
