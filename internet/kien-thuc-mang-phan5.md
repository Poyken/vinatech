# 📚 HỆ THỐNG KIẾN THỨC MẠNG — Phần 5: BẢO MẬT NÂNG CAO & QUẢN LÝ MẠNG NHÀ MÁY

> 🎯 **Mục tiêu:** Hiểu cách tăng cường bảo mật thực tế cho nhà máy, quản lý thiết bị từ xa, giám sát mạng, và các bước nâng cấp hạ tầng theo thứ tự ưu tiên.

> ⬅️ **Trước đó:** [Phần 4 — Chẩn đoán & Xử lý sự cố](./kien-thuc-mang-phan4.md)

---

## Chương 34: Đánh giá hiện trạng bảo mật nhà máy bạn

### 34.1 Điểm mạnh hiện có

```
✅ Có Fortinet FortiGate (lớp bảo vệ tốt từ Internet)
✅ Dùng HTTPS (HTTPS/443) khi duyệt web
✅ Microsoft Defender đang chạy
✅ DHCP tập trung (Fortinet quản lý IP)
✅ 34 thiết bị đang hoạt động ổn định
```

### 34.2 Điểm yếu cần cải thiện (theo thứ tự ưu tiên)

```
🔴 ƯU TIÊN CAO:
  1. Port 445 (SMB) mở toàn bộ LAN
     → Nguy cơ: WannaCry, NotPetya lây lan nội bộ
     → Xử lý ngay được, không tốn tiền

  2. Không có VLAN
     → Nguy cơ: 1 thiết bị bị nhiễm → cả nhà máy
     → Cần switch Managed

  3. Windows chưa cập nhật đầy đủ
     → Kiểm tra ngay: Windows Update → xem có bản vá bảo mật chưa

🟡 ƯU TIÊN TRUNG BÌNH:
  4. PostgreSQL lắng nghe 0.0.0.0 (mở cho cả LAN)
     → Chỉ nên mở 127.0.0.1 hoặc IP cụ thể

  5. Camera không có xác thực 2 lớp
     → Đổi mật khẩu mặc định, bật HTTPS camera

  6. Không có log audit
     → Bật Event Logging trên Windows

🟢 ƯU TIÊN THẤP (dài hạn):
  7. Không có Domain Controller
     → Xem xét Windows Active Directory
  
  8. Không có NMS (Network Monitoring System)
     → SNMP + Zabbix hoặc PRTG để giám sát
```

---

## Chương 35: Tăng cường bảo mật — Các bước làm ngay

### 35.1 Tắt SMBv1 — Làm ngay, miễn phí

**SMBv1 là giao thức chia sẻ file cũ** (từ Windows XP) có lỗ hổng nghiêm trọng. WannaCry 2017 lây qua đây, làm tê liệt hàng trăm nghìn máy tính toàn cầu.

```powershell
# Kiểm tra SMBv1 có đang bật không (chạy với quyền Admin):
Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol

# Nếu State: Enabled → TẮT NGAY:
Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart

# Kiểm tra lại:
Get-SmbServerConfiguration | Select EnableSMB1Protocol
# Kết quả: False = đã tắt ✅
```

**Tắt SMBv1 trên tất cả máy trong nhà máy** — gửi script này cho mọi người hoặc dùng Group Policy nếu có Domain.

### 35.2 Cập nhật Windows — Bắt buộc

```
Windows Update hoạt động như vắc-xin:
  Hacker phát hiện lỗ hổng → Microsoft vá → Update → Máy của bạn an toàn
  Không update → Máy bạn vẫn có lỗ hổng dù Microsoft đã vá rồi!

Làm ngay:
  1. Settings → Windows Update → Check for updates
  2. Cài tất cả bản vá bảo mật (không cần cài preview/optional)
  3. Đặt lịch tự update ngoài giờ làm việc: 2:00 AM thứ 4 hàng tuần
```

### 35.3 Khóa PostgreSQL — 5 phút làm xong

