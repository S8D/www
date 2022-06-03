PhienBan=220603c

dl="curl -sLo"
UB="/etc/unbound"
CauHinh="https://s8d.github.io/config/UnBound/CauHinh.conf"
NRoot="https://www.internic.net/domain/named.root"
Pem="https://data.iana.org/root-anchors/icannbundle.pem"
p7s="https://data.iana.org/root-anchors/root-anchors.p7s"
xml="https://data.iana.org/root-anchors/root-anchors.xml"
SZone="https://www.internic.net/domain/root-servers.net.zone"
RZone="https://www.internic.net/domain/root.zone"

echo "Phiên bản Cài đặt UnBound tự động $PhienBan"
which pacman >/dev/null 2>&1; if [ $? -eq 0 ]; then 
yes | pacman -Suy curl unbound lsof bind-tools; fi
which apk >/dev/null 2>&1; if [ $? -eq 0 ]; then 
apk add curl unbound lsof bind-tools; fi
which apt >/dev/null 2>&1; if [ $? -eq 0 ]; then 
apt install -y curl unbound lsof bind-tools; fi
which opkg >/dev/null 2>&1; if [ $? -eq 0 ]; then 
opkg update; opkg install curl lsof bind-tools unbound-anchor unbound-checkconf luci-i18n-unbound-en luci-i18n-unbound-vi; 
fi

rm -rf $UB
cat > $UB/root.trust << \EOF
. IN DS 20326 8 2 E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D
EOF
mkdir -p $UB/unbound.conf.d
echo -e 'include: "/etc/unbound/unbound.conf.d/*.conf"' >> $UB/unbound.conf
$dl $UB/unbound.conf.d/pi-hole.conf ${CauHinh}
$dl $UB/icannbundle.pem $Pem
unbound-anchor -c $UB/icannbundle.pem -a $UB/trusted-key.key -v
mkdir -p $UB/root-anchors
$dl $UB/root.hints $NRoot
$dl $UB/root-anchors/root-anchors.p7s $p7s
$dl $UB/root-anchors/root-anchors.xml $xml
$dl $UB/root.zone $RZone
$dl $UB/root-servers.net.zone $SZone
unbound-checkconf

which pacman >/dev/null 2>&1; if [ $? -eq 0 ]; then 
	systemctl enable unbound
	systemctl start unbound
	systemctl status unbound
fi

which apk >/dev/null 2>&1; if [ $? -eq 0 ]; then 
	/etc/init.d/unbound enable
	/etc/init.d/unbound start
	/etc/init.d/unbound status
fi

which apt >/dev/null 2>&1; if [ $? -eq 0 ]; then 
	systemctl enable unbound
	service unbound start
	service unbound status
fi

which opkg >/dev/null 2>&1; if [ $? -eq 0 ]; then 
	/etc/init.d/unbound enable
	/etc/init.d/unbound start
	/etc/init.d/unbound status
fi

/etc/unbound/trusted-key.key

lsof -i -P -n | grep LISTEN
dig @127.0.2.2 -p 2222 t.co
