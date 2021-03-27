#!/usr/bin/env bash

INSTALL_WINDOWS_FONTS=true
INSTALL_LIBREOFFICE=true
INSTALL_FIREFOX=true

USERNAME=`whoami`
HOMEDIR=`realpath ~`
AURSDIR="$HOMEDIR/aurs"
SNIPPETSDIR="$HOMEDIR/Snippets"
AUTODIR="$SNIPPETSDIR/arch_dwm"
mkdir -p "$AURSDIR"

function toaurs(){
	cd "$AURSDIR"
}
alias installi="sudo pacman -Sy --needed --noconfirm"
alias makepkgi="makepkg -is --needed --noconform"
alias cprf="/bin/cp -rf"

####### BASE PACKAGES
installi \
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
	tar gzip \
	jre11-openjdk

sudo chmod +x /usr/bin/xinit
sudo rm -rf ~/.pulse ~/.asound*
sudo usermod -a -G wheel,audio,pulse "$USERNAME"

####### ADDITIONAL PACKAGES
if $INSTALL_LIBREOFFICE; then
	installi libreoffice
fi
if $INSTALL_FIREFOX; then
	installi firefox
fi


####### AURS AND OTHERS
toaurs
git clone git://git.suckless.org/dwm
git clone https://aur.archlinux.org/slstatus-git.git

## SLSTATUS
toaurs
cd slstatus-git
makepkgi

## DWM
toaurs
cd dwm
sudo make install
cprf "$AUTODIR/dwm/config.h" ./
cprf "$AUTODIR/dwm/XF86keysym.h" ./
sudo make install
sudo mkdir -p /etc/X11/xinit/
sudo cprf "$AUTODIR/dwm/xinitrc" /etc/X11/xinit/xinitrc
sudo chmod +x /etc/X11/xinit/xinitrc
cat "$AUTODIR/dwm/bash_profile_part.sh" >> "$HOMEDIR/.bash_profile"


## SCREENSHOTS
sudo cprf "$AUTODIR/dwm/screenshot" /usr/bin
sudo chmod +x /usr/bin/screenshot

## BRIGHTNESS
sudo g++ "$AUTODIR/src/brightnessconf.cpp" -o /usr/bin/brightnessconf
sudo chmod u=rwxs,g=rxs,o=rx /usr/bin/brightnessconf

## LOCKSCREEN
sudo g++ "$AUTODIR/src/slock.cpp" -o /usr/bin/slock
sudo chmod u=rwxs,g=rxs,o=rx /usr/bin/slock

## VIM
sudo cprf "$AUTODIR/vim/vimrc" /etc/
sudo chmod +x /etc/vimrc

## KITTY
mkdir -p "$HOMEDIR/.config/kitty"
cprf "$AUTODIR/kitty/kitty.conf" "$HOMEDIR/.config/kitty/kitty.conf"

## FONTS
sudo cprf "$AUTODIR/fonts/local.conf" "/etc/fonts/local.conf"
if $INSTALL_WINDOWS_FONTS; then
	toaurs
	git clone https://github.com/MiloLug/SnippetsFonts.git
fi
# Windows Fonts
if $INSTALL_WINDOWS_FONTS; then
	toaurs
	cd SnippetsFonts/WinfowsFonts
	
	cat fonts.tar.gz.part* > fonts.tar.gz
	tar xzf fonts.tar.gz
	sudo mv fonts /usr/share/fonts/WindowsFonts
fi
toaurs
rm -rf SnippetsFonts
