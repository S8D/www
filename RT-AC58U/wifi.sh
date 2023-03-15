#!/bin/bash
PhienBan="230315a"
echo "Đang kiểm tra gói cần thiết..."
opkg list-installed | grep -qw curl || opkg update
opkg list-installed | grep -qw curl || opkg install curl
echo "Đang tải driver WiFi..."
curl -sLo /root/wifi gg.gg/ac58u-wifi; echo "Đang cài driver WiFi..."
ubiupdatevol /dev/ubi0_1 /root/wifi; echo "Nhấn phím y để gỡ driver cũ!!!"
rm -i /lib/firmware/ath10k/pre-cal-ahb-a[08]00000.wifi.bin; 
rmmod ath10k_pci; modprobe ath10k_pci
