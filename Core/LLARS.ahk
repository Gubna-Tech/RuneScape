; ================================================================
; |     LLARS MASTER LIBRARY     -     LLARS MASTER LIBRARY      |
; ================================================================

; Loads the bundled AutoHotInterception AHK v1 library when available.
; *i keeps first launch working while the Windows Interception driver is being set up.
#Include *i %A_LineFile%\..\..\Vendor\AutoHotInterception\Lib\AutoHotInterception.ahk

; Loads version metadata and GitHub release update helpers.
#Include %A_LineFile%\..\LLARS_Update.ahk

; Loads the LLARS input-backend/bootstrap layer.
#Include %A_LineFile%\..\LLARS_AHI.ahk

; Loads the shared Core functions used by every LLARS script.
#Include %A_LineFile%\..\LLARS_Core.ahk

; Loads the standardized creator-facing API.
#Include %A_LineFile%\..\LLARS_CreatorAPI.ahk

; Loads the main, RunCount, and Timer GUI builders.
#Include %A_LineFile%\..\LLARS_GUI.ahk

; Loads runtime estimation and shared completion helpers.
#Include %A_LineFile%\..\LLARS_Runtime.ahk
