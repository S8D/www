#!/bin/bash
PhienBan="201203a"
GetTime=$(date +"%F %a %T"); Time="$GetTime -"; DauCau="#"
TM="/sd"; mkdir -p $TM; TMunb="${TM}/unb"; mkdir -p $TMunb
Log="${TMunb}/NhatKy.log"; if [ ! -f "$Log" ]; then echo '' > $Log; fi
upTam="${TMunb}/tam"; rm -f $upTam
DownURL="https://nlnetlabs.nl/downloads/unbound/unbound-latest.tar.gz"
#DownURL="https://github.com/NLnetLabs/unbound/archive/release-${PhienBanOn}.tar.gz"
up1="https://bom.to/_ub"
up2="https://tiny.cc/_ub"
up3="gg.gg/_ub"
up4="https://github.com/S8D/config/raw/master/UnBound/ub.sh"
dl1="https://bom.to/ub_"
dl2="https://tiny.cc/ub_"
dl3="gg.gg/ub_"
dl4="https://github.com/NLnetLabs/unbound/releases/latest"

DonDep () {
	echo "$DauCau Đang xóa các file tạm..."
	cd $TMunb; rm -rf $TMunb/unb.tar.gz $TMunb/unbound-*;
}

echo "$DauCau Đang kiểm tra máy chủ cập nhật..."
CheckNet_1 () { ping -q -c 1 -W 1 bom.to >/dev/null; };
CheckNet_2 () { ping -q -c 1 -W 1 tiny.cc >/dev/null; };
CheckNet_3 () { ping -q -c 1 -W 1 gg.gg >/dev/null; };
CheckNet_4 () { ping -q -c 1 -W 1 github.com >/dev/null; }; DonDep;
if CheckNet_1; then UpLink="${up1}"; DownLink="${dl1}"; net="1"; else
	if CheckNet_2; then UpLink="${up2}"; DownLink="${dl2}"; net="2"; else
		if CheckNet_3; then UpLink="${up3}"; DownLink="${dl3}"; net="3"; else
			if CheckNet_4; then UpLink="${up4}"; DownLink="${dl4}"; net="4"; else net=0;
			fi
		fi
	fi
fi

PhienBanUB () {
	PhienBanOff=$(unbound -V | grep Version | sed 's/Version //')
	PhienBanOn=$(curl -sL ${DownLink} | grep release- | cut -d\" -f4 | grep [0-9]$ | sed 's/.*\-//' | sed -n '1p')
}

KiemSH () {
	if [ $net -ge 1 ]; then echo "$DauCau Đang kiểm tra cập nhật $(basename "$0") $PhienBan...";
		PhienBanMoi=$(curl -sL "${UpLink}" | grep PhienBan\= | sed 's/.*\=\"//; s/\"$//');
		if [ $PhienBanMoi == $PhienBan ]; then echo "$DauCau $(basename "$0") $PhienBan là phiên bản mới nhất!"; else
			echo "$DauCau Đang cập nhật $(basename "$0") v.$PhienBan lên v.$PhienBanMoi...";
			cp $0 ${TMunb}/$PhienBan\_$(basename "$0"); curl -sLo $upTam $UpLink; chmod +x $upTam; 
			mv $upTam ${TMunb}/$(basename "$0"); echo "$Time $(basename "$0") được cập nhật lên $PhienBanMoi!" >> $Log;
			echo "$DauCau Khởi chạy $(basename "$0") $PhienBanMoi..."; sh ${TMunb}/$(basename "$0"); exit 1; fi
	fi
}

BuildUB () {
	echo -e "\n$DauCau Đang build UnBound ${PhienBanOn}...\n\n"
	cd ${TMunb}/unbound-*
	./configure --prefix=/usr --disable-static --enable-dnscrypt --enable-subnet --includedir=${prefix}/include --infodir=${prefix}/share/info --libdir=/usr/lib --localstatedir=/var --mandir=${prefix}/share/man --sysconfdir=/etc --with-libevent --with-pidfile=/run/unbound.pid --with-rootkey-file=/etc/unbound/root.key
	make && make install && clear
	echo -e "\n$DauCau Đang kiểm tra phiên bản UnBound...";PhienBanUB
	if [ $PhienBanOn == $PhienBanOff ]; then echo "$Time UnBound $PhienBanOn là bản mới nhất!" >> $Log;
		echo "$DauCau UnBound $PhienBanOn là bản mới nhất!"; exit 1; else
		echo "$DauCau Cập nhật UnBound thất bại!!!"; DonDep; exit 1; fi
}

KiemUB () {
	echo -e "\n$DauCau Đang kiểm tra phiên bản UnBound...";PhienBanUB
	if [ $PhienBanOn == $PhienBanOff ]; then echo "$Time UnBound $PhienBanOn là bản mới nhất!" >> $Log;
		echo "$DauCau UnBound $PhienBanOn là phiên bản mới nhất!"; exit 1; else
		echo "$DauCau Đang cập nhật UnBound v.$PhienBanOff lên v.$PhienBanOn...";
		echo "$DauCau Đang tải UnBound...";
		curl -sLo ${TMunb}/unb.tar.gz ${DownURL};
		echo -e "$DauCau Đang giải nén UnBound...";
		cd $TMunb; tar xzf unb.tar.gz;
		if [ ! -f ${TMunb}/unbound-*/LICENSE ]; then echo -e "\n$DauCau Giải nén thất bại!!! Thoát ra!"; DonDep; exit;
			else echo "$DauCau Giải thành công!!!"; BuildUB; fi;
	fi
}

KiemSH;KiemUB
