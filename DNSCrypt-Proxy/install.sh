#!/bin/bash
PhienBan="220530"

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
cauhinh_null="${Home}/cauhinh_null.tar.gz"
dl1="curl -sLo"; dl2="curl -sL"


$dl1 $TM/cauhinh.toml $CauHinh
$dl1 $TM/dns.service $DichVu
$dl1 $TM/cauhinh.tar.gz $cauhinh_null
tar zxf cauhinh.tar.gz
PhienBanOn=$(${dl2} "${DownLink}" | awk -F '"' '/tag_name/{print $4}')
PhienBanOff=$(dns --version)
DownURL=$(${dl2} $DownLink | grep browser_download_url.*tar.gz | grep $linktai | sed 's/.*minisig//' | cut -d '"' -f 4);

echo "Đang tải DNSCrypt-Proxy..."; $dl1 $TM/dns.tar.gz $DownURL
echo "Đang giải nén DNSCrypt-Proxy..."; tar zxf dns.tar.gz
echo "Đang sắp xếp lại thư mục DNSCrypt-Proxy..."
mv linux*/* ./
rm -rf linux*
mv dnscrypt-proxy dns
ln -s /sd/dns/dns /usr/sbin/dns
ln -s /sd/dns/cauhinh.toml /sd/dns/dnscrypt-proxy.toml

if [ -d /www/luci-static ]; then echo "Cài dịch vụ DNSCrypt-Proxy cho OpenWRT"; 
	$dl1 $TM/dv ${Home}/dv.sh; chmod +x /sd/dns/dv; ln -s /sd/dns/dv /etc/init.d/dns; 
	service dns enable; service dns start; service dns status
else 
	echo "Cài dịch vụ DNSCrypt-Proxy cho Linux"
	dns -service install
	mv /etc/systemd/system/dnscrypt-proxy.service /sd/dns/dns.service
	ln -s /sd/dns/dns.service /etc/systemd/system/dnscrypt-proxy.service
	dns -service start
	service dnscrypt-proxy status
fi

echo "Kiểm tra Nhật ký chạy DNSCrypt-Proxy"
cat /sd/dns/NhatKy.log

IP=$(lsof -i -P -n | grep LISTEN | grep "dns " | sed 's/.*127/127/; s/\:.*//')
Port=$(lsof -i -P -n | grep LISTEN | grep "dns " | sed 's/.*\://; s/ .*//')
dig @$IP -p $Port t.co
echo "Bạn kiểm tra lại file cấu hình IP và cổng chạy DNSCrypt-Proxy xem có phù hợp chưa nhé!"
cat $TM/cauhinh.toml | grep ^listen_addresses
echo "Để chỉnh sửa nội dung file cấu hình cho phù hợp, bạn có thể dùng lệnh: nano /sd/dns/cauhinh.toml"