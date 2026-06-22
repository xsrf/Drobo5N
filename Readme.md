# Drobo 5N Reverse-Engineering
My Drobo 5N (Unit 1) died on me in May 2026. Here are some random notes and resources I gathered, trying to find out what happened.
It looks like one of the three 2 channel SATA Controllers died (more on that later).
I also bought another Drobo 5N (Unit 2) from eBay, to check some of my assumptions.

My assumption was later confirmed. One SATA controller had a bad 1V voltage rail due to a burnt out transistor. Simply replacing that transistor (Q2) fixed the issue.

## Directory Contents

| Directory | Description |
|---|---|
| [3D](3D/) | OpenSCAD and 3D-print files (PCB carriers to help working on the PCB on the desk) |
| [Disassembly](Disassembly/) | Disassembly instructions including images |
| [Datasheets](Datasheets/) | Component datasheets and reference material |
| [gfx](gfx/) | Images used in this repo (figures and photos) |
| [MSP430](MSP430/) | Tools for MSP430 and flash dumps of both units |
| [Unit1](Unit1/) | Unit 1: crashlogs, bootlogs, traces (PulseView), and USB-DOM files/image |
| [Unit2](Unit2/) | Unit 2: crashlogs, bootlogs, traces (PulseView), USB-DOM files |
| [USB-DOM](USB-DOM/) | Disk-on-module images and vxWorks files |


## Crashlog Recovery

### USB DOM (Disk on Module)
The Drobo 5N comes with a 1GB FAT16 formatted internal USB drive. It uses a module which is connected using a 2mm pitch internal USB connector (like the ones on a regular PC motherboard, but smaller). You can make yourself an adapter with 2mm pitch Header-Pins.

<img src="gfx/USB-DOM-RM2.0-Adapter.jpg" width="480" />

The module holds Crashlogs (basically the whole output of the Drobis internal VxWorks system) which hold valuable information for debugging.

### Crashlogs (Unit 1)
The [crashlogs](Unit1/USB-DOM/UBSW/Crashlogs) I recovered from my unit have a time offset of about ~9h to MESZ. 2026-05-03 03:19 MESZ ~= 2026-05-02 18:19 in log.  
- [crashlog-20260504-1210](Unit1/USB-DOM/UBSW/Crashlogs/crashlog-20260504-1210) shows drobo crashing
- [crashlog-20260504-1211](Unit1/USB-DOM/UBSW/Crashlogs/crashlog-20260504-1211) shows the reason on next bootup: *diskInterfaceInitialise: Adapter 1 Init Failed*

### Timeline (Unit 1)
Together with my local monitoring and my own observations, the crashlogs allow me to reconstruct what happened:
- 2026-05-01 19:34 MESZ Disk 3 dropped out?!?! (Most recent timestamp via UFS Explorer recovery of Disk 3)
- 2026-05-03 03:19 MESZ (+-5min) Drobos httpd went offline (Timestamp via Monitoring)
- 2026-05-04 20:49 MESZ Me noticing Drobo being off with top slot green, 2nd slot red; No sign in Dashboard
- 2026-05-04 20:.. Tried to power off via Switch. Got untill all lights went dark but drive and fan didn't power down even after ~15 minutes; Removed Power-Plug
- 2026-05-04 20:.. Plugged back in, booted, all lights yellow, after few min top red, rest off; Dashboard sees Drobo and says no drives; Drives did not spin up!
- Powered on again without drives then inserted one totally different drive - did not spin up!

## Other components

### Battery
The Battery is a 3.6V 2150mAh Li-Ion 18650 (Panasonic CGR 18650 CH). Model "Bumblebee b".
I measured:
- 4.12V between Red and Black under slight load (Multimeter Low-Z)
- 10k between Green and Black
Looks perfectly fine

### Power-Switch
| Wire | Function |
| --- | --- |
| Blue | Switched to white -> pulls up MSP430 P1.1 |
| White | 3V supply; LED anode |
| Red | LED kathode -> pulled down by MSP430 P4.6 via Q87 |

