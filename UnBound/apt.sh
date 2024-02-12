#!/bin/bash
PhienBan="220924"

CauHinh="https://s8d.github.io/config/UnBound/CauHinh.conf"
DichVu="https://s8d.github.io/config/UnBound/DichVu"
NRoot="https://www.internic.net/domain/named.root"
Pem="https://data.iana.org/root-anchors/icannbundle.pem"
p7s="https://data.iana.org/root-anchors/root-anchors.p7s"
xml="https://data.iana.org/root-anchors/root-anchors.xml"
SZone="https://www.internic.net/domain/root-servers.net.zone"
RZone="https://www.internic.net/domain/root.zone"
mkdir -p /sd; 
TM="/sd/unb"; mkdir -p $TM; cd $TM
UB="/etc/unbound"
dl="curl -sLo"
goi="/usr/sbin"

which unbound >/dev/null 2>&1; if [ $? -eq 0 ]; then echo -e "UnBound đã được cài đặt trong hệ thống! Đang tiến hành gỡ bỏ...\n"
	apt remove unbound -y; rm -rf /etc/unbound /etc/init.d/unbound /etc/insserv.conf.d/unbound /etc/resolvconf/update.d/unbound; echo ''; fi

echo -e "Đang cài UnBound và các gói cần thiết...\n"
which apt >/dev/null 2>&1; if [ $? -eq 0 ]; then apt update; apt install -y curl dnsutils unbound unbound-anchor lsof lighttpd-mod-openssl; fi

echo -e "Đang kiểm tra UnBound trong hệ thống...\n"
$goi/unbound -V >/dev/null 2>&1 || { echo "Cài đặt UnBound thất bại!!! Đang thoát" >&2; exit 1; }
$goi/unbound -V
$dl /lib/systemd/system/unbound.service $DichVu
systemctl unmask unbound.service
systemctl enable unbound.service

echo -e "Đang cấu hình UnBound...\n"
key=$(unbound -V | grep rootkey | sed 's/.*rootkey\-file\=//; s/ .*//')
echo "Key: $key"
key="$UB/root.key"
cat > $UB/root.trust << \EOF
. IN DS 20326 8 2 E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D
EOF
mkdir -p $UB/unbound.conf.d
echo -e 'include: "/etc/unbound/unbound.conf.d/*.conf"' >> $UB/unbound.conf

echo -e "Đang tải file cấu hình UnBound...\n"
rm -rf $UB/unbound.conf.d/*.conf
$dl $UB/unbound.conf.d/pi-hole.conf ${CauHinh}
$dl $UB/icannbundle.pem $Pem
$goi/unbound-anchor -c $UB/icannbundle.pem -a $key -v
mkdir -p $UB/root-anchors
$dl $UB/root.hints $NRoot
$dl $UB/root-anchors/root-anchors.p7s $p7s
$dl $UB/root-anchors/root-anchors.xml $xml
$dl $UB/root.zone $RZone
$dl $UB/root-servers.net.zone $SZone

echo "Đang kiểm tra các khóa xác thực và trạng thái truy vấn"
TrangThai=$($goi/unbound-anchor -c $UB/icannbundle.pem -a $key -v | grep anchor | sed 's/\:.*//')
if [ $TrangThai == "fail" ]; then echo  -e "\nHệ thống của bạn đang chuyển tiếp hoặc chuyển hướng cổng 53!!!\nVui lòng cho phép truy vấn trực tiếp từ thiết bị này!\n"; fi
echo -e "Kiểm tra cấu hình UnBound\n"
$goi/unbound-checkconf

echo -e "Chạy dịch vụ UnBound\n"
$goi/service unbound restart

echo -e "Kiểm tra cổng đang chạy\n"
lsof -i -P -n | grep LISTEN

echo -e "Kiểm tra truy vấn\n"
dig @127.0.2.2 -p 2222 t.co

echo -e "Kiểm tra dịch vụ UnBound\n"
$goi/service unbound status
