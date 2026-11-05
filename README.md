<h1 align="center">
  <strong>LLARS</strong>
</h1>

<h3 align="center">
  <strong>L</strong>ocal <strong>L</strong>ibrary of <strong>A</strong>utomated <strong>R</strong>outines and <strong>S</strong>cripts
</h3>

<p align="center">
  <img
    width="250"
    height="250"
    src="https://raw.githubusercontent.com/Gubna-Tech/RuneScape/main/Assets/Logo/LLARS/LLARS%20Logo.png"
    alt="LLARS Logo"
  >
  <a href="https://www.autohotkey.com">
    <img
      width="250"
      height="250"
      src="https://raw.githubusercontent.com/Gubna-Tech/RuneScape/main/Assets/Logo/LLARS/AHK%20Logo.png"
      alt="AutoHotkey Logo"
    >
  </a>
</p>

<p align="center">
  <a href="https://github.com/Gubna-Tech/RuneScape/archive/main.zip">
    <img
      src="https://raw.githubusercontent.com/Gubna-Tech/RuneScape/main/Assets/LLARS%20Download.png"
      alt="Download LLARS"
      width="400"
      height="120"
    >
  </a>
</p>

<p align="center">
  <a href="https://discord.gg/Wmmf65myPG">
    <img
      src="https://raw.githubusercontent.com/Gubna-Tech/RuneScape/a0b944fa0adb2ff6251545e43360c004e3b12819/Assets/LLARS%20Discord.png"
      alt="Join the LLARS Discord"
      width="400"
      height="120"
    >
  </a>
</p>

---

## What is LLARS?

LLARS is a free and open-source AutoHotkey framework and script-building toolkit for **RuneScape 3 (RS3/EoC)** and **Old School RuneScape (OSRS)**. Its included scripts are for RS3; the LLARS framework and Script Generator can also be used to create and run OSRS-specific scripts.

It provides a shared framework, Creator API, reusable functions, configuration system, GUI tools, and supporting libraries for creating and running LLARS-compatible scripts.

LLARS is designed for both:

- **Script Users** — Configure and run existing LLARS-compatible scripts.
- **Script Creators** — Build, maintain, and expand automation using the LLARS framework.

---

## Table of Contents

