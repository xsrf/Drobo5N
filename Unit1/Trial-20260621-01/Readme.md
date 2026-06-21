# Trial 2026-06-21 - 01

I've had the PMU starting in failsafe mode many times after flashing MAIN and INFO from the working unit to this one.
Every time the System booted, the VxWorks system has senn the PMU in failsafe mode and reflashed the PMU.
When reflash finished, the PMU turned the system off and the continously flashed LED+FAN in ~500ms interval. Pressing the button did nothing.
Removing power and replugging ended up in the same state.

My plan was to record traces of the PMU communication while this happened.

So I hooked up my probes not only to the Linux and VxWorks UART but also to the PMU UART and Power Switch LED.

I then dumped the flash (fw_msp_2026-06-21_19-39-40) of the MSP once again, which leaves the PMU in reset, causing FAN and LED permanently on. To reset the PMU, I ran mspdebug and exited it, which lets the PMU run again.

It did, with a confirming ~200ms Blink of the LED and FAN, as usual.

I then hit record in PulseView (powerup_01) and powered the System on.

As usual, it started in Failsafe and VxWorks flashed the PMU. But to my surprise - after PMU flashing, the LED did a blinky dance and the System powered off completely. To the first time ever it looked like the PMU update worked?!

I dumped the Flash again (fw_msp_2026-06-21_20-01-51) and reset the MSP using mspdebug.

It again did a short funky blinky thing on the Power switch which I didn't capture.

Then I recorded again (powerup_02) in PulseView and immediately saw that the PMU was not in failsafe anymore!

I let it run for a while and then powered off. It looks like it was running just fine.

I dumped the flash once again (fw_msp_2026-06-21_20-33-56)

This time I aso captured the Power Switch LED Blinking after `exit` in `mspdebug`.

I powered up once again and captured it, powered off again.

Then I plugged in the Battery, LAN and a Disk in Slot 0.

Captured and Powered Up!

Interesting fact, the PMU now reports as `PMU Version: 1.0.0x007a, Download Version 122 (Variant 0) [Failsafe Ver 3]`. Before all this, when the PMU was fine and the SATA controller was the issue, it reported as `PMU Version: 1.0.0x0078, Download Version 120 (Variant 0) [Failsafe Ver 3]` and VxWorks was fine. Maybe Firmware 4.2.1 accepts both as valid but shipps with `1.0.0x007a`?

No clue why it now finally fixed itself!

## Timeline
- fw_msp_2026-06-21_19-39-40
- powerup_01
- fw_msp_2026-06-21_20-01-51
- powerup_02
- fw_msp_2026-06-21_20-33-56
- pws_led_blink_after_mspdebug_exit
- powerup_03
- powerup_04 (with hdd)
- fw_msp_2026-06-21_21-32-37

## File-Hashes
```
fw_msp_2026-06-21_19-39-40_all.hex             f37e4395118e87baa999cb87a1dc1588
fw_msp_2026-06-21_19-39-40_bsl.bin             1597be47dfb3ff5691237c399af98363
fw_msp_2026-06-21_19-39-40_bsl.hex             494ea8995a5e5cf3dc2c4cd97f1b0822
fw_msp_2026-06-21_19-39-40_info.bin            4fadb5c3f8ebcc03420263dad8efb7e6
fw_msp_2026-06-21_19-39-40_info.hex            b03e8c64e0cd2e6b76ec0c4ca9ef0887
fw_msp_2026-06-21_19-39-40_main.bin            891151b5a212570fb0ae076e054da34e
fw_msp_2026-06-21_19-39-40_main.hex            837404044c66fa5d39c0c882d7aaa984
fw_msp_2026-06-21_20-01-51_all.hex             9bca0fa6755b7072e911425d5b85ebdc
fw_msp_2026-06-21_20-01-51_bsl.bin             1597be47dfb3ff5691237c399af98363
fw_msp_2026-06-21_20-01-51_bsl.hex             494ea8995a5e5cf3dc2c4cd97f1b0822
fw_msp_2026-06-21_20-01-51_info.bin            df1396b0ca8081cc6bdab26871d9c7c6
fw_msp_2026-06-21_20-01-51_info.hex            8ee6b8d8bda03b83dbb831cee497a290
fw_msp_2026-06-21_20-01-51_main.bin            9e494d79aed6a20fe877c2cab423a509
fw_msp_2026-06-21_20-01-51_main.hex            4913f3cb7d4d6b50f1903d3595f6d7fa
fw_msp_2026-06-21_20-33-56_all.hex             8821c6a4191679b5179bce775eeacf11
fw_msp_2026-06-21_20-33-56_bsl.bin             1597be47dfb3ff5691237c399af98363
fw_msp_2026-06-21_20-33-56_bsl.hex             494ea8995a5e5cf3dc2c4cd97f1b0822
fw_msp_2026-06-21_20-33-56_info.bin            4eede758837c5fd29221d0531341cc6b
fw_msp_2026-06-21_20-33-56_info.hex            c60e63d910ffd1d15e16e4294490f458
fw_msp_2026-06-21_20-33-56_main.bin            9e494d79aed6a20fe877c2cab423a509
fw_msp_2026-06-21_20-33-56_main.hex            4913f3cb7d4d6b50f1903d3595f6d7fa
fw_msp_2026-06-21_21-32-37_all.hex             373f1b379c50739d7566657384df8c7b
fw_msp_2026-06-21_21-32-37_bsl.bin             1597be47dfb3ff5691237c399af98363
fw_msp_2026-06-21_21-32-37_bsl.hex             494ea8995a5e5cf3dc2c4cd97f1b0822
fw_msp_2026-06-21_21-32-37_info.bin            e8cc2223758b5345f1cc710c277e43e3
fw_msp_2026-06-21_21-32-37_info.hex            1ac2cb4b297a566ff39554628db4be1f
fw_msp_2026-06-21_21-32-37_main.bin            9e494d79aed6a20fe877c2cab423a509
fw_msp_2026-06-21_21-32-37_main.hex            4913f3cb7d4d6b50f1903d3595f6d7fa
```