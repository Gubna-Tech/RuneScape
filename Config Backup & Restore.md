# Config Backup and Restore

Updates to the project can sometimes be inconvenient, especially with the frequent small changes that are pushed. To make it easier for you to manage and safeguard your configuration files, I have provided two batch files: Config Backup.bat and Config Restore.bat.

## Config Backup

Running the Config Backup.bat file will create a backup of all the Config.ini and LLARS Config.ini files. These files will be copied to a folder named "Config Backup." This way, when you clone this repository or update the project, you won't have to worry about losing your customized configurations.

To create a backup of your config files:

1. Run the `Config Backup.bat` file.
2. The script will automatically copy all the Config.ini and LLARS Config.ini files to the "Config Backup" folder.

## Config Restore

In case you need to restore your backed-up config files, the `Config Restore.bat` file comes to your rescue. This file simplifies the process of restoring your previously saved configurations.

To restore your backed-up config files:

1. Run the `Config Restore.bat` file.
2. The script will automatically restore the previously backed-up Config.ini and LLARS Config.ini files to their original locations.

With the Config Backup and Restore batch files, you can conveniently backup and restore your configuration files, ensuring that your settings are preserved and ready to use.

Please note that it is always recommended to keep backups of your config files, especially before making significant changes or updating the project. This precaution helps safeguard your customizations and ensures a smooth transition during updates.

Happy scripting!
