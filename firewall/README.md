# 🏛️ TRUNG TÂM TÀI LIỆU & LỘ TRÌNH ĐÀO TẠO MẠNG — TƯỜNG LỬA FORTIGATE VINATECH
> **Bộ Giáo Trình & Hồ Sơ Kỹ Thuật Độc Quyền (Master Suite 2026)**  
> **Dành cho:** Người mới bắt đầu từ con số 0 đến khi làm chủ toàn diện hệ thống hạ tầng mạng và an ninh của 4 cơ sở Vinatech.

---

## 📚 TRỌN BỘ 5 TẬP GIÁO TRÌNH & HỒ SƠ THỰC CHIẾN

Toàn bộ hệ thống kiến thức đã được biên soạn công phu, chuẩn hóa theo giáo trình quốc tế (CompTIA Network+, Cisco CCNA, Fortinet FCP) và gắn chặt với thực tế nhà máy sản xuất của Vinatech:

```
c:\Users\User Vinatech.DESKTOP-RJJSEQU\Desktop\firewall\
 ├── 📘 01_GIAO_TRINH_NEN_TANG_NETWORK_SYSTEM.md        --> [Tập 1: Nền tảng Mạng & Hệ thống từ số 0]
 ├── 📙 02_CAM_NANG_CHUYEN_SAU_FORTIGATE_FORTIOS.md       --> [Tập 2: Cẩm nang chuyên sâu FortiGate FortiOS]
 ├── 📕 03_HO_SO_THUC_TE_4_NHA_MAY_VINATECH.md           --> [Tập 3: Hồ sơ kỹ thuật thực tế 4 nhà máy & Audit]
 ├── 📗 04_SO_TAY_XU_LY_SU_CO_THUC_CHIEN_TROUBLESHOOTING.md --> [Tập 4: Sổ tay xử lý 12 kịch bản sự cố thực chiến]
 └── 🔬 05_THUC_CHIEN_GIAI_PHAU_MANG_HIEN_TAI_CUA_BAN.md --> [Tập 5: Thực chiến giải phẫu mạng chiếc máy bạn đang ngồi]
```

### 1. [Tập 1: Giáo trình Nền tảng Mạng & Hệ thống Doanh nghiệp](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/01_GIAO_TRINH_NEN_TANG_NETWORK_SYSTEM.md)
* **Đối tượng:** Dành cho người chưa biết gì về mạng & hệ thống máy tính.
* **Nội dung:** Mô hình OSI 7 tầng; Bản chất gói tin (Packet); Địa chỉ vật lý MAC & ARP; Cấu trúc địa chỉ IPv4; Giải mã dải mạng Subnet `/21` (`255.255.248.0` chứa hơn 2.000 máy tính); So sánh TCP vs UDP; Danh bạ các cổng dịch vụ thực tế của Vinatech (Port 4443, 8601 MES, 5398 MSSQL, 9952 NAIS, 9100 Zebra RAW, 445 SMB, 8000 NVR); Bộ ba dịch vụ mạng (DHCP, DNS, Default Gateway `192.168.184.1`); Chuyển mạch VLAN & Cisco Catalyst Core Switch L3; Bản chất NAT và VPN.

### 2. [Tập 2: Cẩm nang Toàn thư Quản trị Tường lửa FortiGate FortiOS](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/02_CAM_NANG_CHUYEN_SAU_FORTIGATE_FORTIOS.md)
* **Đối tượng:** Hướng dẫn chi tiết từng ngóc ngách của hệ điều hành FortiOS.
* **Nội dung:** Trái tim phần cứng chuyên dụng chip ASIC (NP6/NP7, CP9); Bố cục giao diện Web (GUI) & CLI Console; Quản trị cổng mạng (Interfaces) & Công nghệ cân bằng tải SD-WAN; Trái tim Firewall Policy; Virtual IPs (VIP - Port forwarding); Lớp giáp bảo mật nâng cao (Antivirus, Web Filter, Application Control, IPS); Mạng riêng ảo IPsec Site-to-Site & SSL-VPN; Quản trị tài khoản Admin & Trusted Hosts; Quy trình sao lưu (Backup) và cụm dự phòng (High Availability - HA).

