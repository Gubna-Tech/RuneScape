# Smithing Script Instructions

This AutoHotKey (AHK) script is designed to automate the smithing process in RuneScape. Please follow the instructions below to properly set up and use the script:

## Config File
Before using the script, please ensure the following configurations in the LLARS Config file:

1. **Item Config:**
   In the [Item Config] section of the config file, enter the following information:
   - `bar`: Enter the type of metal bar you wish to smith (e.g., rune bar).
   - `modifier`: Specify the modifier for the smithing process, such as base, +1, +2, or +3.
   - `item`: Enter the type of item you want to smith, such as arrowhead.

2. **Scroll Configuration:**
   If your selected item needs to be scrolled down to in the smithing menu, configure the scroll settings in the [Scroll] section of the config file:
   - `min`: Specify the minimum number of scrolls required to reach the item frame on-screen.
   - `max`: Set a value between 2 and 5 more than the minimum to ensure randomness.

3. **Modifier Coordinates:**
   Set up the modifier coordinates in the config file to match the in-game positions. Use the appropriate section (e.g., [Base], [1], [2], [3]) to enter the following coordinates:
   - `xmin` and `xmax`: Specify the X-coordinate range for the modifier.
   - `ymin` and `ymax`: Specify the Y-coordinate range for the modifier.

4. **Bar Type Coordinates:**
   Configure the coordinates for the specific bar type you want to use. Locate the appropriate section in the config file (e.g., [Bronze Bar], [Iron Bar], [Steel Bar], [Mithril Bar], [Adamant Bar]) and enter the following coordinates:
   - `xmin` and `xmax`: Specify the X-coordinate range for the bar type.
   - `ymin` and `ymax`: Specify the Y-coordinate range for the bar type.

5. **Item Coordinates:**
   Find the item you want to smith in the config file using Ctrl+F to search. Ensure that the item coordinates in the respective section match the in-game item position.

## Timers and Hotkeys:
By default, the timers and hotkeys are set to generic values. However, it is recommended to customize them according to your preferences and playstyle.

## Starting the Script:
Once the config file is properly adjusted to your needs, you can start the script. Press the Start button on the GUI or use the designated start hotkey (default: F9, unless changed in the LLARS Config file).
