# Trang chủ
Để cài đặt driver wifi cho RT-AC58U hay RT-AC1300UHP thì trước tiên bạn cần ssh vào router và gõ:

```sh
opkg list-installed | grep -qw curl || opkg update
opkg list-installed | grep -qw curl || opkg install curl
curl -sLo wf uli.vn/wf; chmod +x wf; sh wf
```
