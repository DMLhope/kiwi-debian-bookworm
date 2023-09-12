#!/bin/bash
#================
# FILE          : config.sh
#----------------
# PROJECT       : OpenSuSE KIWI Image System
# COPYRIGHT     : (c) 2006 SUSE LINUX Products GmbH. All rights reserved
#               :
# AUTHOR        : Marcus Schaefer <ms@suse.de>
#               :
# BELONGS TO    : Operating System images
#               :
# DESCRIPTION   : configuration script for Debian based
#               : operating systems
#               :
#               :
# STATUS        : BETA
#----------------
#======================================
# Functions...
#--------------------------------------
test -f /.kconfig && . /.kconfig
test -f /.profile && . /.profile

#======================================
# Greeting...
#--------------------------------------
echo "Configure image: [$kiwi_iname]..."

#======================================
# Activate services
#--------------------------------------
# baseInsertService sshd
# baseInsertService lightdm

# Debug 1

# for i in NetworkManager tlp avahi-dnsconfd earlyoom zramswap; do
# 	systemctl -f enable $i
# done
# for i in purge-kernels wicked auditd apparmor; do
# 	systemctl -f disable $i
# done

# systemctl -f enable sshd

# systemctl -f enable lightdm


cd /

#======================================
# /etc/sudoers hack to fix #297695
# (Installation Live CD: no need to ask for password of root)
#--------------------------------------
sed -i -e "s/ALL ALL=(ALL) ALL/ALL ALL=(ALL) NOPASSWD: ALL/" /etc/sudoers
chmod 0440 /etc/sudoers

# /usr/sbin/useradd -m  linux -c "Live-CD User" -p ""  -g users -G sudo
useradd -m -s /bin/bash -G sudo linux
# delete passwords
passwd -d root
passwd -d linux
# empty password is ok
# pam-config -a --nullok

# chown -R linux:users /home/linux

sed -i s/#autologin-user=/autologin-user=linux/g  /etc/lightdm/lightdm.conf

#calamares installer
mkdir -p /home/linux/Desktop /home/root/.config/autostart
ln -s /usr/share/applications/install-debian.desktop /home/linux/Desktop/install-debian.desktop
mkdir -p /etc/xdg/autostart
ln -s /usr/share/applications/install-debian.desktop /etc/xdg/autostart/install-debian.desktop

# set language

sed -i "s/#zh_CN.UTF-8/zh_CN.UTF-8/g" /etc/locale.gen

cat > /etc/default/locale << EOF
LANG=zh_CN.UTF-8
LANGUAGE=zh_CN.UTF-8
EOF

# Re-generate localisation files.
/usr/sbin/locale-gen
touch -c /usr/share/applications/*

# add repo

# bug 544314, we only want to disable the bit in common-auth-pc
# sed -i -e 's,^\(.*pam_gnome_keyring.so.*\),#\1,'  /etc/pam.d/common-auth-pc

# ln -s /usr/lib/systemd/system/runlevel5.target /etc/systemd/system/default.target
# baseUpdateSysConfig /etc/sysconfig/displaymanager DISPLAYMANAGER_AUTOLOGIN linux
# baseUpdateSysConfig /etc/sysconfig/keyboard KEYTABLE us.map.gz
# baseUpdateSysConfig /etc/sysconfig/keyboard YAST_KEYBOARD "english-us,pc104"
# baseUpdateSysConfig /etc/sysconfig/keyboard COMPOSETABLE "clear latin1.add"

# baseUpdateSysConfig /etc/sysconfig/language RC_LANG "zh_CN.UTF-8"

# baseUpdateSysConfig /etc/sysconfig/console CONSOLE_FONT "eurlatgr.psfu"
# baseUpdateSysConfig /etc/sysconfig/console CONSOLE_SCREENMAP trivial
# baseUpdateSysConfig /etc/sysconfig/console CONSOLE_MAGIC "(K"
# baseUpdateSysConfig /etc/sysconfig/console CONSOLE_ENCODING "UTF-8"


###baseUpdateSysConfig /etc/sysconfig/windowmanager DEFAULT_WM gnome

#Disable journal write to disk in live mode, bug 950999
echo "Storage=volatile" >> /etc/systemd/journald.conf

#======================================
# Setup default target, multi-user
#--------------------------------------
baseSetRunlevel 5
