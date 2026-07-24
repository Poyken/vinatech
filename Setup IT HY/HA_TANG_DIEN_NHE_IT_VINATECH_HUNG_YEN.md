# 📘 HỒ SƠ THIẾT KẾ KỸ THUẬT HẠ TẦNG IT & ĐIỆN NHỆ (ELV)
## DỰ ÁN NHÀ MÁY VINATECH VINA HƯNG YÊN (VERSION 5.2)

> **Lưu ý:** Tài liệu này được dịch thuật chuẩn hóa, tổng hợp toàn bộ thông số kỹ thuật chi tiết từ tập bản vẽ 43 trang (`Drawing_ELV System_VINATECH_260615_v5.2.pdf`) phục vụ trực tiếp công tác vận hành, bảo trì và xử lý sự cố của Bộ Phận IT Nhà Máy Vinatech Hưng Yên.

---

## 📌 MỤC LỤC TÀI LIỆU
1. [Tổng Quan Dự Án & Hạ Tầng Điện Nhẹ (ELV Overview)](#1-tổng-quan-dự-án--hạ-tầng-điện-nhẹ-elv-overview)
2. [Bảng Thống Kê Chi Tiết Số Lượng Thiết Bị IT & Kỹ Thuật (BOM - 56 Hạng Mục)](#2-bảng-thống-kê-chi-tiết-số-lượng-thiết-bị-it--kỹ-thuật-bom---56-hạng-mục)
3. [Sơ Đồ Nguyên Lý Kỹ Thuật 6 Phân Hệ Điện Nhẹ Chính](#3-sơ-đồ-nguyên-lý-kỹ-thuật-6-phân-hệ-điện-nhẹ-chính)
4. [Bảng Chi Tiết 11 Tủ Rack Mạng & Sơ Đồ Cáp Quang Trục Chính (Backbone Core Map)](#4-bảng-chi-tiết-11-tủ-rack-mạng--sơ-đồ-cáp-quang-trục-chính-backbone-core-map)
5. [Bảng Phân Bổ Chi Tiết Điểm Mạng (Node LAN/TEL) & Máng Cáp Theo Tầng](#5-bảng-phân-bổ-chi-tiết-điểm-mạng-node-lantel--máng-cáp-theo-tầng)
6. [Danh Mục Đầy Đủ 43 Trang Bản Vẽ Kỹ Thuật CAD](#6-danh-mục-đầy-đủ-43-trang-bản-vẽ-kỹ-thuật-cad)
7. [Quy Trình Hướng Dẫn Kỹ Thuật Dành Cho IT Vận Hành & Xử Lý Sự Cố](#7-quy-trình-hướng-dẫn-kỹ-thuật-dành-cho-it-vận-hành--xử-lý-sự-cố)

---

## 1. TỔNG QUAN DỰ ÁN & HẠ TẦNG ĐIỆN NHỆ (ELV OVERVIEW)

* **Tên dự án:** DỰ ÁN CÔNG TY TNHH VINATECH VINA HƯNG YÊN
* **Địa chỉ:** Lô CN7.4-5 Khu Công Nghiệp Sạch, Xã Xuân Trúc, Huyện Ân Thi, Tỉnh Hưng Yên, Việt Nam.
* **Chủ đầu tư:** CÔNG TY TNHH VINATECH VINA (Địa chỉ cũ: Số 410, Khu phố Hà Liễu, P. Phương Liễu, Bắc Ninh).
* **Đơn vị tư vấn thiết kế:** DOUL ASIA CO., LTD (Địa chỉ: B3-18 Vinhomes Gardenia, Đường Hàm Nghi, Nam Từ Liêm, Hà Nội).
* **Quản lý kỹ thuật:** Seo Sang Wook | **Chủ trì bộ môn:** Hwang Sun Soo | **Chủ nhiệm dự án:** Nguyễn Xuân Hiếu.
* **Ngày phát hành bản vẽ:** 15/06/2026 (Phiên bản Version 5.2 - Giai đoạn Thiết kế Thi công Construction Design).
* **Quy mô dự án:** Nhà máy sản xuất 3 tầng + Tầng 1.5 phụ trợ, Khu Văn phòng Tầng 2, Khu Bãi xe công nhân (E-Parking), 3 Cổng Bảo vệ (Guardhouse 1, 2, 3), Khu Trạm phụ trợ Utility, và Hệ thống hạ tầng ống ngầm ngoài trời.

---

## 2. BẢNG THỐNG KÊ CHI TIẾT SỐ LƯỢNG THIẾT BỊ IT & KỸ THUẬT (BOM - 56 HẠNG MỤC)
*(Chuyển ngữ & tổng hợp chính xác 100% từ Trang 3 - Bản vẽ 42/03 Product Quantity Summary)*

### I. Hệ Thống Mạng LAN & Tổng Đài (Network & PBX System)
| STT | Phân Hệ | Tên Thiết Bị / Hạng Mục Kỹ Thuật | Ký Hiệu / Model | Đơn Vị | Số Lượng |
| :---: | :--- | :--- | :---: | :---: | :---: |
| 1 | Network | Tường lửa bảo mật trung tâm | FortiGate 100E Firewall | Cái | **01** |
| 2 | Network | Switch chuyển mạch trung tâm Layer 3 (24 Cổng) | L3 Switch 24P (Cisco) | Cái | **01** |
| 3 | Network | Switch chia tầng Layer 2 (48 Cổng LAN) | L2 Switch 48P | Cái | **03** |
| 4 | Network | Switch chia tầng Layer 2 (24 Cổng LAN) | L2 Switch 24P | Cái | **02** |
| 5 | Network | Switch chia nhánh Layer 2 (08 Cổng LAN) | L2 Switch 8P | Cái | **05** |
| 6 | Network | Bộ phát Wifi Access Point ốp trần | Access Point | Bộ | **08** |
| 7 | Network | Thanh quản lý cáp & Patch Panel Cat6 | Patch Panel / CM | Thanh | **14** |
| 8 | Network | Ổ cắm mạng âm sàn | 01 LAN Floor Outlet | Bộ | **58** |
| 9 | Network | Ổ cắm mạng âm tường đơn | 01 LAN Wall Outlet | Bộ | **22** |
| 10 | Network | Ổ cắm mạng âm tường đôi | 02 LAN Wall Outlet | Bộ | **04** |
| 11 | Network | Ổ cắm hỗn hợp Mạng & Điện thoại | 01 LAN + 01 TEL Wall | Bộ | **03** |
| 12 | Network | Ổ cắm 04 Cổng mạng âm tường | 04 LAN Wall Outlet | Bộ | **06** |
| 13 | Network | Cụm ổ cắm 06 Cổng mạng âm tường | 06 LAN Wall Outlet | Bộ | **01** |
| 14 | Network | Bộ chuyển đổi quang điện | Media Converter Network | Cái | **04** |
| 15 | Network | Hộp phối cáp quang trung tâm & nhánh | ODF Fiber Box | Cái | **09** |
| 16 | Network | Bộ lưu điện UPS cấp nguồn dự phòng IT | UPS | Cái | **09** |
| 17 | Network | Tủ Rack chứa thiết bị mạng (42U / 27U) | Rack Cabinet | Cái | **09** |
| 18 | PBX | Tổng đài điện thoại IP PBX trung tâm | IP PBX | Cái | **01** |
| 19 | PBX | Điện thoại bàn IP Phone | IP Phone | Cái | **23** |

### II. Hệ Thống Camera Giám Sát An Ninh (CCTV System)
| STT | Phân Hệ | Tên Thiết Bị / Hạng Mục Kỹ Thuật | Ký Hiệu / Model | Đơn Vị | Số Lượng |
| :---: | :--- | :--- | :---: | :---: | :---: |
| 20 | CCTV | Switch PoE L2 16 Cổng (Cấp nguồn Camera) | L2 Switch PoE 16P | Cái | **04** |
| 21 | CCTV | Switch PoE L2 08 Cổng (Cấp nguồn Camera) | L2 Switch PoE 8P | Cái | **07** |
| 22 | CCTV | Switch CCTV Trung Tâm 24 Port | L2 Main Switch 24P | Cái | **01** |
| 23 | CCTV | Đầu ghi hình Camera IP trung tâm (64CH & 32CH) | NVR Hikvision | Cái | **02** |
| 24 | CCTV | Camera IP thân trụ ngoài trời | IP Bullet Outdoor Camera | Cái | **30** |
| 25 | CCTV | Camera IP bán cầu trong nhà | IP Dome Indoor Camera | Cái | **48** |
| 26 | CCTV | Camera IP chống cháy nổ ngoài trời | IP Bullet Flame Camera | Cái | **02** |
| 27 | CCTV | Camera IP đặc biệt chống nổ kho hóa chất | Explosion-Proof Bullet | Cái | **01** |
| 28 | CCTV | Máy tính giám sát an ninh | CCTV PC Client | Bộ | **01** |
| 29 | CCTV | Màn hình hiển thị giám sát 50 inch | Monitor 50" | Cái | **03** |
| 30 | CCTV | Bộ chuyển đổi quang điện Camera | Media Converter CCTV | Bộ | **18** |
| 31 | CCTV | Hộp phối cáp quang ODF Camera | ODF CCTV | Cái | **18** |
| 32 | CCTV | Thanh quản lý cáp CCTV | Cable Mgmt CCTV | Thanh | **11** |
| 33 | CCTV | Cột gắn Camera ngoài sân | Camera Pole | Cột | **11** |
| 34 | CCTV | Tủ điện ngoài trời chống nước | Outside Cabinet Box 01 | Tủ | **01** |
| 35 | CCTV | Hố ga chứa cáp viễn thông ngầm | Manhole 01 ~ 11 | Hố | **11** |

### III. Hệ Thống Chấm Công & Kiểm Soát Ra Vào (TA/AC System)
| STT | Phân Hệ | Tên Thiết Bị / Hạng Mục Kỹ Thuật | Ký Hiệu / Model | Đơn Vị | Số Lượng |
| :---: | :--- | :--- | :---: | :---: | :---: |
| 36 | TA/AC | Máy chấm công nhận diện khuôn mặt / vân tay | Time Attendance | Cái | **05** |
| 37 | TA/AC | Đầu đọc kiểm soát ra vào cửa | Access Control | Cái | **16** |
| 38 | TA/AC | Cổng xoay Barie phân làn tự động Nhà xe | Flapgate Barie | Làn | **06** |
| 39 | TA/AC | Khóa từ hút an toàn cửa kính/gỗ | Doorlock Magnetic | Cái | **06** |
| 40 | TA/AC | Nút nhấn khẩn cấp mở cửa | Exit Button | Cái | **06** |
| 41 | TA/AC | Máy tính Server quản lý chấm công & nhân sự | TA/AC Server PC | Bộ | **01** |
| 42 | TA/AC | Hàng rào Inox phân làn cổng vào nhà xe | Inox Fence | Bộ | **02** |
| 43 | TA/AC | Thiết bị lấy mẫu dữ liệu khuôn mặt nhân viên | Faces Sample Device | Cái | **01** |
| 44 | TA/AC | Switch chia cổng L2 16 Port (Flapgate Barie) | L2 Switch 16P | Cái | **01** |
| 45 | TA/AC | Switch chia cổng L2 08 Port (Mạng TA/AC) | L2 Switch 8P | Cái | **02** |

### IV. Hệ Thống Âm Thanh Thông Báo (PA System)
| STT | Phân Hệ | Tên Thiết Bị / Hạng Mục Kỹ Thuật | Ký Hiệu / Model | Đơn Vị | Số Lượng |
| :---: | :--- | :--- | :---: | :---: | :---: |
| 46 | PA | Bộ hẹn giờ phát thanh tự động ca giờ | Program Timer TT-104B | Cái | **01** |
| 47 | PA | Đầu phát nhạc nền CD/USB | CD Player | Cái | **01** |
| 48 | PA | Bộ tăng âm công suất trung tâm | Main Amplifier | Cái | **01** |
| 49 | PA | Bộ tăng âm mở rộng công suất | Amplifier Extension | Cái | **01** |
| 50 | PA | Micro thông báo từ xa chọn vùng | Remote Microphone | Cái | **01** |
| 51 | PA | Loa âm trần khu văn phòng | Ceiling Speaker | Cái | **56** |
| 52 | PA | Loa hộp treo tường khu xưởng | Wall Speaker | Cái | **36** |
| 53 | PA | Loa nén phóng thanh nhà xe & ngoài sân | Horn Speaker | Cái | **04** |
| 54 | PA | Tủ Rack đựng thiết bị âm thanh PA | PA Rack Cabinet 27U | Tủ | **01** |

### V. Hệ Thống Tiếp Địa & Cáp Quang ISP (Grounding & ISP)
| STT | Phân Hệ | Tên Thiết Bị / Hạng Mục Kỹ Thuật | Ký Hiệu / Model | Đơn Vị | Số Lượng |
| :---: | :--- | :--- | :---: | :---: | :---: |
| 55 | Grounding | Hộp kiểm tra tiếp địa điện nhẹ Tầng 1 | Testing Box | Hộp | **01** |
| 56 | ISP Line | Tủ phối quang nhà mạng ISP đầu vào | ISP ODF Box | Tủ | **01** |

---

## 3. SƠ ĐỒ NGUYÊN LÝ KỸ THUẬT 6 PHÂN HỆ ĐIỆN NHỆ CHÍNH

### 3.1. Sơ Đồ Nguyên Lý Mạng LAN & Tường Lửa FortiGate 100E (Bản vẽ 42/06)

```
[TỦ ODF CÁP QUANG ĐẦU VÀO ISP] (Nhận cáp quang Viettel / VNPT kéo ngầm từ Hố ga ngoài đường vào)
                 │
                 ▼ (Dây nhảy Cáp quang Patchcord)
[TƯỜNG LỬA BẢO MẬT TRUNG TÂM: FORTIGATE 100E] (Đặt tại Server Room Tầng 2 - Tủ RACK IT)
 ├── Port Mgmt  ──► PC Quản trị IT (Cấu hình Out-of-Band 192.168.1.99)
 ├── Port WAN 1 ──► Kết nối Cáp quang ISP 1 (Viettel - Đường chính)
 ├── Port WAN 2 ──► Kết nối Cáp quang ISP 2 (VNPT - Đường dự phòng Failover)
 ├── Port HA 1  ──► Kết nối Tường lửa dự phòng đôi (High Availability Active-Passive)
 ├── Port DMZ   ──► Server MES Vinatech / Server Web nội bộ
 └── Port LAN   ──► [1 SỢI CÁP MẠNG TRUNK LINK UTP DUY NHẤT (ĐƯỜNG XANH NHẠT TRÊN BẢN VẼ)]
                 │   (Gom toàn bộ lưu lượng dữ liệu 802.1Q VLAN Tagging qua 1 cổng duy nhất)
                 ▼
[SWITCH CHUYỂN MẠCH TRUNG TÂM: L3 SWITCH 24 PORT] (Nối đất tiếp địa ⏚ vỏ thiết bị)
                 │
   ┌─────────────┼─────────────┬─────────────┬─────────────┐ (Truyền dẫn cáp quang Backbone ODF)
   ▼             ▼             ▼             ▼             ▼
[RACK 01 - 1F] [RACK 02 - 1F] [RACK 03 - 1F] [RACK 04 - 2F] [RACK 05~08]
(Switch L2 48P)(Switch L2 48P)(Switch L2 24P)(Switch L2 48P)(E-Parking & Guardhouses)
   │             │             │             │             │
   ▼ (Cat6 UTP)  ▼ (Cat6 UTP)  ▼ (Cat6 UTP)  ▼ (Cat6 UTP)  ▼ (Cat6 UTP)
 Ổ cắm LAN/Tel Ổ cắm LAN/Tel Ổ cắm LAN/Tel Ổ cắm LAN/Tel Ổ cắm LAN/Tel
 58 Bộ (Văn phòng Tầng 2) & Cụm Ổ cắm Chuyền Sản Xuất Tầng 1, 1.5, 3
```

> 💡 **Phân tích kỹ thuật chuyên sâu:** 
> 1. Trên bản vẽ CAD 42/06, giữa FortiGate 100E và L3 Core Switch chỉ thể hiện **đúng 1 sợi cáp mạng UTP (đường màu xanh nhạt)**. Đây là đường **Trunk Link** chạy giao thức IEEE 802.1Q Tagging giúp truyền dẫn đồng thời nhiều dải mạng (VLAN Văn phòng, VLAN Xưởng, VLAN Camera, VLAN MES...) qua 1 cổng cáp duy nhất mà không bị lẫn lộn.
> 2. Ký hiệu **⏚ (3 đường ngang ngắn dần ở đáy tủ)** xuất hiện ở góc tủ đại diện cho dây đồng tiếp địa rò điện rò nhiễu nối về bãi tiếp địa ELV R < 1 Ohm.

---

### 3.2. Sơ Đồ Nguyên Lý Camera Giám Sát CCTV (Bản vẽ 42/07)
* **Đầu ghi hình trung tâm:** 02 Đầu ghi NVR Hikvision (1 con NVR 64 kênh + 1 con NVR 32 kênh) đặt tại Server Room Tầng 2.
* **Switch CCTV Trung Tâm:** L2 Main Switch CCTV 24 Port nhận cáp quang từ 18 bộ Media Converter & ODF Camera.
* **Phân bổ Camera:**
  - **48 Camera IP Dome Indoor (Trong nhà):** Phân bổ tại trần hành lang văn phòng Tầng 2 và trần xưởng sản xuất Tầng 1, 1.5, 2, 3.
  - **30 Camera IP Bullet Outdoor (Thân ngoài trời IP66/IP67):** Gắn trên 11 Cột Camera Pole ngoài sân, cổng bảo vệ và xung quanh tường rào nhà máy.
  - **02 Camera IP Bullet Flame (Chống cháy):** Gắn tại các dải thiết bị nhạy cảm nhiệt độ cao.
  - **01 Camera IP Explosion-Proof (Chống nổ đặc biệt):** Gắn tại Kho Hóa Chất.

---

### 3.3. Sơ Đồ Nguyên Lý Chấm Công & Kiểm Soát Cửa TA/AC (Bản vẽ 42/08)
* **Máy chấm công (05 cái):** Đặt tại các cửa vào xưởng Tầng 1, 2, 3 và khu Nhà xe E-Parking kết nối về Server PC Phòng HR/IT.
* **Access Control (16 cửa):** Lắp đặt tại cửa Server Room Tầng 2, Phòng IT, Phòng Giám Đốc, Kho Hóa Chất. Mỗi hệ thống cửa bao gồm: Đầu đọc AC, Khóa từ Magnetic Lock, Nút nhấn thoát hiểm Exit Button.
* **Cổng Barie Flapgate (06 làn):** Lắp đặt tại E-Parking kết nối về Switch L2 16 Port riêng để đọc thẻ/khuôn mặt công nhân và đóng mở hàng rào Inox tự động.

---

### 3.4. Sơ Đồ Nguyên Lý Âm Thanh Thông Báo PA (Bản vẽ 42/09)
* **Tủ Rack PA (27U D800):** Đặt tại Phòng IT Tầng 2, chứa Bộ hẹn giờ ca giờ **Program Timer TT-104B**, CD Player, Main Amplifier, Extension Amplifier và Remote Microphone.
* **Phân vùng âm thanh (Zone Selector):**
  - **Vùng 1 (Khối Văn Phòng Tầng 2):** 56 Loa âm trần Ceiling Speaker (Phát nhạc nền & thông báo).
  - **Vùng 2 (Khối Xưởng Tầng 1, 1.5, 2, 3):** 36 Loa hộp Wall Speaker (Phát thông báo ca giờ & báo động khẩn cấp).
  - **Vùng 3 (Khu Ngoài Trời & E-Parking):** 04 Loa nén phóng thanh Horn Speaker (Thông báo nhà xe & sân bãi).

---

### 3.5. Sơ Đồ Tiếp Địa Chống Nhiễu ELV Grounding (Bản vẽ 42/36 & 42/42)
* **Bãi cọc tiếp địa chuyên dụng:** Hệ thống cọc đồng tiếp địa 2.4m chôn ngầm dưới đất ngoài trời, đảm bảo điện trở tiếp địa R < 1 Ohm.
* **Tuyến dây tiếp địa:** Dây đồng trần M70/M50 luồn trong ống PVC từ bãi cọc đi lên **Hộp kiểm tra tiếp địa Testing Box** ở Tầng 1 -> Đi lên **Thanh Busbar Đồng** trong Phòng Server Room Tầng 2.
* **Kết nối bảo vệ:** 
  - Dây Cu/PVC 1x16mm² nối vỏ Tủ Rack IT Main Server Room.
  - Dây Cu/PVC 1x10mm² nối vỏ cho toàn bộ 10 Tủ Rack tầng/nhà xe/bảo vệ và Thang máng cáp Cable Tray.

---

### 3.6. Tuyến Cáp Quang Viễn Thông ISP & Hạ Tầng Ngầm (Bản vẽ 42/37 & 42/40)
* **Đường mạng ISP đầu vào:** Tuyến cáp quang ngầm đi trong **Ống HDPE D42/50mm** luồn trong ống thép D60mm chạy qua 11 Hố ga (**Manhole 01 ~ 11**) ngoài đường chính vào khuôn viên nhà máy -> Đi lên Tủ ODF ISP trong Phòng Server Tầng 2.
* **Cơ chế dự phòng:** Đấu nối đồng thời 2 đường cáp quang độc lập (Viettel & VNPT) vào cổng WAN 1 và WAN 2 trên Tường lửa FortiGate 100E.

---

## 4. BẢNG CHI TIẾT 11 TỦ RACK MẠNG & SƠ ĐỒ CÁP QUANG TRỤC CHÍNH (BACKBONE CORE MAP)

### 4.1. Bản Đồ Phân Bổ Số Lõi Cáp Quang Trục Chính (Trang 42/38 & 42/39)
| Tuyến Cáp Quang Từ Tủ IT Main (Server Room 2F) Đến | Cáp Quang Mạng (Network Backbone 42/38) | Cáp Quang Camera (CCTV Backbone 42/39) |
| :--- | :---: | :---: |
| **RACK 01 - 1F** (Xưởng Tầng 1) | Cáp quang 8-Core (x1) | Cáp quang 8-Core (x1) |
| **RACK 02 - 1F** (Xưởng Tầng 1) | Cáp quang 8-Core (x2) | Cáp quang 8-Core (x2) |
| **RACK 03 - 1F** (Xưởng Tầng 1) | Cáp quang 4-Core (x1) | Cáp quang 4-Core (x1) |
| **RACK 04 - 2F** (Xưởng Tầng 2) | Cáp quang 8-Core (x2) | Cáp quang 8-Core (x3) |
| **RACK 05 - E-PARKING** (Khu Nhà Xe) | Cáp quang 8-Core (x5) | Cáp quang 8-Core (x6) |
| **RACK 06 - GUARDHOUSE 1** (Cổng 1) | Cáp quang 8-Core (x1) | Cáp quang 8-Core (x1) |
| **RACK 07 - GUARDHOUSE 2** (Cổng 2) | Cáp quang 8-Core (x1) | Cáp quang 8-Core (x1) |
| **RACK 08 - GUARDHOUSE 3** (Cổng 3) | Cáp quang 8-Core (x1) | Cáp quang 8-Core (x1) |
| **RACK 09 - UTILITY** (Khu Phụ Trợ) | Cáp quang 8-Core (x1) | Cáp quang 8-Core (x1) |

---

### 4.2. Danh Mục Chi Tiết Thiết Bị Trong 11 Tủ Rack & Tủ Outdoor (Trang 42/11)

1. **RACK MAIN IT ROOM (42U D1000) - Server Room Tầng 2 Office [⏚ Tiếp Địa]:**
   - `U40-U42`: NW-CCTV ODF 52 Port (Khung phối cáp quang trung tâm 52 cổng)
   - `U38-U39`: ISP ODF 08 Port (Khung phối cáp quang nhà mạng Viettel/VNPT)
   - `U36-U37`: Tường lửa FortiGate 100E Firewall (WAN1/WAN2 cắm ODF ISP)
   - `U34-U35`: Cisco L3 Core Switch 24P (Cắm 1 cáp Trunk Link UTP xanh nhạt lên FortiGate)
   - `U31-U33`: Main Switch CCTV 24 Port & L2 Switch 48 Port
   - `U25-U30`: 14 Thanh Patch Panel Cat6 & Cable Management
   - `U20-U24`: Tổng đài điện thoại IP PBX trung tâm
   - `U15-U19`: Đầu ghi hình NVR 64CH & NVR 32CH Hikvision
   - `U01-U06`: Bộ lưu điện UPS Trung tâm & Pack Pin dự phòng

2. **RACK PA IT ROOM (27U D800) - Phòng IT Tầng 2 [⏚ Tiếp Địa]:**
   - `U24-U26`: CCTV ODF 04 Port
   - `U20-U23`: Switch PoE L2 08 Port
   - `U15-U19`: Bộ hẹn giờ phát thanh ca giờ Program Timer TT-104B
   - `U12-U14`: Đầu phát nhạc nền CD-Player & Remote Microphone
   - `U06-U11`: Bộ tăng âm công suất chính (Main Amplifier)
   - `U01-U05`: Bộ tăng âm công suất mở rộng (Amplifier Extension)

3. **RACK 01 & RACK 02 (27U D800) - Tầng 1 Xưởng [⏚ Tiếp Địa]:**
   - `U22-U24`: NW-CCTV ODF 08 Port
   - `U18-U21`: Patch Panel Cat6 & Cable Management
   - `U14-U17`: Switch mạng L2 48 Port
   - `U10-U13`: Switch PoE Camera L2 16 Port
   - `U06-U09`: Switch chia nhánh L2 08 Port
   - `U01-U05`: Bộ lưu điện UPS Local

4. **RACK 03 (1F) & RACK 04 (2F) - Xưởng Sản Xuất [⏚ Tiếp Địa]:**
   - `U22-U24`: ODF 12 Port (Rack 03) / ODF 08 Port (Rack 04)
   - `U18-U21`: Patch Panel Cat6 & Cable Management
   - `U14-U17`: Switch L2 24P (Rack 03) / Switch L2 48P (Rack 04)
   - `U10-U13`: Switch PoE Camera L2 16 Port
   - `U01-U05`: UPS Local & Media Converter

5. **RACK 05 (NHÀ XE E-PARKING 10U/27U) [⏚ Tiếp Địa]:**
   - `U22-U24`: NW-CCTV ODF 16 Port
   - `U18-U21`: Switch Barie Flapgate L2 16 Port
   - `U14-U17`: Switch PoE Camera L2 08 Port
   - `U10-U13`: Switch mạng chấm công AC L2 08 Port & L2 8P
   - `U01-U05`: Media Converter (x2) & UPS Local

6. **RACK 06, 07, 08 (CỔNG BẢO VỆ 1, 2, 3) & RACK 09 (UTILITY) [⏚ Tiếp Địa]:**
   - `U08-U10`: ODF 08 Port / 16 Port / 04 Port
   - `U05-U07`: Switch L2 08 Port (Nối PC & IP Phone bảo vệ)
   - `U02-U04`: Switch PoE L2 08 Port (Nối Camera cổng)
   - `U01`: Media Converter & Nguồn Adapter DC12V

7. **BOX 01 OUTSIDE (TỦ ĐIỆN NGOÀI TRỜI CỘT CAMERA):**
   - Chứa Nguồn Adapter DC12V & Bộ chuyển đổi quang điện Media Converter cấp nguồn cho Camera ngoài sân.

---

## 5. BẢNG PHÂN BỔ CHI TIẾT ĐIỂM MẠNG (NODE LAN/TEL) & MÁNG CÁP THEO TẦNG
*(Tổng hợp từ Bản vẽ 42/12 ~ 42/17 & 42/33 ~ 42/35)*

| Tầng / Khu Vực | Số Bản Vẽ CAD | Số Lượng Điểm Mạng LAN / TEL Chi Tiết | Tủ Rack Đấu Nối | Quy Cách Tuyến Máng Cáp IT |
| :--- | :---: | :--- | :---: | :--- |
| **Tầng 1 Nhà Xưởng** | 42/12 & 42/33 | • 16 Bộ Ổ cắm mạng âm tường (01 LAN Wall)<br>• 04 Bộ Ổ cắm mạng đôi (02 LAN Wall)<br>• 01 Bộ Cụm ổ cắm 06 LAN Wall (Phòng quản lý)<br>• Cấp mạng dải chuyền 130 Packing, 131 Formation, 132/133 Assembly | RACK 01, RACK 02, RACK 03 (1F) | Cable Tray 300x100mm & 200x100mm mạ kẽm chạy dọc xưởng |
| **Tầng 1.5 Nhà Xưởng** | 42/13 | • 03 Bộ Ổ cắm mạng âm tường (01 LAN Wall)<br>• 19 Bộ Ổ cắm mạng âm sàn (01 LAN Floor)<br>• Cấp mạng máy móc xưởng phụ trợ | RACK MAIN 2F & RACK 04 | Máng cáp nhánh 100x50mm & Ống luồng cáp PVC D25/D32 |
| **Tầng 2 Văn Phòng & Xưởng** | 42/14 & 42/34 | • 39 Bộ Ổ cắm mạng âm sàn (01 LAN Floor - Cụm bàn làm việc)<br>• 01 Bộ Ổ cắm mạng âm tường (01 LAN Wall)<br>• 02 Bộ Ổ cắm 04 Cổng mạng (04 LAN Wall - Server/IT Room)<br>• 08 Bộ Phát Wi-Fi Access Point gắn trần văn phòng | RACK MAIN IT ROOM (42U) & RACK 04 | Cable Tray 300x100mm chạy trục hành lang văn phòng |
| **Tầng 3 Nhà Xưởng** | 42/15 | • 01 Bộ Ổ cắm mạng âm tường (01 LAN Wall)<br>• Cấp mạng máy chủ quản lý hạ tầng tầng mái | RACK MAIN 2F | Máng cáp 100x50mm luồn ống PVC âm trần |
| **Nhà Xe E-Parking** | 42/16 & 42/35 | • 01 Bộ Ổ cắm mạng âm tường (01 LAN Wall)<br>• Kết nối 06 Làn Barie Flapgate tự động<br>• Kết nối 02 Cổng đọc thẻ & Camera biển số | RACK 05 (E-Parking) | Tuyến ống ngầm HDPE D42/50 luồn trong hố ga Manhole |
| **3 Cổng Bảo Vệ (Guardhouses)** | 42/17 | • 03 Bộ Ổ cắm tích hợp Mạng & TEL (01 LAN + 01 TEL Wall)<br>• Điện thoại IP Phone phục vụ liên lạc cổng an ninh | RACK 06, RACK 07, RACK 08 | Tuyến cáp quang ngầm đi qua Pipe Rack & Hố ga Manhole 01~11 |

---

## 6. DANH MỤC ĐẦY ĐỦ 43 TRANG BẢN VẼ KỸ THUẬT CAD

| Trang PDF | Số Bản Vẽ CAD | Tên Bản Vẽ Kỹ Thuật (Tiếng Anh / Tiếng Việt) | Phân Hệ Hạ Tầng |
| :---: | :---: | :--- | :---: |
| **Trang 01** | `42/01` | Drawing List (1) / Danh mục bản vẽ phần 1 | Hạ tầng tổng hợp |
| **Trang 02** | `42/02` | Drawing List (2) / Danh mục bản vẽ phần 2 | Hạ tầng tổng hợp |
| **Trang 03** | `42/03` | Product Quantity Summary / Bảng thống kê số lượng vật tư thiết bị (BOM) | Toàn hệ thống |
| **Trang 04** | `42/04` | Details Installation (1) / Chi tiết lắp đặt Ổ cắm LAN/TEL, Camera, Wifi | Chi tiết thi công |
| **Trang 05** | `42/05` | Details Installation (2) / Chi tiết lắp đặt Máy chấm công, Loa, Tủ Rack | Chi tiết thi công |
| **Trang 06** | `42/06` | Diagram Network & PBX / Sơ đồ nguyên lý Mạng LAN & Tổng đài PBX | Network Diagram |
| **Trang 07** | `42/07` | Diagram CCTV / Sơ đồ nguyên lý Hệ thống Camera giám sát | CCTV Diagram |
| **Trang 08** | `42/08` | Diagram TA/AC / Sơ đồ nguyên lý Chấm công & Kiểm soát ra vào cửa | TA/AC Diagram |
| **Trang 09** | `42/09` | Diagram Speaker (PA) / Sơ đồ nguyên lý Hệ thống Âm thanh thông báo | PA Diagram |
| **Trang 10** | `42/10` | Diagram Power / Sơ đồ nguyên lý Cấp nguồn cho tủ IT & Điện nhẹ | Power Diagram |
| **Trang 11** | `42/11` | Diagram Rack / Sơ đồ bố trí thiết bị trong 11 Tủ Rack IT | Rack Elevation |
| **Trang 12** | `42/12` | 1st Floor Factory Network & PBX / Mặt bằng Mạng LAN & PBX Tầng 1 | Floor Plan 1F |
| **Trang 13** | `42/13` | 1.5 Floor Factory Network & PBX / Mặt bằng Mạng LAN & PBX Tầng 1.5 | Floor Plan 1.5F |
| **Trang 14** | `42/14` | 2nd Floor Factory Network & PBX / Mặt bằng Mạng LAN & PBX Tầng 2 | Floor Plan 2F |
| **Trang 15** | `42/15` | 3rd Floor Factory Network & PBX / Mặt bằng Mạng LAN & PBX Tầng 3 | Floor Plan 3F |
| **Trang 16** | `42/16` | Network & PBX E-Parking / Mặt bằng Mạng LAN Nhà xe | Outdoor Network |
| **Trang 17** | `42/17` | Network & PBX Guardhouse 1, 2, 3 / Mặt bằng Mạng LAN 3 Cổng Bảo vệ | Outdoor Network |
| **Trang 18** | `42/18` | CCTV Master Plan / Mặt bằng tổng thể vị trí Camera ngoài trời | CCTV Master |
| **Trang 19** | `42/19` | 1st Floor Factory CCTV / Mặt bằng Camera Tầng 1 | CCTV Floor 1F |
| **Trang 20** | `42/20` | 1.5 Floor Factory CCTV / Mặt bằng Camera Tầng 1.5 | CCTV Floor 1.5F |
| **Trang 21** | `42/21` | 2nd Floor Factory CCTV / Mặt bằng Camera Tầng 2 | CCTV Floor 2F |
| **Trang 22** | `42/22` | 3rd Floor Factory CCTV / Mặt bằng Camera Tầng 3 | CCTV Floor 3F |
| **Trang 23** | `42/23` | CCTV E-Parking & Guardhouse / Mặt bằng Camera Nhà xe & Bảo vệ | Outdoor CCTV |
| **Trang 24** | `42/24` | 1st Floor Factory PA / Mặt bằng Loa thông báo Tầng 1 | PA Floor 1F |
| **Trang 25** | `42/25` | 1.5 Floor Factory PA / Mặt bằng Loa thông báo Tầng 1.5 | PA Floor 1.5F |
| **Trang 26** | `42/26` | 2nd Floor Factory PA / Mặt bằng Loa thông báo Tầng 2 | PA Floor 2F |
| **Trang 27** | `42/27` | 3rd Floor Factory PA / Mặt bằng Loa thông báo Tầng 3 | PA Floor 3F |
| **Trang 28** | `42/28` | PA E-Parking / Mặt bằng Loa thông báo Nhà xe | Outdoor PA |
| **Trang 29** | `42/29` | PA Guardhouse / Mặt bằng Loa thông báo Cổng bảo vệ | Outdoor PA |
| **Trang 30** | `42/30` | 1st Floor Factory TA/AC / Mặt bằng Máy chấm công & Cửa Tầng 1 | TA/AC Floor 1F |
| **Trang 31** | `42/31` | 1.5 Floor Factory TA/AC / Mặt bằng Máy chấm công Tầng 1.5 | TA/AC Floor 1.5F |
| **Trang 32** | `42/32` | 2nd Floor Factory TA/AC / Mặt bằng Kiểm soát cửa Tầng 2 | TA/AC Floor 2F |
| **Trang 33** | `42/33` | 1st Floor Factory Cable Tray / Mặt bằng Máng cáp Tầng 1 | Cable Tray 1F |
| **Trang 34** | `42/34` | 2nd Floor Factory Cable Tray / Mặt bằng Máng cáp Tầng 2 | Cable Tray 2F |
| **Trang 35** | `42/35` | Flap Barie E-Parking / Chi tiết Cổng Barie phân làn Nhà xe | E-Parking Barie |
| **Trang 36** | `42/36` | 1st Floor Grounding / Mặt bằng Tiếp địa Điện nhẹ Tầng 1 | Grounding 1F |
| **Trang 37** | `42/37` | ISP Line Master Plan / Mặt bằng Tuyến cáp quang Viễn thông ISP | ISP Master |
| **Trang 38** | `42/38` | Backbone Master Plan (Network) / Mặt bằng Trục cáp quang Mạng | Network Backbone |
| **Trang 39** | `42/39` | Backbone Master Plan (Camera) / Mặt bằng Trục cáp quang Camera | CCTV Backbone |
| **Trang 40** | `42/40` | Speaker Master Plan / Mặt bằng Tuyến cáp ngầm HDPE ngoài sân | HDPE Master |
| **Trang 41** | `42/41` | Power Master Plan / Mặt bằng Tuyến cáp nguồn Tủ IT | Power Master |
| **Trang 42** | `42/42` | Grounding Master Plan / Tổng mặt bằng Tiếp địa toàn nhà máy | Grounding Master |
| **Trang 43** | `N/A` | Trang Phụ lục Khung tên Dự án & Chữ ký Duyệt thiết kế | General Info |

---

## 7. QUY TRÌNH HƯỚNG DẪN DÀNH CHO IT VẬN HÀNH & XỬ LÝ SỰ CỐ

### 🛠️ Kịch bản 1: Mất kết nối mạng một máy tính / dải chuyền sản xuất
1. Kiểm tra đèn báo trên ổ cắm mạng (Wall Outlet / Floor Outlet).
2. Tra mặt bằng tầng (**Trang 12 ~ 15**) để xác định ổ cắm đó kéo cáp Cat6 về **RACK 01, RACK 02 hay RACK 04**.
3. Đến Tủ Rack tầng kiểm tra: Đèn nguồn Switch L2, đèn cổng cắm Patch Panel, bộ nguồn dự phòng UPS.
4. Nếu cả Tủ Rack bị suy hao tín hiệu: Kiểm tra đèn `FX/Link` trên bộ **Media Converter / ODF** trong tủ Rack xem tuyến cáp quang Backbone về Server Room Tầng 2 có bị đứt không.

### 🛠️ Kịch bản 2: Camera ngoài sân / cổng bảo vệ bị đứt tín hiệu
1. Mở **Trang 18 (CCTV Master Plan)** tra vị trí Camera thuộc Cột ngoài trời số mấy (**Camera Pole 01 ~ 11**).
2. Kiểm tra **BOX 01 Outdoor** xem nguồn cấp 220V/PoE và Bộ chuyển đổi Media Converter còn hoạt động không.
3. Tra tuyến cáp quang ngầm đi qua hố ga **Manhole 01 ~ 11** về Tủ ODF Camera tại Server Room.

### 🛠️ Kịch bản 3: Sự cố Cổng Barie Flapgate / Máy chấm công Nhà xe
1. Tra **Trang 35 (Flap Barie E-Parking)** và **Trang 16 (Network E-Parking)**.
2. Kiểm tra **RACK 05** đặt tại E-Parking: Kiểm tra Switch L2 16 Port cấp kết nối Barie và Switch AC L2 8 Port.
3. Kiểm tra nguồn điện 12V/24V DC cấp cho đầu đọc thẻ và bộ khóa từ Barie.

---
*Hồ sơ kỹ thuật hạ tầng Điện Nhẹ IT được tổng hợp & việt hóa hoàn chỉnh từ Hồ sơ thiết kế thi công Nhà máy Vinatech Vina Hưng Yên v5.2.*
