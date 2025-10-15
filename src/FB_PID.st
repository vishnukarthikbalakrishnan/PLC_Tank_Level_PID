(*
    FB_PID - Simple PID with anti-windup (Structured Text)
    Author: You
*)
FUNCTION_BLOCK FB_PID
VAR_INPUT
    Enable      : BOOL := TRUE;
    Kp          : REAL := 1.0;
    Ki          : REAL := 0.0;   // per second
    Kd          : REAL := 0.0;   // per second
    Setpoint    : REAL := 0.0;
    PV          : REAL := 0.0;
    OutMin      : REAL := 0.0;
    OutMax      : REAL := 100.0;
    Ts          : REAL := 0.1;   // sample time (s)
END_VAR
VAR_OUTPUT
    Out         : REAL := 0.0;
END_VAR
VAR
    err         : REAL;
    prevErr     : REAL;
    integ       : REAL;
    deriv       : REAL;
    u           : REAL;
    firstScan   : BOOL := TRUE;
END_VAR

IF NOT Enable THEN
    Out := 0.0;
    integ := 0.0;
    prevErr := 0.0;
    firstScan := TRUE;
    RETURN;
END_IF;

err := Setpoint - PV;

IF firstScan THEN
    prevErr := err;
    firstScan := FALSE;
END_IF;

// Integral and derivative terms
integ := integ + (Ki * err * Ts);
deriv := (err - prevErr) / Ts;

// Unbounded output
u := (Kp * err) + integ + (Kd * deriv);

// Anti-windup via clamping integral based on output saturation
IF u > OutMax THEN
    u := OutMax;
    // Back-calculate: prevent further positive integration when saturated high
    IF err > 0.0 THEN
        integ := integ - (Ki * err * Ts);
    END_IF;
ELSIF u < OutMin THEN
    u := OutMin;
    // Prevent further negative integration when saturated low
    IF err < 0.0 THEN
        integ := integ - (Ki * err * Ts);
    END_IF;
END_IF;

Out := u;
prevErr := err;
END_FUNCTION_BLOCK
