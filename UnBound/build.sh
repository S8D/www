#!/bin/bash
PhhienBan="2001029a"

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
dl="curl -sLo"

apt update; apt install -y curl gcc ldnsutils libevent-dev libexpat1-dev libssl-dev
groupdel unbound; groupadd -g 991 unbound
useradd -c "unbound" -d /var/lib/unbound -u 991 -g unbound -s /bin/false unbound
$dl $TM/unb.tar.gz $UB_u
tar xzf unb.tar.gz; cd unbound-*
./configure --prefix=/usr --disable-static --enable-dnscrypt --enable-subnet --includedir=${prefix}/include --infodir=${prefix}/share/info --libdir=/usr/lib --localstatedir=/var --mandir=${prefix}/share/man --sysconfdir=/etc --with-libevent --with-pidfile=/run/unbound.pid --with-rootkey-file=$UB/root.key
make && make install && unbound -V
$dl /lib/systemd/system/unbound.service $DichVu
systemctl unmask unbound.service
systemctl enable unbound.service

cat > $UB/root.trust << \EOF
. IN DS 20326 8 2 E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D
EOF
mkdir -p $UB/unbound.conf.d
echo -e 'include: "/etc/unbound/unbound.conf.d/*.conf"' >> $UB/unbound.conf
$dl $UB/unbound.conf.d/pi-hole.conf ${CauHinh}
$dl $UB/icannbundle.pem $Pem
unbound-anchor -c $UB/icannbundle.pem -a $UB/root.key -v
mkdir -p $UB/root-anchors
$dl $UB/root.hints $NRoot
$dl $UB/root-anchors/root-anchors.p7s $p7s
$dl $UB/root-anchors/root-anchors.xml $xml
$dl $UB/root.zone $RZone
$dl $UB/root-servers.net.zone $SZone
unbound-checkconf
service unbound start && service unbound status
lsof -i -P -n | grep LISTEN
dig @127.0.2.2 -p 2222 t.co
