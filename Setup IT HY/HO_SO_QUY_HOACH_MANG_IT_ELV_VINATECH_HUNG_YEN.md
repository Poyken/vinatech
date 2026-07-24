# 📘 HỒ SƠ QUY HOẠCH CHI TIẾT HẠ TẦNG IT & ĐIỆN NHỆ (ELV MASTER PLAN)
## DỰ ÁN NHÀ MÁY CÔNG TY TNHH VINATECH VINA HƯNG YÊN
*(Kết hợp Bản vẽ Kỹ thuật CAD Version 5.2 & Bảng Cấu hình Vận hành Mr. Hải Update 2026)*

> **Ngày cập nhật hồ sơ:** 24/07/2026  
> **Đơn vị quản lý hệ thống:** Bộ Phận IT - Nhà Máy Vinatech Vina Hưng Yên  
> **Nguồn dữ liệu tích hợp:** 
> 1. Hồ sơ Bản vẽ Kỹ thuật CAD 43 trang (`Drawing_ELV System_VINATECH_260615_v5.2.pdf`) phát hành 15/06/2026 bởi DOUL ASIA CO., LTD.  
> 2. Bảng Quy hoạch Mạng & Gán địa chỉ IP thực tế (`Mr.Hai_Update.xlsx`) cập nhật ngày 04/02/2026.

---