```
Hiện tại: PostgreSQL lắng nghe 0.0.0.0:5432 → bất kỳ máy trong LAN có thể kết nối

Sửa file postgresql.conf:
  Tìm dòng: listen_addresses = '*'
  Đổi thành: listen_addresses = 'localhost'
  (hoặc: listen_addresses = '127.0.0.1, 192.168.125.100')

Sau đó restart PostgreSQL:
  net stop postgresql-x64-14   (hoặc phiên bản của bạn)
  net start postgresql-x64-14

Kiểm tra:
  netstat -an | findstr 5432
  Nên thấy: 127.0.0.1:5432 LISTENING (không còn 0.0.0.0 nữa)
```

### 35.4 Đổi mật khẩu camera Hikvision

Camera Hikvision xuất xưởng với mật khẩu mặc định → hacker biết hết → phải đổi ngay.

```
Vào web interface camera: http://192.168.125.6
  User: admin | Pass: (mặc định thường là admin hoặc 12345)

Sau khi đăng nhập:
  Configuration → System → User Management
  → Đổi mật khẩu admin thành mật khẩu mạnh (>12 ký tự, có số + ký tự đặc biệt)

Ngoài ra:
  Configuration → Network → Advanced → HTTPS
  → Bật HTTPS để kết nối mã hóa
```

---

## Chương 36: VLAN — Kế hoạch triển khai thực tế

### 36.1 Thiết bị cần mua

**Để có VLAN, bạn cần:**
- **Switch Managed** (Layer 2 Managed Switch) — hỗ trợ IEEE 802.1Q VLAN
- **Fortinet FortiGate** của bạn đã hỗ trợ sẵn inter-VLAN routing

**Gợi ý switch:**
```
Ngân sách thấp:  TP-Link TL-SG2428P (24 port PoE Managed, ~$200-300)
Ngân sách trung: Cisco Catalyst 2960, HP ProCurve (~$400-800)
Hiệu suất cao:  Cisco Catalyst 9200 (~$1000+)

→ Đề xuất: TP-Link TL-SG2428P hoặc tương đương
  - 24 port PoE → cấp điện cho camera, AP
  - Managed → hỗ trợ VLAN
  - Giá phù hợp cho nhà máy vừa
```

### 36.2 Thiết kế VLAN cho nhà máy bạn

```
VLAN 10 — Văn phòng:
  Subnet: 192.168.10.0/24 (254 host)
  Thiết bị: PC Dell .17, .20, .37, .82, .87, .100 (bạn), Máy in RICOH

VLAN 20 — Camera / An ninh:
  Subnet: 192.168.20.0/24 (254 host)
  Thiết bị: Camera Hikvision .6, .77
  Rule: Chỉ NVR server trong VLAN 10 mới kết nối được vào VLAN 20

VLAN 30 — Sản xuất / OT:
  Subnet: 192.168.30.0/24 (254 host)
  Thiết bị: Advantech .9, Techno Scope .8
  Rule: Không cho LAN khác vào, chỉ ra Internet qua Fortinet

VLAN 40 — Management:
  Subnet: 192.168.40.0/28 (14 host)
  Thiết bị: Chỉ IT admin (máy bạn khi cần quản trị)
  Rule: Chỉ từ IP admin mới SSH/HTTPS vào được switch, Fortinet

VLAN 99 — Guest / Khách:
  Subnet: 192.168.99.0/24 (254 host)
  Rule: Chỉ ra Internet, KHÔNG vào mạng nội bộ bất kỳ VLAN nào
```

### 36.3 Quy tắc giao tiếp giữa VLAN (trên Fortinet)

```
VLAN 10 (VP) → VLAN 20 (Camera): ✅ Cho (nhân viên xem camera)
VLAN 10 (VP) → VLAN 30 (SX):    ❌ Chặn (không cần thiết)
VLAN 20 (Cam) → VLAN 10 (VP):   ❌ Chặn (camera không cần vào PC)
VLAN 30 (SX) → VLAN 10 (VP):    ❌ Chặn (máy CNC không cần vào PC)
VLAN 99 (Guest) → VLAN 10,20,30: ❌ Chặn (khách chỉ có Internet)
Mọi VLAN → Internet:            ✅ Cho qua Fortinet (có Web Filter)
```

