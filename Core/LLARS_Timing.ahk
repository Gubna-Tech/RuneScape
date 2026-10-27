; ================================================================
; |     LLARS TIMING     -     MONOTONIC & RUN TIMING            |
; ================================================================
; Owns the single monotonic millisecond clock and shared run/countdown/
; Random Sleep timing state transitions.

; Shared monotonic millisecond clock. This pre-Core module is loaded by both
; normal LLARS scripts and Script Selector, so every shared timing caller sees
; the same GetTickCount64-backed clock without adding a new module boundary.
LLARS_NowMS()
{
    return DllCall("Kernel32.dll\GetTickCount64", "UInt64")
}
