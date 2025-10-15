(*
    PLC_PRG - Tank Level Control with PID & Alarms
*)
PROGRAM PLC_PRG
VAR
    // --- Enable & modes ---
    Enable          : BOOL := TRUE;
    ManualMode      : BOOL := FALSE;
    AckReset        : BOOL := FALSE;

    // --- Setpoints & params ---
    LevelSP         : REAL := 60.0;   // %
    Kp              : REAL := 1.5;
    Ki              : REAL := 0.2;    // 1/s
    Kd              : REAL := 0.0;
    Ts              : REAL := 0.1;    // s (scan time assumption for simulation)

    // --- Outputs ---
    ValveOut        : REAL := 0.0;    // 0..100 %
    ManValveOut     : REAL := 0.0;    // manual 0..100 %

    // --- Process values ---
    Level           : REAL := 10.0;   // %
    Inflow          : REAL := 0.0;    // %/s equivalent
    Outflow         : REAL := 0.0;    // %/s equivalent
    Disturbance     : REAL := 0.0;    // %/s equivalent

    // --- Plant constants ---
    K_in            : REAL := 0.5;    // inflow gain
    K_out           : REAL := 0.05;   // outflow gain

    // --- Alarms ---
    ALM_HiHi        : BOOL := FALSE;  // >= 90%
    ALM_Hi          : BOOL := FALSE;  // >= 80%
    ALM_Lo          : BOOL := FALSE;  // <= 20%
    ALM_LoLo        : BOOL := FALSE;  // <= 10%

    LATCH_HiHi      : BOOL := FALSE;
    LATCH_Hi        : BOOL := FALSE;
    LATCH_Lo        : BOOL := FALSE;
    LATCH_LoLo      : BOOL := FALSE;

    AnyAlarm        : BOOL := FALSE;
    AlarmCount      : INT := 0;

    // --- Helpers ---
    rAck            : BOOL := FALSE;

    // --- PID block ---
    PID             : FB_PID;
    pidOut          : REAL := 0.0;

    // --- Misc ---
    firstScan       : BOOL := TRUE;
END_VAR

// Rising edge detect on Acknowledge/Reset
rAck := UTIL_RTrig(In := AckReset);

// --- PID compute (or manual) ---
IF ManualMode THEN
    pidOut := ManValveOut;
ELSE
    PID(
        Enable  := Enable,
        Kp      := Kp,
        Ki      := Ki,
        Kd      := Kd,
        Setpoint:= LevelSP,
        PV      := Level,
        OutMin  := 0.0,
        OutMax  := 100.0,
        Ts      := Ts,
        Out     => pidOut
    );
END_IF;

ValveOut := pidOut;

// --- Process simulation ---
Inflow  := K_in  * ValveOut;   // proportional to valve position
Outflow := K_out * Level;      // proportional to level (drain)

// Optional disturbance step: simulate a leak or inflow bump
IF firstScan THEN
    Disturbance := 0.0;
    firstScan := FALSE;
END_IF;

// Euler update
Level := Level + Ts * (Inflow - Outflow + Disturbance);

// Clamp bounds
IF Level > 100.0 THEN Level := 100.0; END_IF;
IF Level < 0.0 THEN Level := 0.0; END_IF;

// --- Alarm evaluation ---
ALM_HiHi := (Level >= 90.0);
ALM_Hi   := (Level >= 80.0);
ALM_Lo   := (Level <= 20.0);
ALM_LoLo := (Level <= 10.0);

// Latching logic: set when active, reset on rAck and condition cleared
IF ALM_HiHi THEN LATCH_HiHi := TRUE; END_IF;
IF ALM_Hi   THEN LATCH_Hi   := TRUE; END_IF;
IF ALM_Lo   THEN LATCH_Lo   := TRUE; END_IF;
IF ALM_LoLo THEN LATCH_LoLo := TRUE; END_IF;

// Reset on acknowledge when the condition is no longer present
IF rAck AND (NOT ALM_HiHi) THEN LATCH_HiHi := FALSE; END_IF;
IF rAck AND (NOT ALM_Hi)   THEN LATCH_Hi   := FALSE; END_IF;
IF rAck AND (NOT ALM_Lo)   THEN LATCH_Lo   := FALSE; END_IF;
IF rAck AND (NOT ALM_LoLo) THEN LATCH_LoLo := FALSE; END_IF;

// Summary & count
AnyAlarm := LATCH_HiHi OR LATCH_Hi OR LATCH_Lo OR LATCH_LoLo;

AlarmCount := 0;
IF LATCH_HiHi THEN AlarmCount := AlarmCount + 1; END_IF;
IF LATCH_Hi   THEN AlarmCount := AlarmCount + 1; END_IF;
IF LATCH_Lo   THEN AlarmCount := AlarmCount + 1; END_IF;
IF LATCH_LoLo THEN AlarmCount := AlarmCount + 1; END_IF;

END_PROGRAM