### Power-Switch LED
During debugging I've observed many flashing patterns
| Signal | Meaning |
| --- | --- |
| on continously | System on; normal operation |
| off continously | System off/stand-by |
| 3x 790ms, 4x 160ms, repeating | Performing Shutdown |
| on 256ms, off 256ms, repeating | System on; PMU (v78) in failsafe mode! |
| extremely faint short flash every ~500ms | PMU (v78) reset-loop |
| one 330ms flash (and short fan twitch) | PMU (v78) enters Failsafe Stand-By after power connect / reset |
| one 300ms, 3x 80ms, 3x 160ms, 3x 80ms, 2x 160ms (and short fan spinup) | PMU (v7a) enters regular Stand-By after power connect / reset |



### PMU - MSP430F2252
The PMU (Power Management Unit) of the Drobo is a MSP430F2252. It's responsible for handling the Power-Switch, Power-Switch LED, Power-On/Stand-By behaviour and brings up additional power-rails for the SoC, other controllers and Fan.

When the PMU is held in reset, the FAN and Power Switch LED are turned on!

#### J11 - MSP430F2252 programming header

J11 (not populated 0.1" header) exposes the programming / debugging pins of the MSP430.

| Pin | Function    |
| --- | ----------- |
|   1 | 3V (marked) |
|   2 | TEST        |
|   3 | RST         |
|   4 | GND         |

Jumper J13 must be removed in order to debug/reset/flash the MSP during operation.
While flashing, FAN might tun on.
Didn't try supplying 3V through J11.

#### Flash/Memory Layout
| Range | Name | Info |
| --- | --- | --- |
| 0x0C00 - 0x0FFF | Boot | 1kb; Identical on Unit1/Unit2; probably stock TI |
| 0x1000 - 0x10FF | Info | 256b; INFOD to INFOA |
| 0xC000 - 0xFFFF | Main/Code | 16kb |

Remove J13 to read/write to MSP430 while drobo is powered (plugged in is enough).

#### Info Segments
| Range | Name | Info |
| --- | --- | --- |
| 0x1000 - 0x103F | Info D | PMU version; static values; programmed with PMU update |
| 0x1040 - 0x107F | Info C | PMU runtime information; updated on every reset and power-up |
| 0x1080 - 0x10BF | Info B | static informatiion?! |
| 0x10C0 - 0x10FF | Info A | FF + Chip calibration values at end; write protected |

Only Info D is written when a PMU update is performed by the VxWorks system. 

#### Info C
0x105B (unit8) (probably 0x105A uint16) looks like it contains a counter that increments with every boot-up of the system

0x1065 (unit8) (probably 0x1064 uint16) contains a counter that's incremented whenever the PMU starts

#### UART to SoC
The PMU has a 38400 baud UART connection to the main SoC via Pins UCA0RXD/UCA0TXD. It communicates via 0x00 terminated ASCII strings.
Communication can be observed in [powerup_01_safemode_pmu_update.sr](Unit1/Trial-20260621-01/powerup_01_safemode_pmu_update.sr).
Whenever the PMU parses a command from the SoC, the power switch LED goes off (which is to fast to notice in real life).


### PMU Failure Modes

#### Cleared INFO Segments
https://www.youtube.com/live/jLmZw1f3uVw?t=13111

#### Power Switch LED blinking rapidly and extremely faint (look closely in dark!) after plugging in
Probably caused by PMU constantly resetting and initial High-Z output of the PMU turns on the LED for just a few ms.
Probably due to corrupt INFO segment in flash.
https://www.youtube.com/live/jLmZw1f3uVw?t=10425

#### Power Switch LED constantly blinking fast (~500ms 50% duty cicle) after plugging-in
FAN pulsing with LED. No reaction to power switch.
Probably caused by corrupt INFO segment. PMU probably boot-looping.

#### Power Switch LED constantly blinking fast (~500ms 50% duty cicle) after power on
PMU in FailSafe mode; FAN at full speed

### Serial

#### J3 (2.54 Header, populated, Linux)
- 1: 3V3 (marked)
- 2: RX (send to drobo)
- 3: TX @ 3V3 (drobo sends to you)
- 4: GND

#### J2 (2.54 Header, unpopulated, VxWorks)
- 1: 3V3 (marked)
- 2: RX (send to drobo)
- 3: TX @ 3V3 (drobo sends to you)
- 4: GND

## Backplane - I2C IO Expanders (TCA9555)

### U13 - LEDs (Addr: 0x20)
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

### U15 - Disks (Addr: 0x23)
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

### Disk sensing
Pin 6 of the SATA Connector (GND) is connected through 5K (R1/2/7/8/20) to an input on U15 Port 1.
The Input is pulled-down to GND via 100K.

> [!WARNING]  
> No clue how this should work. The input would always be pulled down?! However, I2C later reads all HIGH when no disk is connected

### I2C

GPIO Extenders U13 and U15 are controlled via I2C commands:

#### Drobo PowerOff
Measured on faulty Unit 1:
```
W 23 02 00 -> Output Port 0 (P00-P07) ALL OFF
```
#### Drobo PowerUp
Measured on faulty Unit 1 with no disk in place:
```
W 23 07 FF      P1 CNF ALL IN
R 23 01 :: FF   P1 GET ALL HIGH (diskPresence -> no disk present)

W 23 02 00      P0 SET ALL LOW
W 23 06 00      P0 CNF ALL OUT
W 23 03 00      P1 SET ALL LOW
W 23 07 1F      P1 CNF 0001 1111 (diskPresence IN)
```

Mesured on working Unit 1 with disk in slot 0:
```
W 23 07 FF      P1 CNF ALL IN
R 23 01 :: F7   P1 GET 11110111 (diskPresence -> Disk in Slot 0)

W 23 06 00      P0 CNF ALL OUT
W 23 02 00      P0 SET ALL LOW
W 23 07 1F      P1 CNF 0001 1111 (diskPresence IN)
W 23 03 00      P1 SET ALL LOW

R 23 01 :: 17   P1 GET 0001 0111 (diskPresence -> Disk in Slot 0)
R 23 01 :: 17   P1 GET 0001 0111 (diskPresence -> Disk in Slot 0)
R 23 01 :: 17   P1 GET 0001 0111 (diskPresence -> Disk in Slot 0)
R 23 01 :: 17   P1 GET 0001 0111 (diskPresence -> Disk in Slot 0)
R 23 01 :: 17   P1 GET 0001 0111 (diskPresence -> Disk in Slot 0)
R 23 00 :: 00   P0 GET 0000 0000 (Disk power is all off)
R 23 00 :: 00   P0 GET 0000 0000 (Disk power is all off)
R 23 00 :: 00   P0 GET 0000 0000 (Disk power is all off)
R 23 00 :: 00   P0 GET 0000 0000 (Disk power is all off)
R 23 00 :: 00   P0 GET 0000 0000 (Disk power is all off)
R 23 00 :: 00   P0 GET 0000 0000 (Disk power is all off)
W 23 02 08      P0 SET 0000 1000 (Power Slot 0)
R 23 00 :: 08   P0 GET 0000 1000 (Power is on for Slot 0)
W 23 02 08      P0 SET 0000 1000 (Power Slot 0)
R 23 00 :: 08   P0 GET 0000 1000 (Power is on for Slot 0)
W 23 02 08      P0 SET 0000 1000 (Power Slot 0)
R 23 00 :: 08   P0 GET 0000 1000 (Power is on for Slot 0)
W 23 02 08      P0 SET 0000 1000 (Power Slot 0)
R 23 00 :: 08   P0 GET 0000 1000 (Power is on for Slot 0)
W 23 02 08      P0 SET 0000 1000 (Power Slot 0)
R 23 01 :: 17   P1 GET 0001 0111 (diskPresence -> Disk in Slot 0)
R 23 01 :: 17   P1 GET 0001 0111 (diskPresence -> Disk in Slot 0)
R 23 01 :: 17
R 23 01 :: 17
R 23 01 :: 17
R 23 01 :: 17
...
```