### 36.4 Kế hoạch triển khai từng bước

```
Tuần 1: Chuẩn bị
  □ Mua switch Managed PoE
  □ Vẽ sơ đồ vật lý: thiết bị nào cắm vào cổng nào
  □ Xác định IP tĩnh cho mỗi VLAN gateway (trên Fortinet)

Tuần 2: Cấu hình Fortinet
  □ Tạo 5 interface VLAN trên Fortinet
  □ Đặt IP gateway cho từng VLAN
  □ Cấu hình DHCP pool cho từng VLAN
  □ Viết Firewall policy giữa các VLAN

Tuần 3: Cấu hình Switch
  □ Cấu hình VLAN trên switch
  □ Gán port theo VLAN (Access port cho thiết bị)
  □ Cấu hình Trunk port (nối switch với Fortinet)
  □ Test từng VLAN một

Tuần 4: Rollout
  □ Di chuyển từng thiết bị sang VLAN tương ứng
  □ Kiểm tra kết nối từng thiết bị
  □ Kiểm tra các rule firewall
  □ Tài liệu hóa cấu hình
```

---

## Chương 37: Giám sát mạng — "Đặt camera cho mạng"

### 37.1 Tại sao cần giám sát?

Không giám sát = không biết có vấn đề cho đến khi quá muộn:
- Camera mất kết nối lúc 2 giờ sáng → sáng hôm sau mới biết
- Máy Advantech bị lỗi → nhân viên báo cáo → IT mới biết
- Hacker đang quét mạng lúc nửa đêm → không ai hay biết

**Với hệ thống giám sát:**
- Thông báo ngay khi thiết bị mất mạng
- Dashboard tổng quan tất cả thiết bị
- Alert khi có traffic bất thường

### 37.2 SNMP — Giao thức giám sát thiết bị mạng

**SNMP (Simple Network Management Protocol)** = "ngôn ngữ" để phần mềm giám sát hỏi thăm các thiết bị:

```
Phần mềm giám sát                    Thiết bị (Switch, Camera, PC)
       │                                          │
       │──── "CPU đang mức bao nhiêu?" ─────────►│
       │◄─── "78%"  ──────────────────────────── │
       │──── "Còn bao nhiêu RAM?" ───────────────►│
       │◄─── "4.2GB"  ────────────────────────── │
       │──── "Port 5 có lỗi không?" ─────────────►│
       │◄─── "Lỗi: 0" ─────────────────────────  │

Nếu thiết bị không trả lời sau X lần → Gửi alert: "THIẾT BỊ MẤT KẾT NỐI!"
```

### 37.3 Zabbix — Phần mềm giám sát miễn phí cho nhà máy

**Zabbix** là phần mềm giám sát mạng mã nguồn mở, miễn phí, mạnh mẽ — nhiều doanh nghiệp lớn dùng.

```
Kiến trúc Zabbix:

  [Zabbix Server] ── SNMP/ping/agent ──► [Switch]
       │                                  [Camera]
       │                                  [PC]
       │                                  [Fortinet]
  [Database]
  [Web Frontend]
       │
  [Admin xem dashboard trên browser]
```

**Những gì Zabbix theo dõi được:**

| Đối tượng | Chỉ số theo dõi | Alert khi |
|:---|:---|:---|
| Mọi thiết bị IP | Ping (còn online?) | Mất kết nối > 1 phút |
| Switch | CPU, RAM, traffic từng port | CPU > 80%, port lỗi |
| Fortinet | Số kết nối, bandwidth, CPU | Bandwidth > 80% |
| Windows PC | CPU, RAM, disk, network | Disk > 90% |
| Camera | Ping | Mất kết nối |

