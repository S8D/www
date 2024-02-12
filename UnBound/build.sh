#!/bin/bash
PhienBan="240212a"

# Cài đặt màu sắc
MauDo="\e[31m"
MauVang="\e[33m"
MauXanh="\e[32m"
MauXam="\e[0m"

# Đánh dấu màu
TgTT=$(echo -e "[i]") # [i] Information
TgCB=$(echo -e "[${MauVang}w${MauXam}]") # [w] Warning
TgNG=$(echo -e "[${MauDo}✗${MauXam}]") # [✗] Error
TgOK=$(echo -e "[${MauXanh}✓${MauXam}]") # [✓] Ok


unb_down="https://api.github.com/repos/NLnetLabs/unbound/tags"
CauHinh="https://s8d.github.io/config/UnBound/CauHinh.conf"
DichVu="https://s8d.github.io/config/UnBound/DichVu"
UB_u="https://www.nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz"
NRoot="https://www.internic.net/domain/named.root"
Pem="https://data.iana.org/root-anchors/icannbundle.pem"
p7s="https://data.iana.org/root-anchors/root-anchors.p7s"
xml="https://data.iana.org/root-anchors/root-anchors.xml"
SZone="https://www.internic.net/domain/root-servers.net.zone"
RZone="https://www.internic.net/domain/root.zone"
mkdir -p /sd; 
TM="/sd/unb"; mkdir -p $TM; cd $TM
UB="/etc/unbound"
dl1="curl -sLo"; dl2="curl -sL"
GetTime=$(date +"%F %a %T"); Time="$GetTime -"; DauCau="#"
echo -e "${TgTT}$MauXam Đang cài$MauXanh các gói cần thiết$MauXam..."
apt update; 
DSGoi="curl lsof jq gcc dnsutils ldnsutils libevent-dev libexpat1-dev libssl-dev libsodium-dev build-essential flex bison"
for pkg in $DSGoi; do if [ -z "$(dpkg -s $pkg | grep Version | sed 's/.*\: //g')" ]; then 
	echo -e "${TgTT}$MauXam Đang cài $MauVang$pkg$MauXam..."
	apt install -y $pkg; fi; 
done
if [ ! -z "$(cat /etc/shadow | grep unbound)" ]; then sudo groupdel unbound; fi
sudo groupadd -g 2222 unbound
sudo useradd -c "unbound" -d /var/lib/unbound -u 2222 -g unbound -s /bin/false unbound

unb_On=$(${dl2} "${unb_down}" | jq -r '.[0].name' | sed 's/.*\-//')
echo -e "${TgTT}$MauXam Đang$MauVang tải UnBound $MauXanh$unb_On$MauXam..."
DownURL="https://github.com/NLnetLabs/unbound/archive/refs/tags/release-$unb_On.tar.gz"
$dl1 $TM/$unb_On.tar.gz $DownURL; cd $TM
echo -e "${TgTT}$MauXam Đang$MauVang giải nén UnBound $MauXanh$unb_On$MauXam..."
tar xzf $TM/$unb_On.tar.gz; 
cd unbound-*
if [ -z "$(ls $TM/unbound-release-* | grep configure)" ]; then
	echo -e "${TgNG}$MauXam Giải nén$MauDo UnBound thất bại!!!$MauXam"; exit 1; 
fi
#$dl1 $TM/unb.tar.gz $UB_u; tar xzf unb.tar.gz; cd $TM/unbound-*
echo -e "${TgTT}$MauXam Đang$MauVang build UnBound $MauXanh$unb_On$MauXam..."
./configure --prefix=/usr --disable-static --enable-dnscrypt --enable-subnet --includedir=${prefix}/include --infodir=${prefix}/share/info --libdir=/usr/lib --localstatedir=/var --mandir=${prefix}/share/man --sysconfdir=/etc --with-libevent --with-pidfile=/run/unbound.pid --with-rootkey-file=$UB/root.key
make && make install
command -v unbound >/dev/null 2>&1 || { echo -e "${TgNG}$MauDo Build UnBound thất bại!!!$MauXam..." >&2; exit 1; }
unbound -V

echo -e "${TgTT}$MauXam Đang$MauVang cấu hình dịch vụ UnBound$MauXam..."
$dl1 /lib/systemd/system/unbound.service $DichVu
systemctl unmask unbound.service
systemctl enable unbound.service

echo -e "${TgTT}$MauXam Đang$MauVang cấu hình UnBound $MauXam..."
cat > $UB/root.trust << \EOF
. IN DS 20326 8 2 E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D
EOF
mkdir -p $UB/unbound.conf.d
echo -e 'include: "/etc/unbound/unbound.conf.d/*.conf"' >> $UB/unbound.conf
rm -rf $UB/unbound.conf.d/*.conf
$dl1 $UB/unbound.conf.d/pi-hole.conf ${CauHinh}
$dl1 $UB/icannbundle.pem $Pem
unbound-anchor -c $UB/icannbundle.pem -a $UB/root.key -v
mkdir -p $UB/root-anchors
$dl1 $UB/root.hints $NRoot
$dl1 $UB/root-anchors/root-anchors.p7s $p7s
$dl1 $UB/root-anchors/root-anchors.xml $xml
$dl1 $UB/root.zone $RZone
$dl1 $UB/root-servers.net.zone $SZone
unbound-checkconf
service unbound start && service unbound status
lsof -i -P -n | grep LISTEN
dig @127.0.2.2 -p 2222 t.co
