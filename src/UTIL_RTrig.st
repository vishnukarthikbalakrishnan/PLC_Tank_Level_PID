(*
    UTIL_RTrig - Rising edge detector
*)
FUNCTION UTIL_RTrig : BOOL
VAR_INPUT
    In : BOOL;
END_VAR
VAR
    prev : BOOL := FALSE;
END_VAR

UTIL_RTrig := FALSE;

IF (In = TRUE) AND (prev = FALSE) THEN
    UTIL_RTrig := TRUE;
END_IF;

prev := In;
END_FUNCTION
