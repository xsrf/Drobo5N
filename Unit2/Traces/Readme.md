# Traces

Traces of both UARTs and I2C recorded using PulseView @ 1MHz. Open with [Sigrok PulseView](https://sigrok.org/wiki/PulseView).

| Trace | Description |
|---|---|
| power_on_1 | First power-on after disassembly with one new drive in slot 0 (top); timestamp is wrong as battery was disconnected; Drobo is creating a new DiskPack on this drive |
| power_on_2 | 2nd boot with the previously installed drive still in slot 0. |
| poweroff_fail | after running for longer I powered off, but the disk and Fan stayed on. The disk was doing something when I powered off. It has known bad sectors, maybe internal housekeeping. Not sure if that prevented proper shutdown.
