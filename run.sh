#!/bin/bash
BAKDIR=./BAK

if [ -f "$BAKDIR" ]; then
    echo -e "$BAKDIR exists."

else
    echo "$BAKDIR not exists. Creating"
    mkdir $BAKDIR
fi

ALSAFILE=/etc/modprobe.d/alsa-base.conf
ALSAFIXSTRING="options snd-hda-intel power_save=0 power_save_controller=N"
if [ -f "$ALSAFILE" ]; then
    echo -e "$ALSAFILE exists."
    echo -e "Fixing audio ..."
    if grep "$ALSAFIXSTRING" $ALSAFILE >> /dev/null; then
        echo -e "\tFix for audio already exist!"
    else
        echo -e "\tFix for audio not exist! Applying fix"
        echo -e "\tBACKUP original ALSA file into BAK directory"
        sudo cp $ALSAFILE $BAKDIR
        sudo bash -c "echo '# Audio Clicking Fix' >> $ALSAFILE"
        sudo bash -c "echo '$ALSAFIXSTRING' >> $ALSAFILE"
    fi
else
    echo "$ALSAFILE not exists."
    echo -e "Not fixing audio ..."  
fi


SYSTEMDSLEEPDIR=/lib/systemd/system-sleep/
if [ -d "$SYSTEMDSLEEPDIR" ]; then
    echo -e "$SYSTEMDSLEEPDIR exist."

    SLEEPFILE=touchpad
    if [ -f "$SLEEPFILE" ]; then
        echo -e "\t$SLEEPFILE exists."
        echo -e "\tNot fixing touchpad, file already exist ..."
    else
        echo -e "\t$SLEEPFILE not exists."
        echo -e "\tCopying $SLEEPFILE into $SYSTEMDSLEEPDIR/$SLEEPFILE"
        sudo cp "./files/$SLEEPFILE" $SYSTEMDSLEEPDIR/$SLEEPFILE
        sudo chown root:root $SYSTEMDSLEEPDIR/$SLEEPFILE
        sudo chmod +x $SYSTEMDSLEEPDIR/$SLEEPFILE
    fi
else
    echo -e "$SYSTEMDSLEEPDIR not exist."
    echo -e "Not fixing touchpad, systemd sleep dir not exist ..."
fi



KEYBOARDSYMBOLSDIR=/usr/share/X11/xkb/symbols/
KEYBOARDRULESDIR=/usr/share/X11/xkb/rules/
if [ -d "$KEYBOARDSYMBOLSDIR" ] && [ -d "$KEYBOARDRULESDIR" ]; then
    echo -e "X11 Keyboard rules and symbols exists."
    echo -e "\tBACKUP original Keyboard Symbols file into BAK directory"
    sudo cp $KEYBOARDSYMBOLSDIR/it $BAKDIR
    echo -e "\tBACKUP original Keyboard Rules files into BAK directory"
    sudo cp $KEYBOARDRULESDIR/base.lst $BAKDIR
    sudo cp $KEYBOARDRULESDIR/evdev.lst $BAKDIR
    sudo cp $KEYBOARDRULESDIR/evdev.xml $BAKDIR

    echo -e "\tApplying Keyboard patch"
    sudo patch -R $KEYBOARDSYMBOLSDIR/it < ./files/symbols_it.patch
    sudo patch -R $KEYBOARDRULESDIR/base.lst < ./files/rules_base-lst.patch
    sudo patch -R $KEYBOARDRULESDIR/evdev.lst < ./files/rules_evdev-lst.patch
    sudo patch -R $KEYBOARDRULESDIR/evdev.xml < ./files/rules_evdev-xml.patch
    sudo dpkg-reconfigure xkb-data
    sudo dpkg-reconfigure keyboard-configuration
else
    echo -e "X11 Keyboard rules and symbols not exists."
    echo -e "Not fixing keyboard Italian layout custom keys"
fi