## 📌 MỤC LỤC TÀI LIỆU
1. [Tổng Quan Kiến Trúc Hạ Tầng IT & Điện Nhẹ (ELV Architecture)](#1-tổng-quan-kiến-trúc-hạ-tầng-it--điện-nhẹ-elv-architecture)
2. [Bảng So Sánh & Cập Nhật Thực Tế So Với Bản Vẽ CAD Thiết Kế](#2-bảng-so-sánh--cập-nhật-thực-tế-so-với-bản-vẽ-cad-thiết-kế)
3. [Phân Tích Chi Tiết 6 Phân Hệ Điện Nhẹ ELV Chính](#3-phân-tích-chi-tiết-6-phân-hệ-điện-nhẹ-elv-chính)
4. [Bảng Quy Hoạch Chi Tiết Subnetting & VLAN (Logical Network Scheme)](#4-bảng-quy-hoạch-chi-tiết-subnetting--vlan-logical-network-scheme)
5. [Bảng Tra Cứu Chi Tiết IP Management & Tài Khoản Truy Cập 33 Thiết Bị Active](#5-bảng-tra-cứu-chi-tiết-ip-management--tài-khoản-truy-cập-33-thiết-bị-active)
6. [Ma Trận Phân Bổ Thiết Bị Trong 11 Tủ Rack & Trục Cáp Quang Backbone](#6-ma-trận-phân-bổ-thiết-bị-trong-11-tủ-rack--trục-cáp-quang-backbone)
7. [Bảng Phân Bổ Chi Tiết Điểm Mạng LAN/TEL & Máng Cáp Theo Tầng](#7-bảng-phân-bổ-chi-tiết-điểm-mạng-lantel--máng-cáp-theo-tầng)
8. [Quy Trình Hướng Dẫn Vận Hành & Xử Lý Sự Cố Dành Cho IT](#8-quy-trình-hướng-dẫn-vận-hành--xử-lý-sự-cố-dành-cho-it)

---

## 1. TỔNG QUAN KIẾN TRÚC HẠ TẦNG IT & ĐIỆN NHỆ (ELV ARCHITECTURE)

### 1.1. Thông Tin Chung Dự Án
* **Tên dự án:** CÔNG TY TNHH VINATECH VINA HƯNG YÊN.
* **Địa chỉ:** Lô CN7.4-5 Khu Công Nghiệp Sạch, Xã Xuân Trúc, Huyện Ân Thi, Tỉnh Hưng Yên, Việt Nam.
* **Chủ đầu tư:** CÔNG TY TNHH VINATECH VINA.
* **Đơn vị tư vấn thiết kế:** DOUL ASIA CO., LTD (B3-18 Vinhomes Gardenia, Nam Từ Liêm, Hà Nội).
* **Nhân sự phụ trách thiết kế:** Seo Sang Wook (Quản lý kỹ thuật) | Hwang Sun Soo (Chủ trì bộ môn) | Nguyễn Xuân Hiếu (Chủ nhiệm dự án).

### 1.2. Mô Hình Mạng 3 Lớp Trung Tâm (Hierarchical Core-Access Network)
Hệ thống IT Nhà máy Vinatech Hưng Yên được tổ chức theo mô hình hình sao (Star Topology) dự phòng cao:
```
                                 [ ĐƯỜNG TRUYỀN ISP INTERNET ]
                                  ├── Viettel Fiber (WAN 1)
                                  └── VNPT Fiber    (WAN 2 - Failover)
                                           │
                                           ▼
                       [ TƯỜNG LỬA BẢO MẬT: FORTIGATE 100F (10.0.0.1) ]
                                           │ (Cáp Trunk Link 802.1Q Tagging - 1 Gbps/10Gbps)
                                           ▼
                    [ SWITCH CHUYỂN MẠCH TRUNG TÂM: CISCO C1300-24T-4G (192.168.150.1) ]
                                           │
         ┌───────────────────┬─────────────┼─────────────┬───────────────────┐
         ▼                   ▼             ▼             ▼                   ▼
  [VLAN 150 MGMT]     [VLAN 155 SERVER] [VLAN 160 FACTORY] [VLAN 184 OFFICE] [VLAN 220 CCTV & 228 WIFI]
  Switch/AP/PABX Mgmt MES / HR / DB     Máy sản xuất     PC Văn Phòng       79 Camera & 8 UniFi APs
```

---

## 2. BẢNG SO SÁNH & CẬP NHẬT THỰC TẾ SO VỚI BẢN VẼ CAD THIẾT KẾ

Tài liệu `Mr.Hai_Update.xlsx` đã chuẩn hóa và cập nhật trực tiếp các dòng thiết bị thương mại thực tế thay thế cho mã ký hiệu chung trên CAD PDF v5.2:

| Hạng Mục Thiết Bị | Hồ Sơ Kỹ Thuật CAD (PDF v5.2) | Cấu Hình Cập Nhật Thực TẾ (Excel Mr. Hải) | Nguyên Nhân & Lợi Ích Vận Hành |
| :--- | :--- | :--- | :--- |
| **Firewall Trung Tâm** | FortiGate 100E | **FortiGate 100F** (`FW-VINATECH-HY`) | Nâng cấp phần cứng thế hệ 100F (CPU RISC/ASIC SoC4), tăng gấp 2 lần throughput VPN/SSL và IPS/Antivirus cho MES. |
| **L3 Core Switch** | L3 Switch 24P (Cisco) | **Cisco C1300-24T-4G** (`L3-VINATECH-HY`) | Dòng Cisco Catalyst C1300 mới nhất, hỗ trợ Stacking, Routing Layer 3 tốc độ cao và quản trị GUI/CLI chuẩn. |
| **L2 Access Switch** | L2 Switch 48P / 24P / 8P | **Cisco CBS220-48T-4G-EU**, **CBS220-8T-E-2G-EU**, **C1200-24T-4G** | Chuẩn hóa toàn bộ hệ thống Switch chia tầng sang thương hiệu Cisco Business 220/1200 series độ bền cao. |
| **Switch PoE CCTV** | L2 Switch PoE 16P / 8P | **Hikvision DS-3E1318P-EI/M** (18P) & **DS-3E1310P-EI/M** (10P) | Dùng Switch PoE thông minh Hikvision giúp cấp nguồn trực tiếp qua cáp UTP cho Camera, hỗ trợ quản lý PoE công suất xa 250m. |
| **Phân Hệ Wi-Fi** | Access Point ốp trần (8 bộ) | **UniFi U7 Lite** (8 bộ) + **UniFi Virtual Controller** | Nâng cấp lên chuẩn Wi-Fi 7 (802.11be) tốc độ cực cao, quản lý tập trung qua máy chủ ảo UniFi Controller (`192.168.150.100`). |

---

## 3. PHÂN TÍCH CHI TIẾT 6 PHÂN HỆ ĐIỆN NHỆ ELV CHÍNH

### 3.1. Phân Hệ Mạng LAN, Điện Thoại IP PBX & Wi-Fi Nội Bộ (CAD 42/06)
* **Firewall FortiGate 100F:** Đặt tại RACK IT Main Room Tầng 2. Nhận 2 đường cáp quang ngầm từ ISP (Viettel kết nối WAN1, VNPT kết nối WAN2) thiết lập cơ chế dự phòng tự động chuyển mạch (Failover).
* **Core Switch Cisco C1300:** Quản lý toàn bộ Inter-VLAN Routing. Đấu nối vỏ thiết bị về busbar tiếp địa copper bar R < 1 Ohm.
* **Tổng đài IP PBX & IP Phone:** 01 Tổng đài IP PBX trung tâm đặt tại Rack Main 42U + 23 Điện thoại bàn IP Phone cắm tại các phòng ban và 3 Cổng Bảo vệ.
* **Hệ thống Wi-Fi 7 UniFi U7 Lite:** 08 Bộ phát Wi-Fi ốp trần tại Văn phòng Tầng 2 (APM-01, APM-02), Xưởng Tầng 1 (AP 1-01, AP 1-02, AP 1-03), Xưởng Tầng 3 (AP 3-01) và Xưởng Tầng 2 (AP 4-01, AP 4-02).

### 3.2. Phân Hệ Camera Giám Sát An Ninh CCTV (CAD 42/07)
* **Trung tâm quản lý:** 02 Đầu ghi NVR Hikvision (01 NVR 64 kênh + 01 NVR 32 kênh) đặt tại Server Room Tầng 2 + 01 PC Client Giám sát an ninh + 03 Màn hình 50 inch hiển thị hình ảnh 24/7.
* **Tổng số lượng 79 Camera IP phân bổ:**
  - **48 Camera IP Dome Indoor:** Gắn trần hành lang văn phòng 2F và xưởng sản xuất 1F, 1.5F, 2F, 3F.
  - **30 Camera IP Bullet Outdoor (IP66/IP67):** Lắp trên 11 Cột ngoài sân (Camera Pole 01~11), 3 Cổng Bảo vệ và hàng rào nhà máy.
  - **02 Camera IP Bullet Flame:** Cảm biến nhiệt chống cháy lắp tại khu vực nhiệt độ cao.
  - **01 Camera IP Explosion-Proof:** Camera chuyên dụng chống cháy nổ lắp tại Kho Hóa Chất.
* **Hạ tầng kết nối CCTV:** 18 bộ Media Converter & ODF cáp quang nối từ 10 Tủ Rack tầng / BOX ngoài trời về Main Switch CCTV `C1200-24T-4G` (`192.168.150.50`).

### 3.3. Phân Hệ Chấm Công & Kiểm Soát Ra Vào TA/AC (CAD 42/08 & 42/35)
* **Máy chấm công (05 bộ):** Máy chấm công nhận diện khuôn mặt / vân tay tại cửa xưởng Tầng 1, 2, 3 và E-Parking kết nối về Server PC HR/IT.
* **Kiểm soát ra vào Access Control (16 cửa):** Lắp tại Server IT Room, Phòng IT, Phòng Giám Đốc, Kho Hóa Chất. Mỗi hệ thống cửa bao gồm: Đầu đọc AC, Khóa từ Magnetic Lock, Nút nhấn thoát hiểm Exit Button.
* **Cổng Barie Flapgate Tự Động (06 làn):** Lắp đặt tại Nhà xe công nhân (E-Parking) kết nối về Switch L2 `CBS220-8T-E-2G-EU` (`192.168.150.8`) tại RACK 05.

### 3.4. Phân Hệ Âm Thanh Thông Báo PA (CAD 42/09)
* **Tủ Rack PA 27U D800 (Đặt tại Phòng IT Tầng 2):** Chứa Bộ hẹn giờ ca giờ **TOA Program Timer TT-104B**, CD Player, Main Amplifier, Extension Amplifier và Remote Microphone.
* **Phân 3 Vùng Âm Thanh (Zone Selector):**
  - **Vùng 1 (Văn Phòng 2F):** 56 Loa âm trần Ceiling Speaker (Phát nhạc nền & thông báo).
  - **Vùng 2 (Nhà Xưởng 1F, 1.5F, 2F, 3F):** 36 Loa hộp Wall Speaker (Thông báo ca giờ & báo động khẩn cấp).
  - **Vùng 3 (Sân Bãi & E-Parking):** 04 Loa nén phóng thanh Horn Speaker.

### 3.5. Phân Hệ Tiếp Địa Điện Nhẹ (ELV Grounding) (CAD 42/36 & 42/42)
* **Bãi cọc tiếp địa chuyên dụng:** Hệ thống cọc đồng tiếp địa 2.4m chôn ngầm dưới đất ngoài trời, điện trở tiếp địa **R < 1 Ohm**.
* **Trục tiếp địa:** Dây đồng trần M70/M50 đi từ bãi cọc -> Hộp kiểm tra tiếp địa Testing Box Tầng 1 -> Busbar Đồng Server Room 2F.
* **Kết nối bảo vệ thiết bị:** Dây Cu/PVC 1x16mm² nối vỏ Rack IT Main Room; Dây Cu/PVC 1x10mm² nối vỏ 10 Tủ Rack tầng/ngoài trời và hệ thống Máng cáp Cable Tray.

### 3.6. Tuyến Cáp Quang Viễn Thông ISP & Hạ Tầng Ngầm (CAD 42/37 & 42/40)
* **Đường cáp viễn thông vào:** Cáp quang ngầm đi trong ống HDPE D42/50mm luồn ống thép D60mm chạy qua **11 Hố ga (Manhole 01 ~ 11)** ngoài đường chính vào Tủ ISP ODF trong Phòng Server Tầng 2.

---

## 4. BẢNG QUY HOẠCH CHI TIẾT SUBNETTING & VLAN (LOGICAL NETWORK SCHEME)

Tổng hợp chi tiết thông số mạng của 6 VLAN chính theo quy chuẩn quốc tế CIDR:

```
+---------------------------------------------------------------------------------------------------+
| ID  | VLAN NAME  | SUBNET NETWORK    | SUBNET MASK     | WILDCARD    | GATEWAY IP    | TOTAL HOSTS |
+---------------------------------------------------------------------------------------------------+
| 10  | Link FW    | 10.0.0.0/24       | 255.255.255.0   | 0.0.0.255   | 10.0.0.1      | 254 Hosts   |
| 150 | mgmt       | 192.168.150.0/24  | 255.255.255.0   | 0.0.0.255   | 192.168.150.1 | 254 Hosts   |
| 155 | Server     | 192.168.155.0/24  | 255.255.255.0   | 0.0.0.255   | 192.168.155.1 | 254 Hosts   |
| 160 | Factory    | 192.168.160.0/20  | 255.255.240.0   | 0.0.15.255  | 192.168.160.1 | 4.094 Hosts |
| 184 | office     | 192.168.184.0/21  | 255.255.248.0   | 0.0.7.255   | 192.168.184.1 | 2.046 Hosts |
| 220 | CCTV       | 192.168.220.0/22  | 255.255.252.0   | 0.0.3.255   | 192.168.220.1 | 1.022 Hosts |
| 228 | Wifi       | 192.168.228.0/22  | 255.255.252.0   | 0.0.3.255   | 192.168.228.1 | 1.022 Hosts |
+---------------------------------------------------------------------------------------------------+
```

### Phân Tích Kỹ Thuật Subnetting:
1. **VLAN 160 (Factory - `/20`):** Cấp dải IP rộng từ `192.168.160.1` đến `192.168.175.254` (Broadcast: `192.168.175.255`). Đáp ứng tới **4.094 thiết bị**, đảm bảo mở rộng cho toàn bộ máy móc sản xuất, băng chuyền Packing, Formation, Assembly và các cảm biến IoT MES trong tương lai mà không lo cạn IP.
2. **VLAN 184 (Office - `/21`):** Cấp dải IP từ `192.168.184.1` đến `192.168.191.254` (Broadcast: `192.168.191.255`). Đáp ứng **2.046 thiết bị** PC, Laptop, In ấn, Máy chiếu văn phòng.
3. **VLAN 220 (CCTV - `/22`) & VLAN 228 (Wifi - `/22`):** Mỗi VLAN sở hữu dải IP cấp cho **1.022 thiết bị**, cách ly hoàn toàn băng thông truyền tải video CCTV và lưu lượng truy cập Wi-Fi khỏi mạng điều khiển sản xuất MES.

---

## 5. BẢNG TRA CỨU CHI TIẾT IP MANAGEMENT & TÀI KHOẢN TRUY CẬP 33 THIẾT BỊ ACTIVE

Toàn bộ 33 thiết bị hạ tầng active dưới đây thuộc **VLAN 150 (`mgmt`)**, có **Subnet Mask `255.255.255.0`** và **Gateway `192.168.150.1`**:

| STT | Vị Trí Lắp Đặt | Tên Thiết Bị (Device Name) | Loại Thiết Bị | Mã Model Kỹ Thuật | IP Management | Gateway | User Admin | Password Admin |
| :---: | :--- | :--- | :--- | :--- | :---: | :---: | :---: | :---: |
| 1 | IT ROOM (2F) | `FW-VINATECH-HY` | Firewall Trung Tâm | Fortigate 100F | **10.0.0.1** | 10.0.0.1 | `admin` | `Vina123@!#` |
| 2 | IT ROOM (2F) | `L3-VINATECH-HY` | Core Switch L3 | Cisco C1300-24T-4G | **192.168.150.1** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 3 | IT ROOM (2F) | `L2-IT ROOM-01` | Access Switch L2 | Cisco CBS220-48T-4G-EU | **192.168.150.2** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 4 | IT ROOM (2F) | `L2-IT ROOM-02` | Access Switch L2 | Cisco C1200-24T-4G | **192.168.150.3** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 5 | RACK 01 (1F) | `L2-R1-FAC1F` | Access Switch L2 | Cisco CBS220-48T-4G-EU | **192.168.150.4** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 6 | RACK 02 (1F) | `L2-R2-FAC1F` | Access Switch L2 | Cisco CBS220-8T-E-2G-EU | **192.168.150.5** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 7 | RACK 03 (1F) | `L2-R3-FAC1F` | Access Switch L2 | Cisco C1200-24T-4G | **192.168.150.6** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 8 | RACK 04 (2F) | `L2-R4-FAC2F` | Access Switch L2 | Cisco CBS220-48T-4G-EU | **192.168.150.7** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 9 | RACK 05 (E-Parking) | `L2-R5-EPARKING` | Access Switch L2 | Cisco CBS220-8T-E-2G-EU | **192.168.150.8** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 10 | RACK 06 (Cổng 1) | `L2-R6-GUARDHOUSE-01` | Access Switch L2 | Cisco CBS220-8T-E-2G-EU | **192.168.150.9** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 11 | RACK 07 (Cổng 2) | `L2-R7-GUARDHOUSE-02` | Access Switch L2 | Cisco CBS220-8T-E-2G-EU | **192.168.150.10** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 12 | RACK 08 (Cổng 3) | `L2-R8-GUARDHOUSE-03` | Access Switch L2 | Cisco CBS220-8T-E-2G-EU | **192.168.150.11** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 13 | IT ROOM (2F) | `L2-MAIN CCTV` | Switch Main CCTV | Cisco C1200-24T-4G | **192.168.150.50** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 14 | IT ROOM (2F) | `L2-CCTV-ITROOM` | Switch PoE Camera | Hikvision DS-3E1310P-EI/M | **192.168.150.51** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 15 | RACK 01 (1F) | `L2-CCTV-RACK 1` | Switch PoE Camera | Hikvision DS-3E1318P-EI/M | **192.168.150.52** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 16 | RACK 02 (1F) | `L2-CCTV-RACK 2` | Switch PoE Camera | Hikvision DS-3E1318P-EI/M | **192.168.150.53** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 17 | RACK 03 (1F) | `L2-CCTV-RACK 3` | Switch PoE Camera | Hikvision DS-3E1318P-EI/M | **192.168.150.54** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 18 | BOX 01 (Ngoài trời)| `L2-CCTV-BOX 1` | Switch PoE Chống Nước | Hikvision DS-3E1310P-EI/M | **192.168.150.55** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 19 | RACK 04 (2F) | `L2-CCTV-RACK 4` | Switch PoE Camera | Hikvision DS-3E1310P-EI/M | **192.168.150.56** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 20 | RACK 05 (E-Parking) | `L2-CCTV-RACK 5` | Switch PoE Camera | Hikvision DS-3E1318P-EI/M | **192.168.150.57** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 21 | RACK 06 (Cổng 1) | `L2-CCTV-RACK 6` | Switch PoE Camera | Hikvision DS-3E1310P-EI/M | **192.168.150.58** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 22 | RACK 07 (Cổng 2) | `L2-CCTV-RACK 7` | Switch PoE Camera | Hikvision DS-3E1310P-EI/M | **192.168.150.59** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 23 | RACK 08 (Cổng 3) | `L2-CCTV-RACK 8` | Switch PoE Camera | Hikvision DS-3E1310P-EI/M | **192.168.150.60** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 24 | RACK 09 (Utility) | `L2-CCTV-RACK 9` | Switch PoE Camera | Hikvision DS-3E1310P-EI/M | **192.168.150.61** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 25 | Server IT Room | `Unifi Controller` | Virtual PC Management| UniFi Controller Soft | **192.168.150.100** | 192.168.150.1 | `admin` | `Vina123@!#` |
| 26 | Phòng IT Tầng 2 | `APM-01` | Wi-Fi 7 Access Point | UniFi U7 Lite | **192.168.150.101** | 192.168.150.1 | Managed via Controller |
| 27 | Phòng IT Tầng 2 | `APM-02` | Wi-Fi 7 Access Point | UniFi U7 Lite | **192.168.150.102** | 192.168.150.1 | Managed via Controller |
| 28 | Xưởng 1F (Rack 01) | `AP 1- 01` | Wi-Fi 7 Access Point | UniFi U7 Lite | **192.168.150.103** | 192.168.150.1 | Managed via Controller |
| 29 | Xưởng 1F (Rack 01) | `AP 1- 02` | Wi-Fi 7 Access Point | UniFi U7 Lite | **192.168.150.104** | 192.168.150.1 | Managed via Controller |
| 30 | Xưởng 1F (Rack 01) | `AP 1- 03` | Wi-Fi 7 Access Point | UniFi U7 Lite | **192.168.150.105** | 192.168.150.1 | Managed via Controller |
| 31 | Xưởng 1F (Rack 03) | `AP 3 - 01` | Wi-Fi 7 Access Point | UniFi U7 Lite | **192.168.150.106** | 192.168.150.1 | Managed via Controller |
| 32 | Xưởng 2F (Rack 04) | `AP 4-01` | Wi-Fi 7 Access Point | UniFi U7 Lite | **192.168.150.107** | 192.168.150.1 | Managed via Controller |
| 33 | Xưởng 2F (Rack 04) | `AP 4-02` | Wi-Fi 7 Access Point | UniFi U7 Lite | **192.168.150.108** | 192.168.150.1 | Managed via Controller |

---

## 6. MA TRẬN PHÂN BỔ THIẾT BỊ TRONG 11 TỦ RACK & TRỤC CÁP QUANG BACKBONE

### 6.1. Chi Tiết Lắp Đặt Bố Trí Bề Mặt Tủ Rack (Rack Elevation - CAD 42/11)
1. **RACK MAIN IT ROOM (42U D1000) - Server Room Tầng 2 [⏚ Tiếp địa Cu 1x16mm²]:**
   - `U40-U42`: ODF Cáp quang trung tâm 52 Port.
   - `U38-U39`: ODF Cáp quang ISP nhà mạng (Viettel / VNPT).
   - `U36-U37`: FortiGate 100F Firewall (Cắm WAN1/WAN2 ODF ISP).
   - `U34-U35`: Cisco C1300-24T-4G Core Switch L3 (Cắm Trunk Link UTP sang FortiGate).
   - `U31-U33`: Cisco C1200-24T-4G (Main CCTV Switch) & CBS220-48T Access Switch.
   - `U25-U30`: 14 Thanh Patch Panel Cat6 & Quản lý cáp.
   - `U20-U24`: Tổng đài điện thoại IP PBX.
   - `U15-U19`: 02 Đầu ghi NVR 64CH & NVR 32CH Hikvision.
   - `U01-U06`: Bộ lưu điện UPS Trung tâm IT & Pack Pin dự phòng.
2. **RACK PA IT ROOM (27U D800) - IT Room Tầng 2 [⏚ Tiếp địa Cu 1x10mm²]:** Chứa TOA Program Timer TT-104B, CD Player, Main Amply, Extension Amply, Microphone.
3. **RACK 01 & RACK 02 (27U D800) - Tầng 1 Xưởng [⏚ Tiếp địa Cu 1x10mm²]:** Chứa ODF 8 Port, Patch Panel Cat6, Switch Cisco CBS220, Switch Hikvision PoE 18 Port, UPS Local.
4. **RACK 03 (1F) & RACK 04 (2F) - Xưởng Sản Xuất [⏚ Tiếp địa Cu 1x10mm²]:** Chứa ODF 12P/8P, Patch Panel, Switch Cisco C1200/CBS220, Switch Hikvision PoE 10 Port, Local UPS.
5. **RACK 05 (NHÀ XE E-PARKING 10U/27U) [⏚ Tiếp địa Cu 1x10mm²]:** Chứa ODF 16 Port, Switch Flapgate Barie 16 Port, Switch Hikvision PoE 8 Port, Switch AC L2 8 Port.
6. **RACK 06, 07, 08 (CỔNG BẢO VỆ 1, 2, 3) & RACK 09 (UTILITY) [⏚ Tiếp địa Cu 1x10mm²]:** Chứa ODF 8P/16P/4P, Switch Cisco CBS220 8 Port, Switch Hikvision PoE 8 Port.

### 6.2. Sơ Đồ Trục Cáp Quang Backbone (Fiber Core Map - CAD 42/38 & 42/39)
| Tuyến Cáp Quang Xuất Phát Từ Tủ IT Main (2F Server Room) Đi Đến | Số Lõi Cáp Quang Mạng (Network Backbone 42/38) | Số Lõi Cáp Quang Camera (CCTV Backbone 42/39) |
| :--- | :---: | :---: |
| **RACK 01 - 1F** (Xưởng Tầng 1) | Cáp quang 8-Core (x1 tuyến) | Cáp quang 8-Core (x1 tuyến) |
| **RACK 02 - 1F** (Xưởng Tầng 1) | Cáp quang 8-Core (x2 tuyến) | Cáp quang 8-Core (x2 tuyến) |
| **RACK 03 - 1F** (Xưởng Tầng 1) | Cáp quang 4-Core (x1 tuyến) | Cáp quang 4-Core (x1 tuyến) |
| **RACK 04 - 2F** (Xưởng Tầng 2) | Cáp quang 8-Core (x2 tuyến) | Cáp quang 8-Core (x3 tuyến) |
| **RACK 05 - E-PARKING** (Khu Nhà Xe) | Cáp quang 8-Core (x5 tuyến) | Cáp quang 8-Core (x6 tuyến) |
| **RACK 06 - GUARDHOUSE 1** (Cổng 1) | Cáp quang 8-Core (x1 tuyến) | Cáp quang 8-Core (x1 tuyến) |
| **RACK 07 - GUARDHOUSE 2** (Cổng 2) | Cáp quang 8-Core (x1 tuyến) | Cáp quang 8-Core (x1 tuyến) |
| **RACK 08 - GUARDHOUSE 3** (Cổng 3) | Cáp quang 8-Core (x1 tuyến) | Cáp quang 8-Core (x1 tuyến) |
| **RACK 09 - UTILITY** (Phụ Trợ) | Cáp quang 8-Core (x1 tuyến) | Cáp quang 8-Core (x1 tuyến) |

---

## 7. BẢNG PHÂN BỔ CHI TIẾT ĐIỂM MẠNG LAN/TEL & MÁNG CÁP THEO TẦNG

| Khu Vực Tầng | Số Bản Vẽ CAD | Số Lượng Điểm Mạng LAN / TEL Chi Tiết | Tủ Rack Đấu Nối | Quy Cách Tuyến Máng Cáp IT |
| :--- | :---: | :--- | :---: | :--- |
| **Tầng 1 Nhà Xưởng** | 42/12 & 42/33 | • 16 Ổ cắm mạng âm tường (01 LAN Wall)<br>• 04 Ổ cắm mạng đôi (02 LAN Wall)<br>• 01 Cụm 06 LAN Wall (Phòng Quản lý xưởng)<br>• Cấp mạng chuyền 130 Packing, 131 Formation, 132/133 Assembly | RACK 01, RACK 02, RACK 03 | Cable Tray 300x100mm & 200x100mm mạ kẽm chạy dọc xưởng |
| **Tầng 1.5 Phụ Trợ** | 42/13 | • 03 Ổ cắm mạng âm tường (01 LAN Wall)<br>• 19 Ổ cắm mạng âm sàn (01 LAN Floor)<br>• Cấp mạng máy phụ trợ | RACK MAIN 2F & RACK 04 | Máng cáp nhánh 100x50mm & Ống PVC D25/D32 |
| **Tầng 2 Văn Phòng** | 42/14 & 42/34 | • 39 Ổ cắm mạng âm sàn (01 LAN Floor cụm bàn)<br>• 01 Ổ cắm mạng âm tường (01 LAN Wall)<br>• 02 Ổ cắm 04 Cổng (04 LAN Wall - Server Room)<br>• 08 Phát Wi-Fi Access Point ốp trần | RACK MAIN IT ROOM (42U) & RACK 04 | Cable Tray 300x100mm chạy dọc trục hành lang văn phòng |
| **Tầng 3 Nhà Xưởng** | 42/15 | • 01 Ổ cắm mạng âm tường (01 LAN Wall)<br>• Cấp mạng máy chủ quản lý tầng mái | RACK MAIN 2F | Máng cáp 100x50mm luồn ống PVC âm trần |
| **Nhà Xe E-Parking** | 42/16 & 42/35 | • 01 Ổ cắm mạng âm tường (01 LAN Wall)<br>• 06 Làn Barie Flapgate tự động<br>• 02 Cổng đọc thẻ & Camera biển số xe | RACK 05 (E-Parking) | Tuyến ống ngầm HDPE D42/50 luồn trong hố ga Manhole |
| **3 Cổng Bảo Vệ** | 42/17 | • 03 Ổ cắm tích hợp Mạng & TEL (01 LAN + 01 TEL)<br>• Điện thoại bàn IP Phone bảo vệ liên lạc | RACK 06, RACK 07, RACK 08 | Tuyến cáp quang ngầm đi qua Pipe Rack & Hố ga Manhole 01~11 |

---

## 8. QUY TRÌNH HƯỚNG DẪN VẬN HÀNH & XỬ LÝ SỰ CỐ DÀNH CHO IT

### 🛠️ Kịch bản 1: Mất kết nối mạng tại một máy tính chuyền sản xuất (VLAN 160)
1. Kiểm tra đèn báo Link/Act trên ổ cắm mạng âm tường/âm sàn tại vị trí máy.
2. Tra bản vẽ CAD **Trang 12 (Tầng 1)** xác định dây cáp đó kéo về **RACK 01, RACK 02 hay RACK 03**.
3. Mở file Excel `Mr.Hai_Update.xlsx` (Sheet 03), lấy IP Management của Switch tủ đó (`192.168.150.4` cho RACK 01, `192.168.150.5` cho RACK 02, `192.168.150.6` cho RACK 03).
4. Truy cập Web Admin / Telnet (`admin / Vina123@!#`), kiểm tra trạng thái Port đó có bị Error-disabled hay văng khỏi **VLAN 160 (Factory)** không.

### 🛠️ Kịch bản 2: Camera ngoài sân / Cổng bảo vệ mất hình (VLAN 220)
1. Tra mặt bằng **Trang 18 (CCTV Master Plan)** xác định vị trí Cột Camera ngoài trời (**Camera Pole 01 ~ 11**).
2. Kiểm tra tủ điện **BOX 01 Outdoor** ngoài sân: Kiểm tra nguồn 220V/Adapter DC12V và Switch PoE Hikvision `DS-3E1310P-EI/M` (IP `192.168.150.55`).
3. Nếu đứt toàn bộ cụm Camera Cổng Bảo vệ: Truy cập Switch CCTV tương ứng (`192.168.150.58` RACK 06, `192.168.150.59` RACK 07, `192.168.150.60` RACK 08) kiểm tra tuyến cáp quang ngầm đi qua các hố ga **Manhole 01 ~ 11**.

### 🛠️ Kịch bản 3: Sự cố Cổng Barie Flapgate / Chấm công Nhà xe (E-Parking)
1. Tra **Trang 35 (Flap Barie E-Parking)** và **Trang 16 (Network E-Parking)**.
2. Đến **RACK 05** tại E-Parking: Kiểm tra nguồn UPS Local, Switch Cisco `CBS220-8T` (IP `192.168.150.8`) và Switch CCTV `DS-3E1318P` (IP `192.168.150.57`).
3. Đảm bảo các đầu đọc thẻ Barie được cấp đúng IP thuộc dải Server AC hoặc VLAN 150/160.

### 🛠️ Kịch bản 4: Mất kết nối Internet toàn nhà máy (Chuyển mạch WAN Failover)
1. Truy cập Tường lửa FortiGate 100F tại IP `10.0.0.1` (User: `admin` / Password: `Vina123@!#`).
2. Kiểm tra trang `Network > Interfaces`: Xem trạng thái cổng `WAN1` (Viettel) và `WAN2` (VNPT).
3. Kiểm tra tính năng **SD-WAN / Link Monitor**: Nếu đường chính Viettel bị sự cố, FortiGate sẽ tự động điều hướng 100% lưu lượng dữ liệu qua đường VNPT mà không ngắt đoạn kết nối hệ thống MES.

---
*Tài liệu Kỹ thuật Hạ tầng IT & Điện Nhẹ được tổng hợp và chuẩn hóa hoàn chỉnh phục vụ công tác vận hành, bàn giao và bảo trì Nhà máy Vinatech Vina Hưng Yên.*
