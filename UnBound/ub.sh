#!/bin/bash
PhienBan="201011a"
GetTime=$(date +"%F %a %T"); Time="$GetTime -"; DauCau="#"
TM="/sd/"; TMunb="${TM}/unb";
Log="${TMunb}/NhatKy.log"; if [ ! -f "$Log" ]; then echo '' > $Log; fi
clear; echo -e "\n$DauCau Đang kiểm tra phiên bản...";
PhienBanOff=$(unbound -V | grep Version | sed 's/Version //')
PhienBanOn=$(curl -sL https://github.com/NLnetLabs/unbound/releases/latest | grep release- | cut -d\" -f4 | grep [0-9]$ | sed 's/.*\-//' | sed -n '1p')
DownURL="https://github.com/NLnetLabs/unbound/archive/release-${PhienBanOn}.tar.gz"
UpLink="https://github.com/S8D/config/raw/master/UnBound/ub"
upTam="${TMunb}/tam"; rm -f $upTam;
DonDep () {
	echo -e "\n$DauCau Đang xóa các file tạm..."
	cd $TMunb; rm -rf $TMunb/unb.tar.gz $TMunb/unbound-*;
	echo "$DauCau Bạn có thể xem thêm nhật ký chạy lệnh tại:\n${Log}"
}	

BuildUB () {
	echo -e "\n$DauCau Đang build UnBound ${PhienBanOn}...\n\n"
	cd ${TMunb}/unbound-*
	./configure --prefix=/usr --disable-static --enable-dnscrypt --enable-subnet --includedir=${prefix}/include --infodir=${prefix}/share/info --libdir=/usr/lib --localstatedir=/var --mandir=${prefix}/share/man --sysconfdir=/etc --with-libevent --with-pidfile=/run/unbound.pid --with-rootkey-file=/etc/unbound/root.key
	make && make install && clear
	echo -e "\n$DauCau Đang kiểm tra phiên bản...";
	if [ $PhienBanOn == $PhienBanOff ]; then echo "$Time UnBound $PhienBanOn là bản mới nhất!" >> $Log;
		echo "$DauCau UnBound $PhienBanOn là bản mới nhất!"; exit 1; else
		echo "$DauCau Cập nhật UnBound thất bại!!!"; DonDep; exit 1; fi
}

KiemUB () {
	if [ $PhienBanOn == $PhienBanOff ]; then echo "$Time UnBound $PhienBanOn là bản mới nhất!" >> $Log;
		echo "$DauCau UnBound $PhienBanOn là bản mới nhất!"; exit 1; else
		echo "$DauCau Đang cập nhật UnBound v.$PhienBanOff lên v.$PhienBanOn..."
		echo "$DauCau Đang tải UnBound..."
		curl -sLo ${TMunb}/unb.tar.gz ${DownURL};	
		echo -e "$DauCau Đang giải nén UnBound..."; 
		cd $TMunb; tar xzf unb.tar.gz
		if [ ! -f ${TMunb}/unbound-*/LICENSE ]; then echo -e "\n$DauCau Giải nén thất bại!!! Thoát ra!"; DonDep; exit; 
			else echo "$DauCau Giải thành công!!!"; BuildUB
		fi
		
	fi
}

KiemSH () {
	if [ $net -ge 1 ]; then echo "$DauCau Đang kiểm tra cập nhật $(basename "$0") $PhienBan..."
	PhienBanMoi=$(curl -sL "${UpLink}" | grep PhienBan\= | sed 's/.*\=\"//; s/\"$//');
	if [ $PhienBanMoi == $PhienBan ]; then echo "$DauCau $(basename "$0") $PhienBan là bản mới nhất!";
	else echo "$DauCau Đang cập nhật $(basename "$0") v.$PhienBan lên v.$PhienBanMoi...";
		cp $0 ${TMunb}/$PhienBan\_$(basename "$0")
		curl -sLo $upTam $UpLink; chmod +x $upTam; mv $upTam ${TMunb}/$0
		echo "$Time $(basename "$0") được cập nhật lên $PhienBanMoi!"  >> $Log
		echo "$DauCau Khởi chạy $(basename "$0") $PhienBanMoi..."; 
		sh ${TMunb}/$(basename "$0")
	fi
}

KiemSH
KiemUB
