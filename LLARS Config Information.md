# Modifying LLARS Config.ini
In order to customize the settings for this project, you may need to make changes to the LLARS Config.ini files. This file contain important configuration options that can be adjusted according to your requirements.

Please note that modifying this file should be done with caution and understanding of their impact. Incorrect changes to the configurations may lead to unexpected behavior or errors in the project.

Before making any modifications, it is advisable to review the provided documentation or seek guidance from the project creator to ensure you understand the purpose and effect of each configuration option.

Remember to back up the original configuration files before making any changes, so you can easily revert back if needed.

## Notepad++ for Configuration Files:
For better readability and ease of editing, it is recommended to use Notepad++ for working with the configuration files. Notepad++ provides syntax highlighting and other useful features that can enhance your editing experience.

[Notepad++  Download](https://notepad-plus-plus.org/downloads/)

## Saving the Config File
Before starting the script, it is crucial to save the configuration file with your desired settings. Ensure that any modifications or changes made to the config file are saved properly.

Saving the config file ensures that the script uses the updated configurations you have set. It allows the script to function according to your preferences and requirements.

Remember to save the config file before launching the script to ensure that the changes you have made are applied correctly.

## HotKey Configuration
To configure hotkeys for the LLARS script, you will need to make changes in the LLARS Config.ini file. This file contains the settings related to hotkeys used within the script.

When assigning hotkeys, it is important to ensure they do not conflict with any existing hotkeys set in the script or the program itself. You can find a list of available hotkey names at [AutoHotKey KeyList](https://www.autohotkey.com/docs/v2/KeyList.htm).

To avoid conflicts, it is recommended to review the hotkeys set in both the LLARS Config.ini file and the Config.ini file. The hotkeys defined in the Config.ini file are specific to the program itself.

Make sure to carefully choose unique hotkey combinations and avoid overlapping with any pre-defined hotkeys. Conflicting hotkeys can lead to unexpected behavior or interfere with the proper functioning of the script.

## Logout Configuration
The logout functionality in the script can be configured based on the value of the option setting in the configuration file.

If **option=false** When the script finishes running, no specific action will be taken for logging out.

If **option=true** The script will simulate pressing the "Esc" key to open the in-game menu and then click on the logout button.

To set the coordinates for the logout button, follow these steps:

1. Press the Coordinates hotkey (F10) by default.
2. Hover your mouse cursor over the top left corner of the logout button (within the border) and then press the hotkey.
3. Next, hover over the bottom right corner of the logout button and press the hotkey.
4. Press the hotkey once more to clear the tooltip message.
5. The coordinates for the logout button will now be saved to your clipboard and can be easily pasted into the configuration file.

By configuring the correct coordinates, the script will be able to accurately locate and interact with the logout button within the game.

## GUI Position Configuration
Configuring the GUI position involves adjusting the **guix** and **guiy** settings in the configuration file. These settings determine the coordinates on your screen where the top-left corner of the GUI will be positioned.

To configure the GUI position, follow these steps:

1. Utilize the built-in AutoHotKey tool called Window Spy. This tool provides information about windows and their coordinates on the screen.
2. Open the Window Spy tool and locate the desired coordinates on your screen where you want the top-left corner of the GUI to be positioned.
3. Take note of the coordinates displayed by the Window Spy tool. These coordinates will be used to set the guix and guiy values in the configuration file.
4. In the configuration file, adjust the guix setting to match the X-coordinate value of the desired GUI position, and adjust the guiy setting to match the Y-coordinate value.

By correctly configuring the guix and guiy settings with the appropriate coordinates, the GUI of the script will be positioned exactly where you want it on your screen.

## Hotkey Message Configuration

The hotkey message configuration determines whether a startup message displaying the configured hotkeys will appear when starting the script within the specified directory.

If **option=false** No startup message will be displayed, and the hotkeys will not be shown when launching the script.

If **option=true** A message box will appear upon script startup, displaying the hotkeys as configured in the LLARS Config.ini file.

To configure the hotkey message behavior:

1. Set the option value in the configuration file to either true or false based on your preference.

When **option=false**, the script will run without showing a hotkey message.

When **option=true**, a message box will display the configured hotkeys upon script startup.

Ensure that the option setting reflects your desired behavior for displaying the hotkey message.

## Thank You Message Configuration

The thank you message configuration determines whether a message expressing gratitude will appear when closing the script.

If **option=false** No thank you message will be displayed when closing the script.

If **option=true** A message box will appear upon script closure, expressing a thank you message.

To configure the thank you message behavior:

Set the option value in the configuration file to either true or false based on your preference.

When **option=false**, the script will close without displaying a thank you message.

When **option=true**, a message box will be shown when closing the script, expressing a thank you message.

Make sure the option setting accurately represents your desired behavior for displaying the thank you message.

*If you have any questions or need assistance with configuring the LLARS Config file, feel free to reach out to [Gubna#0001](https://discordapp.com/users/616070790319964160) on Discord. They will be able to provide further guidance and help you with the configuration process.*
