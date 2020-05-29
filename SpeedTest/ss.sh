#!/bin/bash
PhienBan="20200529d"
UpLink="https://bom.to/sss"
pem="/etc/ssl/cert.pem"; mkdir -p /etc/ssl
uPem="https://bom.to/pem"
u64="https://bom.to/sp64"
uArm="https://bom.to/sparm"
uAR="https://bom.to/sp64a"
umip="https://bom.to/spp"
SG="20637"
HK="33414"
DL="5334"
VN="6106"
GetTime=$(date +"%F %a %T"); Time="$GetTime -"; DauCau="#"

if [ ! -f "$pem" ]; then echo "Đang tải chứng chỉ..."; curl -sLo $pem $uPem; fi

OS=`uname -m`; x64="x86_64"; arm="armv7l"; Android="aarch64"; mip="mips"

if [ $OS == $x64 ] || [ $OS == $arm ] || [ $OS == $mip ]; then TM="/sd"; mkdir -p $TM; fi
if [ $OS == $Android ]; then TM="/sdcard"; mkdir -p $TM; fi
SP="$TM/sp"; mkdir -p $SP; upTam="$SP/tam"
if [ $OS == $x64 ]; then upem=$u64; sp="/usr/sbin/sp"; fi
if [ $OS == $arm ]; then upem=$uArm; if [ -d /www/cgi-bin ]; then sp="/usr/sbin/sp"; else sp="/opt/sbin/sp"; fi; fi
if [ $OS == $Android ]; then upem=$uAR; sp="/system/xbin/sp"; fi
if [ $OS == $mip ]; then upem=$umip; if [ -d /www/cgi-bin ]; then sp="/usr/sbin/sp"; fi; fi

if [ ! -f "$sp" ]; then echo "Đang tải SpeedTest..."; curl -sLo $sp $upem; chmod +x $sp; fi
if [ $OS != $x64 ] && [ $OS != $arm ] && [ $OS != $Android ] && [ $OS != $mip ]; then echo "Chưa hỗ trợ hệ thống bạn đang dùng"; exit 1; fi

Giup ()
{
	echo ""
	echo "Cú pháp:"
	printf '\t'; echo "$(basename "$0") [ -h | -a | -s | -k | -d | -v | -t [máy chủ] ]"
	echo ""
	echo "Chức năng:"
	printf '\t'; echo -n "[ -h ]"; printf '\t'; echo "Hiện hướng dẫn sử dụng"
	printf '\t'; echo -n "[ -a ]"; printf '\t'; echo "Kiểm tra tốc độ mạng tới tất cả máy chủ"
	printf '\t'; echo -n "[ -s ]"; printf '\t'; echo "Kiểm tra tốc độ mạng tới máy chủ Singapore"
	printf '\t'; echo -n "[ -k ]"; printf '\t'; echo "Kiểm tra tốc độ mạng tới máy chủ Hong Kong"
	printf '\t'; echo -n "[ -d ]"; printf '\t'; echo "Kiểm tra tốc độ mạng tới máy chủ Đài Loan"
	printf '\t'; echo -n "[ -v ]"; printf '\t'; echo "Kiểm tra tốc độ mạng tới máy chủ Việt Nam"
	printf '\t'; echo -n "[ -t ]"; printf '\t'; echo "Kiểm tra tốc độ mạng tới máy chủ tùy chọn"
	echo ""
}

