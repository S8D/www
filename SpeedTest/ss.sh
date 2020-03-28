#!/bin/bash
PhienBan="20200328a"
pem="/etc/ssl/cert.pem"; mkdir -p /etc/ssl
uPem="https://bom.to/pem"
u64="https://bom.to/sp64"
uArm="https://bom.to/sparm"
uAR="https://bom.to/sp64a"

if [ ! -f "$pem" ]; then echo "Đang tải chứng chỉ..."; curl -sLo $pem $uPem; fi

OS=`uname -m`; x64="x86_64"; arm="armv7l"; Android="aarch64"
if [ $OS == $x64 ]; then upem=$u64; sp="/usr/sbin/sp"; fi
if [ $OS == $arm ]; then upem=$uArm; if [ -d /www/cgi-bin ]; then sp="/usr/sbin/sp"; else sp="/opt/sbin/sp"; fi; fi
if [ $OS == $Android ]; then upem=$uAR; sp="/system/xbin/sp"; echo "OS: $OS | Android"; fi

if [ ! -f "$sp" ]; then echo "Đang tải SpeedTest..."; curl -sLo $sp $upem; chmod +x $sp; fi
#echo "Chưa hỗ trợ hệ thống bạn đang dùng"; exit 1

Giup ()
{
	echo ""
	echo "Cú pháp gõ:"
	printf '\t\t'; echo "$(basename "$0") [ -h | -s | -v ]"
	echo ""
	echo "Chức năng:"
	printf '\t\t'; echo -n "[ -h ]"; printf '\t'; echo "Hiện hướng dẫn sử dụng"
	printf '\t\t'; echo -n "[ -s ]"; printf '\t'; echo "Kiểm tra tốc độ mạng tới máy chủ Việt Nam"
	printf '\t\t'; echo -n "[ -v ]"; printf '\t'; echo "Kiểm tra tốc độ mạng tới máy chủ Việt Nam"
	echo ""
}

while getopts "h?sv" opt; do
	case ${opt} in
		h|\? ) Giup ;;
		s    ) echo "Kiểm tra tốc độ mạng tới máy chủ Singapore"; sp -B -s 9575 ;;
		v    ) echo "Kiểm tra tốc độ mạng tới máy chủ Việt Nam"; sp -B -s 6106 ;;
	\? ) exit 2 ;;
	esac
done
shift $((OPTIND-1))
echo "$(basename "$0") $PhienBan"; Giup