### 3. [Tập 3: Hồ sơ Kỹ thuật Mạng Thực tế & Bản đồ An ninh 4 Nhà máy Vinatech](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/03_HO_SO_THUC_TE_4_NHA_MAY_VINATECH.md)
* **Đối tượng:** Tài liệu kỹ thuật bàn giao hệ thống thực tế đang chạy.
* **Nội dung:** 100% dữ liệu sống trích xuất từ 4 thiết bị (Bắc Ninh FGT-80F, Hưng Yên FG-100F, Bắc Giang 1 FGT-80F, Bắc Giang 2 FGT-60F); Bảng chi tiết toàn bộ 67 Firewall Policies; Thiết bị chuyển mạch Cisco Catalyst Core Switch L3 (`192.168.184.1`); Danh bạ thiết bị sống trên VLAN 184 (`MrCuong-ProductionHY`, `PC-Thu-PRODUCTION`, `Admin-PC`, NVR Camera); Mô hình tích hợp hệ thống phần mềm MES (`C:\AwooSystem\`, Database `dbserver.hycap.co.kr,5398`, App Server `192.168.112.254:8601`); **Báo cáo Thẩm định An ninh (Security Audit): Cảnh báo 5 rủi ro bảo mật (Tài khoản lạ `fortiroot1`, VPN mã hóa yếu `des-sha1`, cổng RDP mở trực tiếp, Telnet mở trên Core Switch, lây lan mã độc SMB Workgroup).**

### 4. [Tập 4: Sổ tay Xử lý Sự cố Mạng & Tường lửa Thực chiến (Troubleshooting Playbook)](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/04_SO_TAY_XU_LY_SU_CO_THUC_CHIEN_TROUBLESHOOTING.md)
* **Đối tượng:** Cẩm nang bỏ túi khi gặp sự cố mạng trong nhà máy.
* **Nội dung:** Quy trình chẩn đoán 4 nấc thang từ dưới lên trên; Hướng dẫn xử lý **12 kịch bản sự cố kinh điển** (Mất mạng toàn công ty, đứt kết nối VPN liên xưởng, phần mềm NAIS MES mất kết nối Database hoặc server Bắc Ninh, máy in tem Barcode không in được, máy tính nhận IP lạ `169.254.x.x`, mạng lag do máy ngốn băng thông, lỗi DNS, mở port dịch vụ mới, tạo user VPN, hạ nhiệt CPU tường lửa 100%, phục hồi sau chập điện, mất hình camera NVR xưởng, lỗi chia sẻ file SMB nội bộ); Bảng lệnh CLI FortiGate và CMD/PowerShell Windows.

### 5. [Tập 5: Thực chiến Giải phẫu Mạng & Hệ thống Chiếc Máy Bạn Đang Ngồi](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/05_THUC_CHIEN_GIAI_PHAU_MANG_HIEN_TAI_CUA_BAN.md)
* **Đối tượng:** Dự án thực tế mổ xẻ 100% chiếc máy tính `User Vinatech.DESKTOP-RJJSEQU`.
* **Nội dung:** Đo lường thực tế đường đi của gói tin từ bàn phím bạn qua Switch Cisco L3 Hưng Yên (`192.168.184.1`) ➡️ Tường lửa FortiGate 100F (`10.0.0.1`) ➡️ Ra Internet Viettel (`117.4.123.239`) ➡️ Đi xuyên hầm VPN sang Bắc Ninh chỉ mất đúng **6ms** ➡️ Đi xuyên đại dương sang Wanju Hàn Quốc chỉ mất **144ms**; Bản đồ hàng xóm cùng chuyền (`MrCuong-ProductionHY`, `PC-Thu-PRODUCTION`, NVR Camera); 3 luồng dữ liệu của phần mềm NAIS MES; Kèm 7 bài tập gõ lệnh thực hành ngay trên bàn phím.

---

## 🗓️ LỘ TRÌNH 7 NGÀY TỰ HỌC TỪ SỐ 0 ĐẾN KỸ SƯ VẬN HÀNH

| Ngày | Mục tiêu học tập | Tài liệu tham khảo | Hành động thực hành |
| :---: | :--- | :--- | :--- |
| **Ngày 1** | Hiểu bản chất gói tin, IP, Port, Switch vs Router vs Firewall | [Tập 1 - Chương 1, 2, 4](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/01_GIAO_TRINH_NEN_TANG_NETWORK_SYSTEM.md) | Mở CMD gõ `ipconfig` và `arp -a`. |
| **Ngày 2** | Nắm vững cách chia mạng Subnet `/21` tại Vinatech & Bộ ba DHCP, DNS, Gateway | [Tập 1 - Chương 3, 5](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/01_GIAO_TRINH_NEN_TANG_NETWORK_SYSTEM.md) | Gõ `ping 192.168.0.254` và `ping 8.8.8.8` để cảm nhận đường đi gói tin. |
| **Ngày 3** | Hiểu sâu bản chất NAT và công nghệ đào hầm VPN nối các xưởng | [Tập 1 - Chương 6, 7, 8](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/01_GIAO_TRINH_NEN_TANG_NETWORK_SYSTEM.md) | So sánh tại sao ra Internet cần NAT còn qua VPN lại tắt NAT. |
| **Ngày 4** | Làm quen với giao diện FortiOS: Dashboard, Interfaces và SD-WAN | [Tập 2 - Phần 1, 2, 3](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/02_CAM_NANG_CHUYEN_SAU_FORTIGATE_FORTIOS.md) | Đăng nhập vào web Bắc Ninh (`42.112.60.211`), quan sát Uptime và CPU. |
| **Ngày 5** | Nắm vững trái tim Firewall Policy, Virtual IPs và Security Profiles | [Tập 2 - Phần 4, 5, 6](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/02_CAM_NANG_CHUYEN_SAU_FORTIGATE_FORTIOS.md) | Xem cách một dòng luật được xếp thứ tự từ trên xuống dưới. |
| **Ngày 6** | Nghiên cứu toàn bộ sơ đồ 4 nhà máy và thực hành đọc bảng 67 Rules | [Tập 3 - Toàn bộ](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/03_HO_SO_THUC_TE_4_NHA_MAY_VINATECH.md) | Đối chiếu tại sao Bắc Ninh nối được với Wanju Hàn Quốc và Hưng Yên. |
| **Ngày 7** | Thực hành xử lý sự cố & Học thuộc bảng lệnh CLI chẩn đoán | [Tập 4 - Toàn bộ](file:///c:/Users/User%20Vinatech.DESKTOP-RJJSEQU/Desktop/firewall/04_SO_TAY_XU_LY_SU_CO_THUC_CHIEN_TROUBLESHOOTING.md) | Thử nghiệm sao lưu bản backup cấu hình `.conf` về máy tính cá nhân. |

---

## 🔑 BẢNG TRA CỨU ĐƯỜNG DẪN & TÀI KHOẢN TRUY CẬP 4 CƠ SỞ:

| Cơ sở | Đường dẫn truy cập (URL) | Tài khoản (Username) | Mật khẩu (Password) |
| :--- | :--- | :--- | :--- |
| **Bắc Ninh (BN)** | `https://42.112.60.211/login` | `admin` | `Vinatechvina2025` |
| **Hưng Yên (HY)** | `https://10.0.0.1:4443/login` | `hainv` | `Vina@123` |
| **Bắc Giang 1 (BG1)** | `https://14.241.37.102/login` | `admin` | `Vinatech!@#bg2023` |
| **Bắc Giang 2 (BG2)** | `https://14.252.33.178/login` | `admin` | `Vinatechvina2025` |

*Chúc bạn học tập hiệu quả và sớm làm chủ toàn bộ hạ tầng mạng của Vinatech!*
