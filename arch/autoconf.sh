#!/usr/bin/env bash

USERNAME=`whoami`

HOMEDIR=`realpath ~`
AURSDIR="$HOMEDIR/aurs"
SNIPPETSDIR="$AURSDIR/Snippets"
mkdir -p "$SNIPPETSDIR"

function toaurs(){
	cd "$AURSDIR"
}

####### BASE PACKAGES
sudo pacman -Sy --needed --noconfirm \
	git \
	xorg xorg-xinit \
	gvim \
	gcc make cmake \
	kitty \
	maim \
	xdotool \
	feh \
	alsa-firmware pulseaudio-alsa libpulse pavucontrol \
	dmenu \
	jre11-openjdk

sudo chmod +x /usr/bin/xinit
sudo rm -rf ~/.pulse ~/.asound*
sudo usermod -a -G wheel,audio,pulse "$USERNAME"


####### AURS AND OTHERS
toaurs
git clone git://git.suckless.org/dwm
git clone https://aur.archlinux.org/slstatus-git.git

## SLSTATUS
toaurs
cd slstatus-git
makepkg -is --noconfirm --needed

## DWM
toaurs
cd dwm
sudo make install
/bin/cp -rf "$SNIPPETSDIR/arch/dwm/config.h" ./
/bin/cp -rf "$SNIPPETSDIR/arch/dwm/XF86keysym.h" ./
sudo make install
sudo mkdir -p /etc/X11/xinit/
sudo /bin/cp -rf "$SNIPPETSDIR/arch/dwm/xinitrc" /etc/X11/xinit/xinitrc
sudo chmod +x /etc/X11/xinit/xinitrc
cat "$SNIPPETSDIR/arch/dwm/bash_profile_part.sh" >> "$HOMEDIR/.bash_profile"


## SCREENSHOTS
sudo /bin/cp -rf "$SNIPPETSDIR/arch/dwm/screenshot" /usr/bin
sudo chmod +x /usr/bin/screenshot

## BRIGHTNESS
sudo g++ "$SNIPPETSDIR/arch/src/brightnessconf.cpp" -o /usr/bin/brightnessconf
sudo chmod u=rwxs,g=rxs,o=rx /usr/bin/brightnessconf

## LOCKSCREEN
sudo g++ "$SNIPPETSDIR/arch/src/slock.cpp" -o /usr/bin/slock
sudo chmod u=rwxs,g=rxs,o=rx /usr/bin/slock

## VIM
sudo /bin/cp -rf "$SNIPPETSDIR/arch/vim/vimrc" /etc/
sudo chmod +x /etc/vimrc

## KITTY
mkdir -p "$HOMEDIR/.config/kitty"
/bin/cp -rf "$SNIPPETSDIR/arch/kitty/kitty.conf" "$HOMEDIR/.config/kitty/kitty.conf"

## FONTS
sudo /bin/cp -rf "$SNIPPETSDIR/arch/fonts/local.conf" "/etc/fonts/local.conf"
