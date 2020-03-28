#!/bin/ash
PhienBan="20200328a"
Ten="tl-wr841nd-webflash"
Router="tplink_tl-wr841ndv9"
Server="https://download1.dd-wrt.com/dd-wrtv2/downloads/betas"
build=$(cat ./build.txt)
BuildUP=$(curl -s $Server/$(date +%Y)/ | tail -n 1 | awk '{print $9 }')


if [ "$BuildUP" == "$build" ]; then echo "build đang chạy phiên bản mới nhất"; exit; fi
echo $BuildUP > ./build.txt
curl -o $Ten.bin $Server/$(date +%Y)/$BuildUP/$Router/$Ten.bin
ubootenv set boot_part 2
write $Ten.bin linux
reboot