#!/bin/bash
PhienBan="20200307b"
opkg list-installed | grep -qw curl || opkg update
opkg list-installed | grep -qw curl || opkg install curl

curl -sLo /root/wifi https://s8d.github.io/config/RT-AC58U/wifi; 
ubiupdatevol /dev/ubi0_1 /root/wifi; 
rm -i /lib/firmware/ath10k/pre-cal-ahb-a[08]00000.wifi.bin; 
rmmod ath10k_pci; modprobe ath10k_pci
