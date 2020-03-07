#!/bin/bash
PhienBan="20200307c"
opkg list-installed | grep -qw curl || opkg update
opkg list-installed | grep -qw curl || opkg install curl
echo "Downloading WiFi driver"
curl -sLo /root/wifi uli.vn/wifi; echo "Installing WiFi driver"
ubiupdatevol /dev/ubi0_1 /root/wifi; echo "Press y to remove old driver"
rm -i /lib/firmware/ath10k/pre-cal-ahb-a[08]00000.wifi.bin; 
rmmod ath10k_pci; modprobe ath10k_pci
