# Drobo 5N Reverse-Engineering
My Drobo 5N (Unit 1) died on me in May 2026. Here are some random notes and resources I gathered, trying to find out what ahppened.
It looks like one of the three 2 channel SATA Controllers died (more on that later).
I also bought another Drobo 5N (Unit 2) from eBay, to check some of my assumptions.

# Contents

| Directory | Description |
|---|---|
| [3D/](3D/) | OpenSCAD and 3D-print files (PCB carrier) |
| [Datasheets/](Datasheets/) | Component datasheets and reference material |
| [gfx/](gfx/) | Images used in this repo (figures and photos) |
| [Unit1/](Unit1/) | Unit 1: crashlogs, bootlogs, traces (PulseView), and USB-DOM files/image |
| [Unit2/](Unit2/) | Unit 2: crashlogs, USB-DOM files |
| [USB-DOM/](USB-DOM/) | Disk-on-module images and vxWorks files |

# USB DOM (Disk on Module)
The Drobo 5N comes with a 1GB FAT16 formatted internal USB drive. It uses a module which is connected using a 2mm pitch internal USB connector (like the ones on a regular PC motherboard, but smaller). You can make yourself an adapter with 2mm pitch Header-Pins.

<img src="gfx/USB-DOM-RM2.0-Adapter.jpg" width="480" />

# Timeline (Unit 1)
- 2026-05-01 19:34 MESZ Disk 3 dropped out?!?! (Timestamp via UFS Explorer recovery of Disk 3)
- 2026-05-03 03:19 MESZ (+-5min) Drobos httpd went offline (Timestamp via Monitoring)
- 2026-05-04 20:49 MESZ Noticed Drobo off with top slot green, 2nd slot red; No sign in Dashboard
- 2026-05-04 20:.. Tried to power off via Switch. Got untill all lights went dark but drive and fan didn't power down even after ~15 minutes; Removed Power-Plug
- 2026-05-04 20:.. Plugged back in, booted, all lights yellow, after few min top Red rest off; Dashboard sees Drobo and says no drives; Drives did not spin up!
- Powered on again without drives then inserted one totally different drive - did not spin up!

# Crashlogs (Unit 1)
- timestamp offset -9h; 2026-05-03 03:19 MESZ ~ 2026-05-02 18:19 in log
- crashlog-20260504-1210 shows drobo crashing

# Disassembly
Requires a PH2, a PH1 and a flat hat screwdriver
- Remove magnetic front cover
- Remove drives
- Unhook door from bottom opening
- Unscrew bottom feet (4x PH2)
- Lift the outer shell slightly at the half with the opening and slide the inner parts out to the back end (pay attention to the plastic catch)
- The front rubber seal around the drive cage might have got loose now, remove it
- Unclip the back plastic (2 clips on each side, one on the top)
- Unclip the front plastic (2 clips on each side, one on the top)
- Remove the top and bottom screw on each side (4x PH1)
- Press the top of the case backwards (against the sides) for ~3-5mm and then turn the case around on its top
- Try to pry the bottom part of the back (where the connector openings are) backwards. A flat hat screwdriver might help to lever against the chamfered edges
- Turn it back right way up
- Slide tha top/back all the way back until the back side is free - then lift it carefully ~10mm. Be aware of the Power switch and Fan cables inside!
- Carefully unplug the power switch from the right side, then unplug the Fan (can be done from the left side)
- Remove the top/back
- optionally: Use a flat hat screw driver or a dull pin to push out the plastic pegs, that hold the Fan, from the back side. Then unclip the Fan cable clips and remove the Fan
- optionally: Remove the Power switch by pushing it from the back while carefully compressing the flaps on the side with a flat hat screwdriver
- Unplug the battery
- Remove the remaining two screws on each side (4x PH1)
- Carefully lift the backplane assembly up
- Unscrew the backplane from its frame (8x PH2)
- Unscrew battery holder from its frame (2x PH2)
- Unscrew the main PCB and its shield (6x PH1)
- Carefully lift the PCB shield without bending its fingers on the side
- Remove the main PCB
- optionally: Unscrew the USB DOM (Disk on module) and lift it (1x PH1)

# Battery
The Battery is a 3.6V 2150mAh Li-Ion 18650 (Panasonic CGR 18650 CH). Model "Bumblebee b".
I measured:
- 4.12V between Red and Black under slight load (Multimeter Low-Z)
- 10k between Green and Black

# Power-Switch LED
- 3 Slow, 4 Fast: Performing Shutdown
- on: normal operation
- off: off/stand-by

# Serial

## J3 (2.54 Header, populated, Linux)
- 1: 3V3 (marked)
- 2: RX (send to drobo)
- 3: TX @ 3V3 (drobo sends to you)
- 4: GND

## J2 (2.54 Header, unpopulated, VxWorks)
- 1: 3V3 (marked)
- 2: RX (send to drobo)
- 3: TX @ 3V3 (drobo sends to you)
- 4: GND

# Backplane - I2C IO Expanders (TCA9555)

## U13 - LEDs (Addr: 0x20)
- A0: GND
- A1: GND
- A2: GND
- P00: SLOT3_greenLed
- P01: SLOT3_redLed
- P02: SLOT2_greenLed
- P03: SLOT2_redLed
- P04: SLOT1_greenLed
- P05: SLOT1_redLed
- P06: SLOT0_greenLed
- P07: SLOT0_redLed
- P10: SLOT4_greenLed
- P11: SLOT4_redLed
- P12: TP22
- P13: TP21
- P14: TP20
- P15: TP19
- P16: TP18
- P17: TP17

## U15 - Disks (Addr: 0x23)
- A0: Vcc
- A1: Vcc
- A2: GND
- P00: SLOT3_diskPower
- P01: SLOT2_diskPower
- P02: SLOT1_diskPower
- P03: SLOT0_diskPower
- P04: SLOT4_diskPower
- P05: TP26
- P06: TP27
- P07: TP28
- P10: SLOT3_diskPresence
- P11: SLOT2_diskPresence
- P12: SLOT1_diskPresence
- P13: SLOT0_diskPresence
- P14: SLOT4_diskPresence
- P15: TP2x
- P16: TP2x
- P17: TP2x

## Disk sensing
Pin 6 of the SATA Connector (GND) is connected through 5K (R1/2/7/8/20) to an input on U15 Port 1.
The Input is pulled-down to GND via 100K.

> [!WARNING]  
> No clue how this should work. The input would always be pulled down?! However, I2C later reads all HIGH when no disk is connected

# I2C

GPIO Extenders U13 and U15 are controlled via I2C commands:

## Drobo PowerOff
Mesured on faulty Unit 1:
```
W 23 02 00 -> Output Port 0 (P00-P07) ALL OFF
```
## Drobo PowerUp
Mesured on faulty Unit 1 with no disk in place:
```
W 23 07 FF      P1 CNF ALL IN
R 23 01 :: FF   P1 GET ALL HIGH (diskPresence -> no disk present)

W 23 02 00      P0 SET ALL LOW
W 23 06 00      P0 CNF ALL OUT
W 23 03 00      P1 SET ALL LOW
W 23 07 1F      P1 CNF 0001 1111 (diskPresence IN)
```