# Modifying LLARS Config.ini

In order to customize the settings for this project, you may need to make changes to the LLARS Config.ini files. This file contain important configuration options that can be adjusted according to your requirements.

Please note that modifying this file should be done with caution and understanding of their impact. Incorrect changes to the configurations may lead to unexpected behavior or errors in the project.

Before making any modifications, it is advisable to review the provided documentation or seek guidance from the project creator to ensure you understand the purpose and effect of each configuration option.

Remember to back up the original configuration files before making any changes, so you can easily revert back if needed.

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
