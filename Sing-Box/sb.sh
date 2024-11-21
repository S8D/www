#!/bin/bash
PhienBan="241121d"
TMPC="/sd/Data/00_TongHop/TVBox/sd/sb"
backup="$TM/old"; if [ ! -d "$backup" ]; then mkdir -p $backup; fi
if [ -d "$TMPC" ]; then TM="$TMPC"; elif [ -d "/sd/sb" ]; then TM="/sd/sb"; fi; 

GetTime=$(date +"%F %a %T"); Time="$GetTime -"; DauCau="#"
Log="${TM}/Update.log"; if [ ! -f "$Log" ]; then echo '' > $Log; fi;

if [ "$(uname -m)" == "x86_64" ]; then arch="amd64" ; 
elif [ "$(uname -m)" == "aarch64" ]; then arch="arm64"; 
elif [ "$(uname -m)" == "armv7l" ]; then arch="armv7"; 
else echo "Tạm thời scripts chưa hỗ trợ cài đặt Sing-Box trên các nền tảng khác"; exit
fi

url="https://api.github.com/repos/SagerNet/sing-box/releases"
echo -e "Scripts cài đặt Sing-Box $PhienBan\nĐang lấy thông tin phiên bản..."
OnDinh=$(curl -s "$url/latest" | awk -F '"' '/tag_name/{print $4}')
TienOnDinh=$(curl -s "$url" | jq -r 'map(select(.prerelease)) | .[0].tag_name')
echo -e "Phiên bản ổn định: $OnDinh\nPhiên bản thử nghiệm $TienOnDinh"

if [ "$1" == "ondinh" ]; then PhienBanSB=$OnDinh
elif [ "$1" == "beta" ]; then PhienBanSB=$TienOnDinh
else echo -e "\n\nVui lòng chọn phiên bản ổn định với tham số ondinh\nPhiên bản thử nghiệm với tham số beta\n\n"; exit; fi

#which apt >/dev/null 2>&1; if [ $? -eq 0 ]; then duoi=".deb"; fi
#which pacman >/dev/null 2>&1; if [ $? -eq 0 ]; then duoi=".pkg.tar.zst"; fi
#which rpm >/dev/null 2>&1; if [ $? -eq 0 ]; then duoi=".rpm"; fi
#echo -e "Đang tải Sing-Box $PhienBanSB..."
#curl -sLo $TM/$PhienBanSB$(echo _)$arch$duoi $(curl -s "$url" | grep "browser_download_url" | grep "linux_$arch" | grep "$duoi" | sed 's/.*\"\: \"//g; s/"//g' | grep "$PhienBanSB")

TaiXuong () { duoi=".tar.gz"
  sbFile="$TM/$PhienBanSB$(echo _)$arch$duoi"
  if [ ! -f "$sbFile" ]; then echo -e "Đang tải Sing-Box $PhienBanSB..."
    curl -sLo $sbFile $(curl -s "$url" | grep "browser_download_url" | grep "linux-$arch" | sed 's/.*\"\: \"//g; s/"//g' | grep "$PhienBanSB")
  fi
  if [ "$(($(stat -c%s "$sbFile") / 1048576))" -ge "5" ]; then 
    echo -e "Đang giải nén Sing-Box $PhienBanSB..."
    cd "$TM"; tar xvf "$sbFile"
  fi

  mv sing-box-*$arch/sing-box "$TM/sb"; rm -rf sing-box-*$arch
  mv "$sbFile" "$backup"
}

TaoDichVu () {
  cat > $TM/sb.service << \EOF
[Unit]
Description=Dịch vụ Sing-Box
Documentation=https://sing-box.sagernet.org
After=network.target nss-lookup.target network-online.target

[Service]
ExecStart=/sd/sb/sb -D /sd/sb/data -C /sd/sb/data run
ExecReload=/bin/kill -HUP $MAINPID
Restart=on-failure
RestartSec=10s
LimitNOFILE=infinity

[Install]
WantedBy=multi-user.target

EOF
}

which sb >/dev/null 2>&1; if [ $? -eq 0 ]; then PhienBanOff=$(sb version | grep "sing-box " | sed 's/.*version /v/g')
  echo "Tìm thấy Sing-Box $PhienBanOff trong hệ thống!"; 
  if [ ! "$PhienBanOff" == "$PhienBanSB" ]; then echo "Đang cập nhật Sing-Box $PhienBanOff lên phiên bản $PhienBanSB..."; TaiXuong $1
    PhienBanOff=$(sb version | grep "sing-box " | sed 's/.*version /v/g')
    if [ "$PhienBanOff" == "$PhienBanSB" ]; then echo -e "Cập nhật thành công Sing-Box lên phiên bản $PhienBanOff\nKhởi động lại dịch vụ Sing-Box..."
      systemctl restart sb
    fi
  else 
    if [ "$1" == "ondinh" ]; then PhienBanCai="ổn định"
    elif [ "$1" == "beta" ]; then PhienBanCai="thử nghiệm"
    fi
    echo -e "Sing-Box $PhienBanOff là phiên bản $PhienBanCai mới nhất!"; 
  fi
else 
  echo -e "Không tìm thấy Sing-Box trên hệ thống!!!!\nĐang tiến hành cài Sing-Box $PhienBanSB..."; TaiXuong $1
  if [ ! -f "/etc/systemd/system/sb.service" ]; then 
    if [ ! -f "$TM/sb.service" ]; then TaoDichVu; fi
    ln -s /sd/sb/sb.service /etc/systemd/system/sb.service
  fi
  if [ ! -f "/usr/sbin/sb" ]; then echo "y" | rm -i /usr/sbin/sb
    ln -s /sd/sb/sb /usr/sbin/sb
  fi
  systemctl status sb
  which sb >/dev/null 2>&1; if [ $? -eq 0 ]; then sb version; sb -C /sd/sb/data check; fi
fi
