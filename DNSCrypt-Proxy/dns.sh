#!/bin/bash
PhienBan="201029a"

OS=`uname -m`; x64="x86_64"; arm="armv7l"; arm64="aarch64"; mips="mips"
if [ $OS == $x64 ]; then linktai="x86_64"; fi
if [ $OS == $arm ]; then linktai="arm"; fi
if [ $OS == $arm64 ]; then linktai="arm64"; fi
if [ $OS == $mips ]; then linktai="mipsle"; fi

mkdir -p /sd; 
TM="/sd/dns"; mkdir -p ${TM}; cd ${TM}
DownLink="https://api.github.com/repos/DNSCrypt/dnscrypt-proxy/releases/latest"
Home="https://s8d.github.io/config/DNSCrypt-Proxy"
CauHinh="${Home}/cauhinh.toml"
DichVu="${Home}/dns.service"
CauHinh_Null="${Home}/CauHinh_Null.tar.gz"
dl1="curl -sLo"; dl2="curl -sL"

$dl1 $Home/cauhinh.toml $CauHinh
$dl1 $Home/dns.service $DichVu
$dl1 $Home/cauhinh.tar.gz $CauHinh_Null
tar zxf cauhinh.tar.gz
PhienBanOn=$(${dl2} "${DownLink}" | awk -F '"' '/tag_name/{print $4}')
PhienBanOff=$(dns --version)
DownURL=$(${dl2} $DownLink | grep browser_download_url.*tar.gz | grep $linktai | sed 's/.*minisig//' | cut -d '"' -f 4);

$dl1 dns.tar.gz $DownURL
tar zxf dns.tar.gz
mv linux*/* ./
rm -rf linux*
mv dnscrypt-proxy dns
ln -s /sd/dns/dns /usr/sbin/dns
ln -s /sd/dns/cauhinh.toml /sd/dns/dnscrypt-proxy.toml
dns -service install
mv /etc/systemd/system/dnscrypt-proxy.service /sd/dns/dns.service
ln -s /sd/dns/dns.service /etc/systemd/system/dnscrypt-proxy.service
dns -service start
service dnscrypt-proxy status
lsof -i -P -n | grep LISTEN
dig @127.0.1.1 -p 1111 t.co