**Cài đặt Zabbix cho nhà máy (tóm tắt):**
```
1. Cài đặt Zabbix Server trên 1 PC/VM Linux (Ubuntu Server)
   → Có thể dùng Docker nếu biết Docker

2. Vào web: http://[IP_Zabbix]:80
   → Tạo Host cho từng thiết bị trong nhà máy

3. Cấu hình SNMP Community trên Fortinet và Switch
   → Fortinet: System → SNMP → Enable → Community: "nhà máy" (đặt tên)

4. Thêm host vào Zabbix:
   Configuration → Hosts → Create Host
   → Hostname: "Fortinet FortiGate"
   → IP: 192.168.120.1
   → Template: Fortinet FortiGate by SNMP
       (Tìm trong Zabbix: Configuration → Templates → Search "Fortinet"
        Nếu chưa có → Import từ: git.zabbix.com/templates/fortinet-fortigate)

5. Cấu hình alert qua email:
   Administration → Media types → Email
   → SMTP Server, From, To
   → Khi thiết bị mất → Zabbix gửi email cho bạn ngay
```

### 37.4 Grafana — Dashboard đẹp hơn

**Grafana** kết hợp với Zabbix hiển thị dashboard trực quan:

```
Dashboard nhà máy bạn có thể nhìn thấy:
  🟢 Fortinet: Online, CPU 12%, Bandwidth 45Mbps/100Mbps
  🟢 Camera 1: Online, đang stream
  🟢 Camera 2: Online, đang stream
  🟢 Máy in:   Online
  🟢 PC bạn:   Online, CPU 34%, RAM 6.2GB/16GB
  🔴 Advantech: OFFLINE (17:32 - phát hiện ngay!)
```

---

## Chương 38: VPN — Làm việc từ xa an toàn

### 38.1 Vấn đề: Bạn đang ở nhà cần truy cập camera nhà máy

**Giải pháp sai (không nên):** Port Forwarding camera trực tiếp ra Internet
```
Vấn đề:
  - Camera Hikvision có nhiều lỗ hổng bảo mật đã biết
  - Hacker quét Internet → thấy port 8080 → tấn công camera → vào mạng nhà máy
  - Đây là cách nhiều nhà máy bị hack
```

**Giải pháp đúng:** VPN vào Fortinet → xem camera như đang ở nhà máy
```
Bạn ở nhà:
  Laptop → VPN kết nối → Fortinet 113.22.x.x (IP công cộng)
  Fortinet xác thực → tạo đường hầm mã hóa
  Laptop ← → Mạng nhà máy (như đang ngồi trong văn phòng)
  Mở http://192.168.125.6 → Xem camera bình thường ✅
```

### 38.2 Hai loại VPN Fortinet hỗ trợ

**SSL VPN (dễ dùng hơn, khuyến nghị):**
```
- Nhân viên cài FortiClient (miễn phí) trên laptop/điện thoại
- Gõ địa chỉ VPN, username, password → Kết nối
- Không cần cấu hình phức tạp phía client
- Phù hợp: nhân viên remote work, IT admin quản lý từ xa
```

**IPSec VPN (cho kết nối site-to-site):**
```
- Kết nối 2 văn phòng với nhau (nhà máy Việt Nam ↔ HQ Hàn Quốc)
- Router 2 đầu kết nối cố định, tự động
- Phù hợp: 2 chi nhánh cần chia sẻ tài nguyên
```

### 38.3 Cấu hình SSL VPN trên Fortinet (tóm tắt)

```
VPN → SSL-VPN Settings:
  Listen on Interface: wan1 (cổng Internet)
  Listen on Port: 443 (hoặc port khác tránh conflict)
  Restrict Access: Chỉ IP nhất định được phép (nếu muốn)

VPN → SSL-VPN Portals:
  Create portal "remote-access"
  Enable Split Tunneling: ON (chỉ traffic nhà máy qua VPN, Internet thường)

Policy & Objects → Addresses:
  Tạo VPN user pool: 10.10.10.0/24

Firewall Policy:
  From: SSL-VPN tunnel
  To: LAN (hoặc VLAN cụ thể)
  Action: Accept

User & Authentication:
  Tạo user: admin_remote / [mật khẩu mạnh]
  Bật 2FA qua email hoặc FortiToken
```

