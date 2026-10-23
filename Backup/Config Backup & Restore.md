# Config Backup and Restore

LLARS includes `Backup\Config Backup.bat` and `Backup\Config Restore.bat` to protect both the shared LLARS configuration and script-specific settings during updates or manual changes.

The tools preserve:

- The root `LLARS Config.ini` used for shared hotkeys, input-backend settings, GUI positions, and framework options.
- Every script-local `Config.ini` found under the `Scripts` folder.

Backups are stored under the runtime-created `Backup\Config Backup` folder beside these tools. Script folder structure is preserved under `Backup\Config Backup\Scripts\`, while the shared configuration is stored as `Backup\Config Backup\LLARS Config.ini`.

## Config Backup

Run `Backup\Config Backup.bat` to create or refresh the current configuration backup. Existing backup copies are intentionally overwritten so the folder represents the latest saved LLARS configuration.

You can also use **Information → Backup Config** from a running LLARS script. It invokes the same batch tool without opening a separate command window.

## Config Restore

Run `Backup\Config Restore.bat` to copy the saved shared configuration and script-local configuration files back into the current LLARS folder.

You can also use **Information → Restore Config**. LLARS asks for confirmation before restoring because current configuration files will be overwritten, then reloads so the restored shared settings take effect.

## Updates

When LLARS finds a newer release and you choose to download it, LLARS automatically runs the same configuration backup before opening the Save As dialog. If the backup fails, the update download is not started and the current LLARS installation is left unchanged.

The backup folder is not part of the public release archive, so extracting a newer LLARS release over the existing LLARS folder does not intentionally replace the saved backup. After updating, use `Backup\Config Restore.bat` or **Information → Restore Config** when you need to restore the saved settings.
