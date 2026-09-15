# Config Backup and Restore

Project updates can sometimes replace or reset script configuration files. To make it easier to preserve your script-specific settings, LLARS includes two batch files: `Config Backup.bat` and `Config Restore.bat`.

These tools are intentionally limited to the individual `Config.ini` files inside the `Scripts` folder.

> **Important:** The root `LLARS Config.ini` is not backed up, restored, overwritten, or otherwise changed by these tools.

## Config Backup

Running `Config Backup.bat` creates or updates backup copies of every script-local `Config.ini` found under the `Scripts` folder.

The original script folder structure is preserved inside:

`Config Backup\Scripts\`

If a backed-up `Config.ini` already exists, the backup is overwritten with the current script configuration.

To back up your script configuration files:

1. Run `Config Backup.bat`.
2. LLARS scans the `Scripts` folder for files named `Config.ini`.
3. Each script `Config.ini` is copied to the matching location under `Config Backup\Scripts\`.

The root `LLARS Config.ini` is intentionally excluded from this process.

## Config Restore

Running `Config Restore.bat` restores the backed-up script-local `Config.ini` files from `Config Backup\Scripts\` to their matching script folders under `Scripts`.

To restore your script configuration files:

1. Run `Config Restore.bat`.
2. LLARS scans the backup for files named `Config.ini`.
3. Each backed-up `Config.ini` is copied back to its matching existing script folder.

The restore process only restores script `Config.ini` files. It does not restore or modify the root `LLARS Config.ini`.

## LLARS Config.ini

`LLARS Config.ini` contains shared framework-wide settings and is separate from the individual script configuration backups.

If you want to keep a personal backup of `LLARS Config.ini`, copy that file separately. The provided Config Backup and Config Restore batch files intentionally leave it alone.

Before updating the project or making major configuration changes, running `Config Backup.bat` is recommended so your script-specific settings can be restored afterward.