### 38.4 2FA — Xác thực 2 lớp cho VPN

Dù ai đó biết username/password VPN, vẫn không vào được nếu không có 2FA:

```
Quy trình đăng nhập với 2FA:
  1. Nhập username + password → ✅ Đúng
  2. Fortinet gửi OTP 6 số vào email/SMS
  3. Nhập OTP → ✅ Đúng → Kết nối VPN thành công

Hacker có mật khẩu nhưng không có điện thoại bạn → không vào được ✅
```

---

## Chương 39: Quản lý IP tĩnh vs DHCP — Khi nào dùng cái gì?

### 39.1 Vấn đề với IP động cho thiết bị quan trọng

**DHCP động:** Fortinet cấp IP ngẫu nhiên, có thể thay đổi sau 7 ngày.

```
Vấn đề thực tế:
  Camera offline 8 ngày → DHCP cấp lại IP cho máy khác
  Camera bật lại → Nhận IP mới: 192.168.125.88 (thay vì .125.6)
  
  Hậu quả:
  - Phần mềm quản lý camera dùng IP .125.6 → không tìm thấy camera
  - Zabbix monitoring dùng IP .125.6 → báo camera mất kết nối sai
  - Port forwarding .125.6:80 → trỏ sai
```

### 39.2 Giải pháp: DHCP Reservation (Static DHCP)

Thay vì đặt IP tĩnh trực tiếp trên thiết bị, cấu hình Fortinet **luôn cấp cùng một IP** cho một MAC address cụ thể:

```
Fortinet DHCP → DHCP Reservation:

  MAC: 58-38-79-9C-C3-FC → Luôn cấp: 192.168.125.4  (Máy in)
  MAC: E0-CA-3C-2D-0F-7D → Luôn cấp: 192.168.125.6  (Camera 1)
  MAC: E0-CA-3C-xx-xx-xx → Luôn cấp: 192.168.125.77 (Camera 2)
  MAC: CC-82-7F-xx-xx-xx → Luôn cấp: 192.168.125.9  (Advantech)

Lợi ích:
  ✅ IP không bao giờ thay đổi (dù thiết bị tắt lâu)
  ✅ Quản lý tập trung (chỉ sửa Fortinet, không cần vào thiết bị)
  ✅ Thiết bị vẫn tự động nhận IP (không cần cấu hình static trên từng máy)
```

### 39.3 Khi nào nên dùng IP tĩnh thực sự?

```
Dùng DHCP Reservation (khuyến nghị):
  ✅ Camera, máy in, thiết bị cố định
  ✅ Server nội bộ (nếu có)
  ✅ Quản lý dễ hơn, ít lỗi hơn

Dùng IP tĩnh thực sự (cấu hình trên thiết bị):
  ✅ Fortinet Gateway (192.168.120.1)
  ✅ Zabbix Server (nếu cài)
  ✅ Khi thiết bị không hỗ trợ DHCP
  ✅ Khi muốn hoạt động ngay cả khi Fortinet tắt

Dùng DHCP động:
  ✅ PC nhân viên (không quan trọng IP cụ thể)
  ✅ Laptop khách
  ✅ Điện thoại WiFi
```

---

## Chương 40: Lộ trình học tiếp — Từ đây đi đâu?

### 40.1 Những gì bạn đã nắm vững (Phần 1-5)

```
✅ Nền tảng mạng:
   IP, Subnet Mask (AND tính Network ID), MAC, Gateway, DHCP, DNS

✅ Thiết bị mạng:
   Switch (MAC Table, ARP), Router (Routing Table),
   Firewall (Stateful), AP, Modem, PoE, NAT

✅ Giao thức:
   TCP (handshake, ACK, đảm bảo), UDP (nhanh, không đảm bảo)
   Port, Socket, HTTP/HTTPS, DNS, DHCP, SNMP

✅ Bảo mật:
   VLAN, Defense in Depth, SMBv1, Ransomware,
   VPN (SSL VPN, IPSec), 2FA

✅ Công cụ:
   ipconfig, ping, tracert, arp, netstat, nslookup
   Wireshark (cơ bản), Nmap (cơ bản), Zabbix (cơ bản)

✅ Thực hành:
   Xử lý sự cố theo quy trình
   Chẩn đoán lỗi từ tầng 1 lên
```

