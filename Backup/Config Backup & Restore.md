# Config Backup and Restore

LLARS includes `Backup\Config Backup.bat` and `Backup\Config Restore.bat` to protect both the shared LLARS configuration and script-specific settings during updates or manual changes.

The tools preserve:

- The root `LLARS Config.ini` used for shared hotkeys, input-backend settings, GUI positions, and framework options.
- Every script-local `Config.ini` found under `Scripts` and `Scripts - Menu Entry Swapper`.

The latest successful snapshot is stored under the runtime-created `Backup\Config Backup` folder beside these tools. LLARS also retains up to two previous successful snapshots as `Backup\Config Backup 1` and `Backup\Config Backup 2`. Script folder structure is preserved inside each snapshot under `Scripts\` and, when present, `Scripts - Menu Entry Swapper\`, while the shared configuration is stored as `LLARS Config.ini`.

## Config Backup

Run `Backup\Config Backup.bat` to create a new configuration snapshot. The tool builds the complete new snapshot in a staging folder first. Only after staging succeeds does it rotate the previous successful snapshots, so a failed backup does not intentionally replace the last known-good `Config Backup`.

You can also use **Information → Backup Config** from a running LLARS script. It invokes the same batch tool without opening a separate command window.

## Config Restore

Run `Backup\Config Restore.bat` to copy the **latest** saved shared configuration and script-local configuration files from `Backup\Config Backup` back into the current LLARS folder. The two older retained snapshots remain available as `Config Backup 1` and `Config Backup 2` for manual recovery if needed.

You can also use **Information → Restore Config**. LLARS asks for confirmation before restoring because current configuration files will be overwritten, then reloads so the restored shared settings take effect.

## Updates

When LLARS finds a newer release and you choose to download it, LLARS automatically runs the same configuration backup before opening the Save As dialog. If the backup fails, the update download is not started and the current LLARS installation is left unchanged.

The runtime-created backup snapshot folders are not part of the public release archive, so extracting a newer LLARS release over the existing LLARS folder does not intentionally replace the saved backups. After updating, use `Backup\Config Restore.bat` or **Information → Restore Config** when you need to restore the saved settings.
