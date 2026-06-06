# Drobo 5N (Unit 1)
My own unit. One broken SATA Controller. Will power up and show on the network, but won't spin up any drives.

Software-Version: 4.2.1

## Troubleshooting

Suring boot, the VxWorks software shows:
```
  Dumping Disk Adapter Table
    Adapter Instance   Adapter Address   Adapter Data Address
           0            0x014B4298            0x04339C70
           1            0x014B4298            0x00000000
           2            0x014B42A8            0x0431B5D0

   Dumping Disk Slot Config Table:
    Adapter Instance   Connection    Physical Slot   Adapter Channel    Initialised    Device Pointer
        2                DRIVE             0              0                Yes           0x04304218
        1                DRIVE             1              0                 No           0x04304ABC
        1                DRIVE             2              1                 No           0x04305B70
        0                DRIVE             3              0                 No           0x04306414
        0                DRIVE             4              1                 No           0x04306CB8
        2                DRIVE             5              1                 No           0x0430755C
diskInterfaceInitialise: Adapter 1 Init Failed.
showDiskTbs: Dumping Disk Driver Config Tables:

  Dumping Disk Adapter Table
    Adapter Instance   Adapter Address   Adapter Data Address
           0            0x014B4298            0x04339C70
           1            0x014B4298            0x00000000
           2            0x014B42A8            0x0431B5D0

   Dumping Disk Slot Config Table:
    Adapter Instance   Connection    Physical Slot   Adapter Channel    Initialised    Device Pointer
        2                DRIVE             0              0                Yes           0x04304218
        1                DRIVE             1              0                 No           0x04304ABC
        1                DRIVE             2              1                 No           0x04305B70
        0                DRIVE             3              0                 No           0x04306414
        0                DRIVE             4              1                 No           0x04306CB8
        2                DRIVE             5              1                 No           0x0430755C
diskInterfaceInitialise: Completed Disk Driver Initialisation: FAILED
diskInterfacePostInit: Disk Controller Failed to initialise: Forcing system shutdown...
```

This indicates that something is wrong with SATA Adapter 1, which handles Slots 1 and 2. This matches the crashlog, which showed that my Drive in Slot 2 suddenly disappieared.

I've traced the SATA traces from the slots 2 and 3 to U21, Marvel 88SE9120 (with 4M Flash U22).

<img src="../gfx/Drobo5N_88SE9120_SATA_U21_U22.jpg" width="320">

A thermal image shows that U21 is ~10°C colder than the working SATA controller U19.

<img src="../gfx/Thermal_U21_U22.jpg" width="320">

Comparing signals on the Flash of the working and dead 88SE9120, shows that U21 is not talking to U22, while U19 indeed talks to U20.

<img src="../gfx/PulseView_U20_U22_CS.png">

I cannot find a full Datasheet of the 88SE9120, but I found this pinout:

<img src="../Datasheets/88SE9120_pinout.jpg">

As well as a short [datasheet for the 88SE9125](../Datasheets/88se9125-datasheet-668097cf16614605971775.pdf) which has the same PIN layout.

Both crystals are oscillating.

All Capacitors surrounding U21 on the top measure identical voltages to those around U19, so I guess these voltage rails are fine. The datasheet however mentions VCONT_10 (1.0V) which I cannot find.

Found VCONT_10 and its PNPs on the bottom side of the PCB. VCONT_10 of U21/Q2 is only 0.5V!

<img src="../gfx/U21_VCONT_10.jpg">
<img src="../gfx/Thermal_Q1_Q2.jpg" width="320">

Q1 for VCONT_10 for U19 (1.0V):  
<img src="../gfx/Thermal_Q1.jpg" width="320">

Q2 for VCONT_10 for U21 (0.5V):  
<img src="../gfx/Thermal_Q2.jpg" width="320">