### 40.2 Bước tiếp theo theo cấp độ

**Cấp 1 — Áp dụng ngay cho nhà máy (1-2 tháng):**
```
□ Tắt SMBv1 trên tất cả PC
□ Cập nhật Windows đầy đủ
□ Đổi mật khẩu camera Hikvision
□ Cấu hình PostgreSQL chỉ lắng nghe localhost
□ Thiết lập DHCP Reservation cho thiết bị quan trọng
□ Cài Wireshark, thử bắt gói tin
□ Cài Nmap, quét mạng xem có thiết bị lạ không
```

**Cấp 2 — Nâng cấp hạ tầng (3-6 tháng):**
```
□ Mua switch Managed PoE
□ Triển khai VLAN (5 VLAN như đề xuất)
□ Cấu hình SSL VPN trên Fortinet
□ Cài Zabbix Server, giám sát tất cả thiết bị
□ Cấu hình alert email khi thiết bị mất kết nối
```

**Cấp 3 — Học sâu hơn (6-12 tháng):**
```
□ Wireshark nâng cao: phân tích gói tin thực tế
□ Fortinet FortiGate Admin: học quản trị firewall
□ Network+ hoặc CCNA certification (nền tảng mạng chuẩn)
□ Linux cơ bản (cần cho Zabbix, nhiều server)
□ Active Directory / Domain (quản lý người dùng tập trung)
```

**Cấp 4 — Chuyên nghiệp (1+ năm):**
```
□ CCNA (Cisco Certified Network Associate)
□ Fortinet NSE 4/5 (Fortinet Network Security)
□ OT Security (bảo mật mạng công nghiệp — Advantech, PLC, SCADA)
□ SOC/SIEM (giám sát bảo mật nâng cao)
```

### 40.3 Tài nguyên học tập khuyến nghị

```
📹 YouTube (miễn phí, tiếng Anh có phụ đề):
   - NetworkChuck: Mạng theo phong cách vui nhộn, dễ hiểu
   - David Bombal: CCNA, Wireshark, Nmap thực hành
   - Fortinet TV: Hướng dẫn chính thức từ Fortinet

📚 Tài liệu chính thức (miễn phí):
   - Fortinet Documentation: docs.fortinet.com
   - Cisco Learning Network: learningnetwork.cisco.com
   - Wireshark User Guide: wireshark.org/docs/wsug_html

🎮 Thực hành (miễn phí):
   - Cisco Packet Tracer: mô phỏng mạng (tải miễn phí)
   - GNS3: mô phỏng router/firewall thực tế
   - TryHackMe: học bảo mật theo gamification

📜 Chứng chỉ đề xuất theo thứ tự:
   1. CompTIA Network+ (nền tảng mạng toàn diện)
   2. Fortinet NSE 4 (chuyên về thiết bị nhà máy bạn)
   3. CCNA (nếu muốn đi sâu hơn về networking)
```

---

## Chương 41: Tổng kết toàn bộ series

### 41.1 Câu chuyện hoàn chỉnh

Bạn bắt đầu với câu hỏi: "IP và Subnet Mask liên quan gì nhau?"

Bây giờ bạn hiểu:

```
Khi bạn nhấn Ctrl+P để in:
  → Máy tính tính phường của máy in [IP AND Mask]
  → Cùng phường → ARP tìm MAC → Switch chuyển frame
  → < 1ms sau: tài liệu bắt đầu in

Khi bạn gõ google.com:
  → DNS (UDP:53) dịch tên → IP
  → Khác phường → qua Fortinet (Gateway)
  → Fortinet NAT: đổi IP nội bộ → IP FPT
  → TCP handshake với Google
  → HTTPS (TLS mã hóa)
  → Trang web về → NAT ngược → về đúng máy bạn

Khi có sự cố:
  → Kiểm tra từ tầng 1 (vật lý) lên tầng 7 (ứng dụng)
  → ping → tracert → arp → netstat → nslookup

Để an toàn hơn:
  → VLAN tách thiết bị → Firewall rule → SMBv1 tắt → Camera đổi mật khẩu
  → VPN thay vì Port Forwarding → 2FA → Giám sát 24/7 với Zabbix
```

