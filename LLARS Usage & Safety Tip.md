# LLARS Usage & Safety Tips

LLARS is an automation framework for RuneScape3 (RS3). Before running any script, take time to understand how it works, configure it correctly, and understand the risks associated with game automation. No configuration or usage pattern can guarantee that an account will avoid penalties.

## Before You Run a Script

1. **Read the Setup Guide**  
   Read the [LLARS - Setup Guide](Documentation/LLARS%20-%20Setup%20Guide.pdf) before setting up or running LLARS. It explains the framework, GUI, hotkeys, coordinates, colors, timers, RunCount settings, and normal script operation.

2. **Read the Script's Config.ini**  
   Individual scripts can have their own requirements and instructions. Read the comments in that script's `Config.ini` and do not assume that settings from one script apply to another.

3. **Understand the Account Risk**  
   Automation can violate game rules or terms of service and may result in account penalties. Only use LLARS after considering that risk and accepting responsibility for the account on which you run it.

4. **Test Your Configuration First**  
   Before starting a long run, use a short RunCount or Time-by-User session to confirm that coordinates, colors, inventory positions, bank positions, and other script-specific settings still match your current game layout.

## While Using LLARS

5. **Keep Coordinates and Colors Current**  
   RuneScape interface changes, game updates, resolution changes, UI scaling, or moving interface elements can make saved coordinates or colors inaccurate. Reconfigure affected settings whenever your layout changes or a script stops interacting with the intended location.

6. **Use Reasonable Run Times**  
   Avoid leaving automation running for long periods without checking it. Shorter sessions make it easier to notice configuration problems, game changes, unexpected interfaces, or other conditions that could cause incorrect input.

7. **Keep the Exit Hotkey Available**  
   Know your configured Exit hotkey before starting a script. LLARS is designed to keep the Exit hotkey available while a script is running so you can stop execution quickly when necessary.

8. **Watch the First Few Loops**  
   When using a new script or a newly changed configuration, observe the first few loops. Confirm that the script performs the expected actions and that the LLARS timer and RunCount behavior make sense for the activity.

9. **Do Not Assume a Script Is Maintenance-Free**  
   Game updates can change interfaces, object positions, timing, colors, or behavior. A script that worked previously may need its configuration updated before it is safe to run again.

10. **Stop When Something Looks Wrong**  
    If LLARS clicks the wrong location, encounters an unexpected interface, stops progressing, or otherwise behaves differently from expected, use the Exit hotkey and correct the configuration before continuing.

## Additional Information

LLARS does not provide a guarantee against account penalties, detection, game changes, configuration errors, or other consequences of automation. Use the framework responsibly, keep your configuration current, and make informed decisions about when and where you run scripts.

For general setup information, return to the [README](README.md) or read the [LLARS - Setup Guide](Documentation/LLARS%20-%20Setup%20Guide.pdf).

---

# Disclaimer

The scripts and LLARS framework provided in this repository are offered for educational purposes. Use of this software is at your own risk.

You are responsible for how you use LLARS and for any actions performed while using its scripts. The project author and contributors assume no responsibility for account penalties, losses, violations of game rules or terms of service, or other consequences resulting from use of the software.

Automation may violate rules or policies established by the game developer and may result in penalties, including temporary or permanent restrictions on a game account. You are responsible for reviewing and understanding the applicable rules and deciding whether and how to use this software.

No script, configuration, timing choice, or usage practice can guarantee that automation will be safe or free from penalties. Exercise caution, make informed decisions, and understand the risks before running LLARS.