while getopts "h?askdvt" opt; do echo ""
	case ${opt} in
		h|\? ) Giup ;;
		a    ) echo "Kiểm tra tốc độ mạng tới tất cả máy chủ"; if [ $OS == $mip ]; then echo -e "\nKiểm tra tốc độ mạng tới máy chủ Singapore"; sp --share --bytes --secure --server $SG; echo -e "\nKiểm tra tốc độ mạng tới máy chủ Hong Kong"; sp --share --bytes --secure --server $HK; echo -e "\nKiểm tra tốc độ mạng tới máy chủ Đài Loan"; sp --share --bytes --secure --server $DL; echo -e "\nKiểm tra tốc độ mạng tới máy chủ Việt Nam"; sp --share --bytes --secure --server $VN; else echo -e "\nKiểm tra tốc độ mạng tới máy chủ Singapore"; sp -B -s $SG; echo -e "\nKiểm tra tốc độ mạng tới máy chủ Hong Kong"; sp -B -s $HK; echo -e "\nKiểm tra tốc độ mạng tới máy chủ Đài Loan"; sp -B -s $DL; echo -e "\nKiểm tra tốc độ mạng tới máy chủ Việt Nam"; sp -B -s $VN; fi ;;
		s    ) echo "Kiểm tra tốc độ mạng tới máy chủ Singapore"; if [ $OS == $mip ]; then sp --share --bytes --secure --server $SG; else sp -B -s $SG; fi ;;
		k    ) echo "Kiểm tra tốc độ mạng tới máy chủ Hong Kong"; if [ $OS == $mip ]; then sp --share --bytes --secure --server $HK; else sp -B -s $HK; fi ;;
		d    ) echo "Kiểm tra tốc độ mạng tới máy chủ Đài Loan"; if [ $OS == $mip ]; then sp --share --bytes --secure --server $DL; else sp -B -s $DL; fi ;;
		v    ) echo "Kiểm tra tốc độ mạng tới máy chủ Việt Nam"; if [ $OS == $mip ]; then sp --share --bytes --secure --server $VN; else sp -B -s $VN; fi ;;
		t    ) echo -e "Kiểm tra tốc độ mạng tới máy chủ tùy chọn\n\nCụm máy chủ Singapore\n13623: Singtel | 2054: Viewqwest | 367: NewMedia Express | 4235: StarHub | 5935: MyRepublic | 7311: M1 Limited | 7556: FirstMedia | 20637: OVH Cloud | 5168: Indosat Tbk | 18791: FPT | 7368: Telematika | 28921: PhoenixNAP | 31795: Solone | 31180: Campana\n\nCụm máy chủ Hong Kong\n1536: STC | 22126: i3D.net | 2993: Website Solution | 26461: Telin | 28912: fdcservers.net | 32155: China Mobile | 19036: SmarTone | 33414: 3HK | 18745: FPT | 13538: CSL | 22991: Shanghai Huajuan | 16176: HGC Global | 14903: CSL\n\nCụm máy chủ Đài Loan\n8968: CNS | 4941: Chief | 18458: Chunghwa | 11713: Taiwan Mobile | 24377: CNS | 18607: Chunghwa | 4413: Chief | 19032: Friday Media | 4946: Chief | 18608: Chunghwa | 30349: PTC | 32319: TNIC | 4945: Chief | 18609: Chunghwa | 18480: Chief | 11699: Taiwan Mobile | 18478: Chief | 5164: Chief | 18611: Chunghwa | 29110: Asia Pacific | 30902: HTC-Edge | 17204: FarEasTone Telecom | 17189: FarEasTone Telecom | 32288: CRN | 4940: Chief | 6391: Asia University | 12000: TBC | 7076: Feng Chia | 7469: TINP | 18456: Chunghwa | 11707: Taiwan Mobile | 6597: Tunghai University | 18477: Chief | 27752: Asia Pacific | 17185: Far EasTone | 18449: Chunghwa | 2595: Far EasTone | 4948: Chief | 4939: Chief | 18450: Chunghwa | 29109: Asia Pacific | 17206: FarEasTone Telecom | 11702: Taiwan Mobile | 4938: Chief | 24462: CNS | 18452: Chunghwa | 29107: Asia Pacific | 5334: Star Telecom | 4505: Chief | 18447: Chunghwa | 24460: CNS | 19211: Friday Media | 29106: Asia Pacific | 18422: WiFly | 24461: CNS | 19102: Digicentre | 4947: Chief | 8630: SEEDNET | 18606: Chunghwa | 29108: Asia Pacific | 3967: Chief | 18445: Chunghwa | 2133: Taiwan Fixed | 7429: Taipeinet | 24429: CNS | 2181: kbro | 18421: WiFly | 30059: Star Telecom | 30370: Pikachu_Qserver | 14036: Kbro | 13506: TAIFO Taiwan | 29716: CNS | 18475: Chief | 17205: FarEasTone Telecom | 24974: CNS\nCụm máy chủ VietNam\n6106: VNPT-NET | 18250: CMC | 8158: VTC | 26853: Viettel | 24232: TPCOMS | 2515: FPT | 22708: DCNET | 8491: SCTV | 3381: NetNam | 9668: Supernet | 16749: Vietnamobile | 27601: Viettel | 13373: SPT4 | 30149: Cloudzone | 6102: VNPT-NET | 19294: PowerNet | 10040: Viettel | 16873: Vietnamobile | 19060: VIETPN.COM | 27630: Viettel | 6085: VNPT-NET | 9903: Viettel | 6342: CMC | 2552: FPT | 9174: MOBIFONE | 8156: VTC | 16416: Vietnamobile | 10308: Supernet-hanoi | 5774: NetNam"; 
		echo -en "Nhập ID máy chủ: "; read -r t; if [ $OS == $mip ]; then sp --share --bytes --secure --server $t; else sp -B -s $t; fi ;;		
	\? ) exit 2 ;;
	esac
done
shift $((OPTIND-1))
echo ""
echo "$DauCau Đang kiểm tra cập nhật $(basename "$0") $PhienBan..."
PhienBanMoi=$(curl -sL "${UpLink}" | grep PhienBan\= | sed 's/.*\=\"//; s/\"$//');
if [ $PhienBanMoi == $PhienBan ]; then echo "$DauCau $(basename "$0") $PhienBan là bản mới nhất!";        
else echo "$DauCau Đang cập nhật $(basename "$0") v.$PhienBan lên v.$PhienBanMoi...";
	cp $0 ${SP}/$PhienBan\_$(basename "$0")
	curl -sLo $upTam $UpLink; chmod +x $upTam; cp $upTam ${TM}/$(basename "$0"); rm -rf $upTam
	echo "$DauCau Khởi chạy $(basename "$0") $PhienBanMoi..."; sh ${TM}/$(basename "$0"); exit 1; fi;
Giup