### 41.2 Bảng tra cứu cuối cùng

| Hỏi | Tra ở đâu |
|:---|:---|
| Tôi có IP gì, gateway là gì? | `ipconfig /all` |
| Thiết bị X còn sống không? | `ping [IP thiết bị X]` |
| Mạng chậm ở đoạn nào? | `tracert google.com` |
| Ai đang trong mạng? | `arp -a` hay Nmap |
| Port nào đang mở? | `netstat -an` |
| Tên miền này là IP gì? | `nslookup [tên miền]` |
| Gói tin thực sự chạy thế nào? | Wireshark |
| Thiết bị nào online/offline? | Zabbix dashboard |
| Remote vào nhà máy an toàn? | SSL VPN (FortiClient) |

---

## Chương 42: Tự kiểm tra Phần 5

> **Câu 1:** Camera Hikvision `.125.6` tắt 10 ngày vì mất điện. Khi bật lại, phần mềm iVMS-4200 không tìm thấy camera dù đã ping thành công. Nguyên nhân có thể là gì? Cách xử lý?
> → DHCP đã cấp IP `.125.6` cho thiết bị khác trong 10 ngày tắt. Camera bật lại nhận IP mới (ví dụ `.125.88`). **Xử lý:** Cấu hình DHCP Reservation trong Fortinet để `.125.6` luôn gắn với MAC của camera — không bao giờ thay đổi dù camera tắt bao lâu.

> **Câu 2:** Bạn đang ở nhà, muốn xem camera nhà máy. Đồng nghiệp đề nghị mở Port Forwarding camera trực tiếp ra Internet. Bạn sẽ phản bác thế nào và đề xuất giải pháp nào thay thế?
> → Port Forwarding camera trực tiếp là nguy hiểm: camera Hikvision có nhiều lỗ hổng đã biết công khai, hacker quét Internet sẽ thấy và tấn công. **Giải pháp đúng:** Cấu hình SSL VPN trên Fortinet → cài FortiClient trên laptop cá nhân → kết nối VPN trước → rồi mới mở `http://192.168.125.6` như đang ngồi trong nhà máy. An toàn hơn hoàn toàn.

> **Câu 3:** IT đề xuất mua thêm 1 switch "rẻ tiền" (unmanaged) để mở rộng mạng thêm 8 cổng. Bạn học được gì từ Phần 5 để phản biện đề xuất này?
> → Switch unmanaged không hỗ trợ VLAN — toàn bộ thiết bị cắm vào sẽ nằm chung phường với PC văn phòng. Virus từ 1 máy có thể lan sang camera, máy sản xuất Advantech. **Đề xuất thay thế:** Mua switch Managed PoE (ví dụ TP-Link TL-SG2428P) — hơn một chút về giá nhưng hỗ trợ VLAN để tách biệt camera/sản xuất/văn phòng, đồng thời cấp điện PoE cho camera (tiết kiệm kéo dây điện riêng).

---

> [!TIP]
> **Hành trình học mạng không có điểm dừng cuối cùng. Nhưng bạn đã có nền tảng vững chắc để:**
> - Hiểu những gì đang xảy ra trong mạng nhà máy
> - Tự chẩn đoán và xử lý các sự cố cơ bản
> - Đề xuất cải tiến bảo mật thực tế và có cơ sở
> - Giao tiếp chuyên nghiệp với nhà cung cấp IT/mạng
>
> **Bước tiếp theo quan trọng nhất: Thực hành!**
> Chạy `ipconfig`, `ping`, `tracert`, `arp -a` ngay trên máy thật.
> Cài Wireshark và xem gói tin thực sự chạy thế nào.
> Cài Nmap và quét mạng nhà máy.
