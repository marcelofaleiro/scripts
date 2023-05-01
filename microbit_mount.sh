#!/bin/bash
# microbit_mount.sh
# mount and unmount microbit
# modified from https://askubuntu.com/questions/342188/how-to-auto-mount-from-command-line

BASEPATH="/media/$(whoami)/"
MICRO="MICROBIT"

if [ $# -eq 0 ]
then
    echo "no argument supplied, use 'mount' or 'unmount'"
    exit 1
fi

if [ $1 == "--help" ]
then
    echo "mounts or unmounts a BBC micro:bit"
    echo "args: mount - mount the microbit, unmout - unmount the microbit"
fi

# how many MICRO found in udisksctl dump
RESULTS=$(udisksctl dump | grep IdLabel | grep -c -i $MICRO)

case "$RESULTS" in

0 )     echo "no $MICRO found in 'udkisksctl dump'"
        exit 0
        ;;

1 )     DEVICELABEL=$(udisksctl dump | grep IdLabel | grep -i $MICRO | cut -d ":" -f 2 | sed 's/^[ \t]*//')
        DEVICE=$(udisksctl dump | grep -i "IdLabel: \+$DEVICELABEL" -B 12 | grep " Device:" | cut -d ":" -f 2 | sed 's/^[ \t]*//')
        DEVICEPATH="$BASEPATH""$DEVICELABEL"
        echo "found one $MICRO, device: $DEVICE"

        if [[ -z $(mount | grep "$DEVICE") ]]
        then
            echo "$DEVICELABEL was unmounted"
            if [ $1 == "mount" ]
            then
                udisksctl mount -b "$DEVICE"
                exit 0
            fi
        else
                echo "$DEVICELABEL was mounted"
                if [ $1 == "unmount" ]
                then
                    udisksctl unmount -b "$DEVICE"
                    exit 0
                fi
        fi
        ;;

* )     echo "more than one $MICRO found"
        ;;

    esac

echo "exiting without doing anything"
