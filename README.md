# DriveEncryptor

## Encrypt your files
DriveEncryptor Helps you secure your files without worrying about manually moving all the files yourself! 

** NOTE: ALWAYS BACKUP YOUR FILES FIRST. **

## Ease of use
Running the script is simple. 

The syntax is: ./crypt.sh partitionName KeyName filesystemType

Real example: ./crypt.sh sda1 myDrive ext4

## Setup
Know the script. Don't be afraid to read it. Before you run the script you should modify the $mountpoint and $tmp parameters to make sure they exist, and in the case of $tmp, make sure its big enough to contain all files from $mountpoint. Additionally you may want to avoid using an SSD for $tmp since ALL data from $mountpoint are moved there temporarily

## Safety First!
Take care of your data. Though this script does take some precautions, there's never any guarantee. Always keep backups!
