mountpoint=/mnt/tmp
tmp=/mnt/Archive
drive=$1
keyname=$2

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

fs=$(ls /usr/bin|grep mkfs|awk -v sel="$3" \
    '{
        if(sel == "swap"){
            print(sel);
        }
        split($0, tmp, "."); 
        for(i in tmp){ 
            split(tmp[i], fs, "_"); 
        }
        for(i in fs){ 
            if(fs[i] == sel){ 
                print(sel) 
            } 
        } 
    }')
    
if [[ $fs != *[!\ ]* ]]; then
    echo "Invalid Filesystem"
    exit
fi
echo "Filesystem is valid"

part=$(ls /dev|grep $drive)
if [[ $part != *[!\ ]* ]]; then
  echo "Invalid drive"
  exit
fi
echo "Drive exists"

if [ $# -ne 3 ]; then
    echo "Usage: ./crypt.sh <$drive e.g sda1> <partition name e.g. usr> <fs type e.g. ext4>"
    exit
fi

echo "Note: This script can be very volatile. Be very careful"
read -n1 -r -p "Press any key to continue at your own risk" key

if [ "$fs" != "swap" ]; then
    echo "Mounting /dev/$drive to $mountpoint"
    mount /dev/$drive /mnt/tmp > /dev/null
    
    echo "Synchronizing files from $mountpoint to $tmp"
    rsync -a $mountpoint/* $tmp > /dev/null
    
    echo "Unmounting $mountpoint"
    umount $mountpoint > /dev/null
fi

echo -e "Creating new key at .$keyname\0key"
dd if=/dev/urandom of=.$keyname\key bs=1024 count=4 > /dev/null 2>&1

echo -e "Formatting /dev/$drive to Luks with .$key\0namekey"
cryptsetup luksFormat /dev/$drive -d .$keyname\key

echo "Mapping decrypted /dev/$drive to /dev/mapper/$drive"
cryptsetup luksOpen /dev/$drive -d .$keyname\key $drive > /dev/null

echo "Creating a fresh $fs fs on /dev/mapper/$drive"
if [ "$fs" = "swap" ]; then
    mkswap /dev/mapper/$drive > /dev/null
else
    mkfs -t $fs /dev/mapper/$drive > /dev/null 2>&1
    
    echo "Mounting new fs to $mountpoint"
    sleep 1
    mount /dev/mapper/$drive $mountpoint > /dev/null
    
    echo "Synchronizing from $tmp to $mountpoint"
    sleep 1
    rsync -a $tmp/* $mountpoint > /dev/null
    
    echo "Unmounting formatted $drive"
    sleep 1
    umount $mountpoint
    
    echo "Cleaning up $tmp"
    rm -r $tmp/* > /dev/null
fi

echo "Unmapping $drive from /dev/mapper/$drive"
cryptsetup luksClose /dev/mapper/$drive > /dev/null

echo "Done!"