- [Important Note for Script Use](#important-note-for-script-use)
- [LLARS Documentation](#llars-documentation)
  - [Setup Guide](#setup-guide)
  - [Script Creator Documentation](#script-creator-documentation)
  - [Script Instructions](#script-instructions)
  - [Configuration Backup & Restore](#configuration-backup--restore)
- [Requirements](#requirements)
- [Support](#support)

---

## Important Note for Script Use

> ### Script Configuration
>
> **You do not need to make changes to the script itself.**
>
> For normal setup, use the **Instructions** button on the idle LLARS window and the editors in **Setup**. You do not need to open or edit `Config.ini` files to follow a bundled script's walkthrough. Only open a configuration file when an instruction or a specific advanced setting requires it.

**The included scripts are designed for RuneScape 3 (RS3/EoC) only.** LLARS recognizes Old School RuneScape (OSRS) through the official client and RuneLite, and creators can use its framework and Script Generator to build OSRS scripts. **No ready-made OSRS scripts are included.**

Make sure to use these scripts only with the appropriate version of the game and understand the risks and responsibilities associated with game automation.

Before using LLARS, please read the **[LLARS Usage & Safety Tip](Documentation/LLARS%20Usage%20%26%20Safety%20Tip.md)**.

The project disclaimer is included at the bottom of that file.

---

## LLARS Documentation

LLARS includes documentation for both first-time users and script creators.

### Setup Guide

Before setting up or running a script, **please read the [LLARS - Setup Guide](Documentation/LLARS%20-%20Setup%20Guide.pdf)** included with the project.

The LLARS Setup Guide is the primary guide for learning how to:

- Set up LLARS and its scripts
- Open script-specific **Instructions** and follow the setup walkthrough
- Use **Setup > Hotkeys**, **Coordinates**, **Colors**, and **Timer** when the script needs them
- Confirm required settings with **Setup > Check Setup**
- Understand when an advanced option genuinely requires opening a configuration file
- Run scripts correctly
- Understand timer and run-count settings
- Pause, resume, and stop scripts
- Troubleshoot common setup problems
- Keep your RuneScape layout configured correctly for the script

The Setup Guide is written for **first-time users** and provides the information needed to set up and use LLARS scripts without requiring users to modify the script itself.

### Script Creator Documentation

LLARS is built around a shared framework and Creator API used by the scripts in this repository.

Script creators who want to create or update LLARS-compatible scripts should read:

- **[LLARS - Script Creator & Framework Guide](Documentation/LLARS%20-%20Script%20Creator%20%26%20Framework%20Guide.pdf)**
- **[LLARS - Script Creator Library](Documentation/LLARS%20-%20Script%20Creator%20Library.pdf)**

These are the recommended resources for LLARS v2.x and newer scripts. They cover the current Creator API, framework behavior, reusable components, templates, and copy/paste patterns used throughout the project.

### Script Instructions

**Instructions is the starting point for setting up a bundled script.** Choose your script in Script Selector, then select **Instructions** from its idle LLARS window, below **Setup**. Each script's guide explains its starting position, required items or settings, and the steps to follow before pressing **Start**.

Read **Before You Start** first, then follow **Steps to Run** in order. **Optional Settings** and **Additional Script Notes** appear separately when applicable. The Instructions window includes **Colors**, **Coordinates**, **Hotkeys**, and **Timer** shortcuts; categories the selected script does not use are disabled. You can also open the same editors through **Setup**. For coordinates, select the named field in **Setup > Coordinates** and right-click the indicated in-game target to capture it. Finish by using **Setup > Check Setup** to check the applicable settings.

**Follow the guide for the exact script variant you selected.** For example, standard banking scripts can use a configured **[Bank Preset]** hotkey, while Menu Entry Swapper (**MES**) variants may require the correct preset to have been loaded first. Do not carry setup assumptions from one script to another.

The root `LLARS Config.ini` and script-local `Config.ini` files store settings, but **routine setup should not require editing them by hand**. Use the LLARS editors first. Open **Setup > Script Config** or **Config Settings** only when a script-specific instruction, unsupported advanced option, or troubleshooting situation actually requires it. Back up your configuration before making manual changes.

### Configuration Backup & Restore

LLARS includes the existing backup and restore tools under the **[Backup](Backup/Config%20Backup%20%26%20Restore.md)** folder. They protect the shared `LLARS Config.ini` and script-local `Config.ini` files, and the same backup tool is used automatically before an LLARS update download begins.

---

## Requirements

| Requirement | Version / Information |
| :--- | :--- |
| **Operating System** | Windows |
| **AutoHotkey** | v1.1.37.02 |
| **Game clients** | RuneScape 3 (RS3/EoC); Old School RuneScape (official client or RuneLite). Included scripts: RS3 only. |
| **Script Format** | Uncompiled `.ahk` scripts |

LLARS is built for **AutoHotkey v1**, and the scripts are provided in an uncompiled format.

If you haven't installed AutoHotkey yet, download the required **v1.1.37.02** release from the official AutoHotkey website.

<p align="center">
  <a href="https://www.autohotkey.com/download/1.1/AutoHotkey_1.1.37.02_setup.exe">
    <strong>Download AutoHotkey v1.1.37.02</strong>
  </a>
</p>

> ### AutoHotkey Version
>
> LLARS is built for **AutoHotkey v1.1.37.02**.
>
> AutoHotkey v2 is not a drop-in replacement for AutoHotkey v1 scripts.

### Input backend

LLARS recommends **AutoHotInterception (AHI)** for mouse and keyboard input. The AHI runtime and Interception installer are bundled with LLARS, and a clean installation is offered automatically when AHI is not present. Installation requires an Administrator prompt and one Windows restart.

**Standard AutoHotkey** remains available as a fallback under **Information > Input Settings**. Input Settings shows the configured backend, active input route, AHI driver/device routes, last mouse/keyboard transport, startup timing, and fallback state. It also provides a non-invasive **Test AHI** health check plus the existing enable/repair and uninstall controls.

---

## Support

For questions, setup help, script support, or information about the LLARS framework, join <a href="https://discord.gg/Wmmf65myPG">**Gubna's Script Support Discord Server**.

**Discord Contact:** `Gubna`  
*Formerly `Gubna#0001`*

<p align="center">
  <strong><a href="https://discord.gg/Wmmf65myPG">Join the Discord Server</a></strong>
</p>
