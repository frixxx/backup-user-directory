# Backup User Directory

Rsyncs the current user folder on the current machine to a server via ssh.

## Backup Target Directory Structure
The backup will be stored on the remote server in the following structure:

- `<target-directory>/`
  - `logs/`
    - `<user>@<hostname>.log`
    - ...
    - `<user>@<hostname>/`
      - `<synced data>`
      - ...

## Configure the backup

Create oder edit the file `~/.config/fx/backup-user-directory/.env` and provide the following Environment Variables:

```bash
BACKUP_USER_DIRECTORY___REMOTE_SERVER=remote.server.com                   #required
BACKUP_USER_DIRECTORY___REMOTE_USER=user                                  # defaults to root if not set
BACKUP_USER_DIRECTORY___REMOTE_BACKUP_PATH=/path/to/backup/location       # defaults to /data/backups if not set
BACKUP_USER_DIRECTORY___REMOTE_LOGGING_SCRIPT=/path/to/logging/script.sh  # defaults to /root/scripts/backups-log if not set
BACKUP_USER_DIRECTORY___REMOTE_LOGGING_ENABLED=1                          # enable remote logging (1) or disable (0) - defaults to 1
BACKUP_USER_DIRECTORY___CHANGE_OWNER_ENABLED=1                            # enable changing owner of backed up files (1) or disable (0) - defaults to 0
BACKUP_USER_DIRECTORY___CHANGE_OWNER_USER=user                            # user to set as owner of backed up files - defaults to root
BACKUP_USER_DIRECTORY___CHANGE_OWNER_GROUP=group                          # group to set as owner of backed up files - defaults to root
BACKUP_USER_DIRECTORY___SSH_KEY_PATH=<pathToKeyInclKey>                   # path to ssh private key to use for connection - defaults to ~/.ssh/id_ed25519
```

## Configure Hostname Overrides 

Sometimes you have no full control over the hostname of your machine but you want to have a consistent backup location.

Here is how you provide hostname replacement:

Edit the file `~/.config/fx/backup-user-directory/.env` and provide this config:

```bash
BACKUP_USER_DIRECTORY___HOSTNAME_REPLACEMENT=<desiredHostname>
```

## Exclusions

If you want to exclude certain files or folders from the backup you can create a file `~/.config/fx/backup-user-directory/exclusions` and provide paths relative to your home directory, e.g.:

```
node_modules
.DS_Store
/.m2
.Trash
.Trashes
/.cache
```
