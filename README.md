# Tank Level Control with PID and Alarms (Structured Text)

A small learning project in Structured Text. I wanted to understand PID
control and alarm handling on a PLC, so I wrote a simulated water tank
and a controller for it.

## What it does

- PID control of an inlet valve to hold a level setpoint
- A first-order tank model (inflow from the valve, gravity outflow),
  simulated in the scan cycle so it runs without hardware
- High and low alarms that latch until acknowledged
- Manual mode to bypass the PID and drive the valve directly

## Files

- `src/PLC_PRG.st` — main program: tank simulation, alarms, tags
- `src/FB_PID.st` — PID function block
- `src/UTIL_RTrig.st` — rising-edge helper

## Notes

The integral term uses conditional integration: when the output hits its
limit, the last integral increment is undone so the term cannot wind up
while the valve is saturated.

Written for CODESYS Control Win V3. Create a Program POU for `PLC_PRG`,
a Function Block for `FB_PID`, and a Function for `UTIL_RTrig`, paste the
code in, and assign `PLC_PRG` to MainTask.
