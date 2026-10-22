; ================================================================
; |     LLARS MASTER LIBRARY     -     LLARS MASTER LIBRARY      |
; ================================================================

; Loads AutoHotInterception when first-run setup has installed its AHK v1 library.
; *i keeps a fresh LLARS download launchable before that one-time setup occurs.
#Include *i %A_LineFile%\..\..\Vendor\AutoHotInterception\Lib\AutoHotInterception.ahk

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
