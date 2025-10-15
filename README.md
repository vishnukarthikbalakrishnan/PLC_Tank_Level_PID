# Tank Level Control with PID & Alarms (Structured Text)

A PLC project in **Structured Text (ST)** simulating a water tank with:
- PID control of inlet valve to maintain level
- High/Low alarms with **latching** and **acknowledge/reset**
- Simple first-order tank process simulation (runs in scan cycle)
- Clean tags for easy HMI mapping (CODESYS, Factory I/O, or any simulator)

> Ready for GitHub: includes commented ST code, clear variables, and setup steps.

---

## Files
```
/src/PLC_PRG.st       - Main program containing tank simulation, alarms, HMI tags
/src/FB_PID.st        - Simple PID controller function block (with anti-windup)
/src/UTIL_RTrig.st    - Rising-edge trigger helper
resume_bullets.md     - Copy-paste ready bullets for your CV
LICENSE               - MIT
```

## How it works

- **Simulation model (inside `PLC_PRG`)**
  - `Level` (%): 0–100. Represents tank fill level.
  - `ValveOut` (0–100%): controlled by PID to reach `LevelSP`.
  - Inflow = `K_in * ValveOut`  
  - Outflow = `K_out * Level` (gravity drain)
  - `Level` is updated each cycle: `Level := Level + dt * (Inflow - Outflow + Disturbance);`
  - Hard clamps at 0–100%.

- **PID (in `FB_PID`)**
  - Parameters: `Kp`, `Ki`, `Kd`, `OutMin`, `OutMax`.
  - Internal `dt` from cycle time (configurable via `Ts`).
  - Anti-windup by clamping integral at output limits.

- **Alarms**
  - `ALM_HiHi` (>= 90%), `ALM_Hi` (>= 80%), `ALM_Lo` (<= 20%), `ALM_LoLo` (<= 10%)
  - **Latched** until `AckReset` is pulsed and condition clears.
  - `AnyAlarm` summary and `AlarmCount`.

- **HMI-friendly tags**
  - Setpoints/params: `LevelSP`, `Kp`, `Ki`, `Kd`
  - Control: `Enable`, `ManualMode`, `ManValveOut`, `AckReset`
  - Status: `Level`, `ValveOut`, `Inflow`, `Outflow`, `AnyAlarm`, `AlarmCount`

---

## Quick Start (CODESYS)

1. Create a new CODESYS project (e.g., Standard project → CODESYS Control Win V3).
2. Add a POU named **`PLC_PRG`** of type **Program** in **Structured Text**.
3. Paste the contents from `src/FB_PID.st`, `src/UTIL_RTrig.st`, and `src/PLC_PRG.st` into corresponding POUs:
   - Add **Function Block** `FB_PID` and paste code.
   - Add **Function** `UTIL_RTrig` (BOOL input → BOOL output) and paste code.
   - Paste `PLC_PRG` into the Program POU.
4. Declare `PLC_PRG` as the task’s program (MainTask → PLC_PRG).
5. Download to runtime and start.
6. Change `LevelSP` (e.g., 60.0) and observe `ValveOut`, `Level`, and alarms.
7. Toggle `ManualMode` to test manual valve control via `ManValveOut`.
8. Trigger and **acknowledge** alarms using `AckReset`.

> Optional: Bind tags to an HMI/SCADA and plot `Level` and `ValveOut`.

---

## Key Variables

| Name         | Type  | Description |
|--------------|-------|-------------|
| `Enable`     | BOOL  | Master enable |
| `LevelSP`    | REAL  | Level setpoint (%) |
| `Level`      | REAL  | Process variable (%) |
| `ValveOut`   | REAL  | PID output, 0–100% |
| `ManualMode` | BOOL  | If TRUE, PID is bypassed and `ManValveOut` is used |
| `ManValveOut`| REAL  | Manual valve position (%) |
| `AckReset`   | BOOL  | Rising-edge pulse to reset latched alarms |
| `AnyAlarm`   | BOOL  | Summary alarm |
| `AlarmCount` | INT   | Number of active latched alarms |

---

## Resume Bullets

See `resume_bullets.md` for copy-ready bullets. Example:

- Built a **PID-controlled tank level** system in Structured Text (CODESYS), implementing anti-windup, manual override, and simulated process dynamics for offline testing.
- Engineered **latched alarm logic** (HiHi/Hi/Lo/LoLo) with acknowledge/reset and summary reporting to support HMI/SCADA integration.

---

## License
MIT
