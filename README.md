# OrangeHRM AWS CLI Utility

This command line utility allows you to manage your OrangeHRM AWS instance from the terminal of your EC2 instance.

## OrangeHRM Command
This utility allows you to install, update and remove your OrangeHRM installation on AWS.

## How to install
Download the RPM and run `sudo dnf install orangehrm-<releasever>.amzn2023.noarch.rpm`

### Usage
```
orangehrm COMMAND
```

### Commands
- `help`: Display information on how to use the command
- `install`: Install a dockerized version of OrangeHRM
- `update`: Update to a newer version of OrangeHRM
- `check-update`: Check for a newer version of OrangeHRM
- `status`: Displays whether OrangeHRM is installed or not
- `clean`: Completely wipe all data and backups related to OrangeHRM

## OrangeHRM Backup Command
This utility allows you to manage your OrangeHRM AWS backups

### Usage
```
orangehrm backup COMMAND
```

### Commands
- `help`: Display information on how to use the command
- `create`: Create a backup
- `restore`: Restore an existing backup
- `list`: List your existing backups
- `clean`: Wipe all your exsting backups
