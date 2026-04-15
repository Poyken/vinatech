# 📚 HỆ THỐNG KIẾN THỨC MẠNG — Phần 3: PORT, GIAO THỨC & BẢO MẬT

> 🎯 **Mục tiêu:** Hiểu tại sao có port số, TCP/UDP khác nhau thế nào, tại sao nhà máy cần VLAN, và biết cách dùng lệnh để "nhìn thấy" mạng.

> ⬅️ **Trước đó:** [Phần 2 — Switch, Router, Firewall, NAT](./kien-thuc-mang-phan2.md)

---

## Chương 19: Port — "Số phòng trong tòa nhà"

### 19.1 Tình huống: Một IP, nhiều chương trình

Máy bạn đang chạy cùng lúc:
- Brave Browser đang tải trang web
- OneDrive đang đồng bộ file lên cloud
- PostgreSQL đang lắng nghe kết nối database
- Zalo đang nhận tin nhắn

Tất cả đều dùng **cùng một địa chỉ IP** (`192.168.125.100`). Vậy khi dữ liệu về đến máy, hệ thống biết trao cho Brave hay cho OneDrive?

→ **Port number** — số phòng trong tòa nhà — giải quyết vấn đề này.

### 19.2 Port là gì?

```
Địa chỉ đầy đủ của một kết nối:

   192.168.125.100  :  443
   ───────┬───────     ─┬─
   IP (tòa nhà)       Port (số phòng)
                       443 = phòng HTTPS (Brave đang ở đây)

   192.168.125.100  :  5432
   ───────┬───────     ──┬──
   IP (tòa nhà)       Port (số phòng)
                       5432 = phòng PostgreSQL
```

**65.535 port** cho mỗi IP — đủ dùng. Chia thành 3 nhóm:

```
0 – 1023:      Port "tiêu chuẩn" — các dịch vụ nổi tiếng
               Do IANA quy định, cần quyền admin để mở
               Ví dụ: 80 (HTTP), 443 (HTTPS), 22 (SSH)

1024 – 49151:  Port "đã đăng ký" — ứng dụng phổ biến
               Ví dụ: 5432 (PostgreSQL), 1433 (SQL Server), 3389 (RDP)

49152 – 65535: Port "tạm thời" — máy tự chọn ngẫu nhiên
               Khi bạn mở tab Chrome → Chrome chọn ngẫu nhiên port này
               Ví dụ: 54996, 54997, 55001...
```

### 19.3 Các Port hay gặp — Nhớ những cái quan trọng

| Port | Dịch vụ | Giải thích đơn giản |
|:---:|:---:|:---|
| **80** | HTTP | Web thường (không mã hóa) — bạn thấy `http://` |
| **443** | HTTPS | Web mã hóa (an toàn) — bạn thấy `https://` và ổ khóa 🔒 |
| **53** | DNS | Dịch tên miền → IP |
| **22** | SSH | Điều khiển máy từ xa (dòng lệnh, mã hóa) |
| **3389** | RDP | Remote Desktop Windows (giao diện đồ họa) |
| **445** | SMB | Chia sẻ file/thư mục trong Windows |
| **1433** | SQL Server | Database của Microsoft (MSSQL) |
| **5432** | PostgreSQL | Database PostgreSQL — đang chạy trên máy bạn! |
| **25** | SMTP | Gửi email đi |
| **554** | RTSP | **Stream video từ camera IP** — Hikvision dùng giao thức này để truyền hình |
| **8000** | Hikvision SDK | **Cổng SDK Hikvision** — phần mềm iVMS-4200 kết nối camera qua port này |
| **8883** | MQTT | Giao tiếp thiết bị IoT/công nghiệp (Advantech) |

### 19.4 Port trên máy bạn — Hiện tại đang mở gì?

```powershell
netstat -an | findstr LISTEN
```

Kết quả thực tế từ máy bạn:
```
TCP  0.0.0.0:135        LISTENING   ← Windows RPC (bình thường)
TCP  0.0.0.0:445        LISTENING   ← SMB chia sẻ file ← ⚠️ Rủi ro
TCP  127.0.0.1:5432     LISTENING   ← PostgreSQL (chỉ chính máy truy cập)
TCP  0.0.0.0:3389       LISTENING   ← RDP (nếu bật Remote Desktop)
```

**Hiểu `0.0.0.0` vs `127.0.0.1`:**
```
0.0.0.0:445  → Port 445 mở cho TẤT CẢ địa chỉ IP đến
               → Bất kỳ ai trong mạng đều có thể kết nối! ⚠️

127.0.0.1:5432 → Port 5432 chỉ mở cho CHÍNH máy này (localhost)
                → Máy khác trong mạng KHÔNG kết nối được ✅ an toàn hơn
```

### 19.5 Socket — "Cặp đôi hoàn hảo xác định 1 kết nối"

Mỗi kết nối mạng được xác định bởi **4 thông tin**:

```
Socket = IP nguồn : Port nguồn ←→ IP đích : Port đích

Tab Chrome 1: 192.168.125.100:54996 ←→ 142.250.199.202:443 (Google)
Tab Chrome 2: 192.168.125.100:54997 ←→ 142.250.199.202:443 (Google)
OneDrive:     192.168.125.100:55001 ←→ 13.107.6.152:443    (Microsoft)

→ Dù cùng IP đích và port đích, port nguồn khác nhau
→ HĐH biết tab 1 dùng 54996, tab 2 dùng 54997
→ Hoàn toàn tách biệt, không lẫn lộn
```

---

## Chương 20: TCP và UDP — Hai phong cách gửi dữ liệu

### 20.1 Vấn đề: Không phải dữ liệu nào cũng cần như nhau

- **In tài liệu:** Nếu mất 1 ký tự → cả trang có thể hỏng → CẦN đảm bảo 100%
- **Video call:** Nếu mất 1 frame video → hình chỉ mờ 1/30 giây → KHÔNG CẦN đảm bảo, chấp nhận mất một chút

→ Đây là lý do tồn tại 2 giao thức: **TCP** và **UDP**

### 20.2 TCP — "Vận chuyển bưu phẩm bảo đảm"

**TCP (Transmission Control Protocol)** — đảm bảo dữ liệu đến **đầy đủ, đúng thứ tự**.

**Bước 1: Bắt tay trước khi gửi (3-way handshake)**
```
💻 Máy bạn                    🖥️ Server Google
      │
      │───── SYN ────────────►│  "Tôi muốn kết nối"
      │◄──── SYN-ACK ─────────│  "Được, tôi sẵn sàng"
      │───── ACK ────────────►│  "Bắt đầu!"
      │
      └─ Kết nối thiết lập ✅ │
```

**Bước 2: Gửi dữ liệu và xác nhận từng gói**
```
Máy bạn gửi:         Server xác nhận:
  Gói 1 ──────────►  ✅ "Nhận gói 1 rồi"
  Gói 2 ──────────►  ✅ "Nhận gói 2 rồi"
  Gói 3 ─── MẤT ──►  (không có ACK)
  (chờ timeout)
  Gói 3 (gửi lại) ►  ✅ "Nhận gói 3 rồi"
  Gói 4 ──────────►  ✅ "Nhận gói 4 rồi"
```

**Ứng dụng đang dùng TCP trên máy bạn:**
- Brave Browser tải trang web (HTTP/HTTPS) → cần đầy đủ từng byte HTML
- PostgreSQL truy vấn database → cần chính xác 100%
- OneDrive upload file → mất byte = file hỏng

### 20.3 UDP — "Gửi thư nhanh, không cần biên lai"

**UDP (User Datagram Protocol)** — gửi nhanh, không xác nhận, có thể mất gói.

```
Máy gửi:             Máy nhận:
  Gói 1 ──────────►  ✅
  Gói 2 ─── MẤT ──►   (không ai biết, không gửi lại, tiếp tục)
  Gói 3 ──────────►  ✅
  Gói 4 ──────────►  ✅
```

**Tại sao video call dùng UDP?**

```
Nếu Zoom/Teams dùng TCP:
  Giây 1: Frame hình ✅
  Giây 2: Frame hình MẤT → TCP yêu cầu gửi lại
  Giây 3: Frame hình mới PHẢI CHỜ frame 2 về trước
  → Hình bị đơ 1-2 giây, rất khó chịu 😤

Dùng UDP:
  Giây 1: Frame hình ✅
  Giây 2: Frame hình MẤT → bỏ qua, mất ~33ms hình là OK
  Giây 3: Frame hình mới ✅
  → Hình chỉ bị mờ nhẹ thoáng qua, không ai chú ý 😊
```

### 20.4 So sánh và ghi nhớ

| | TCP | UDP |
|:---|:---|:---|
| **Ẩn dụ** | Bưu phẩm bảo đảm (có ký nhận) | Gửi thư thường (bỏ vào hộp) |
| **Bắt tay trước?** | ✅ 3-way handshake | ❌ Gửi luôn |
| **Xác nhận nhận?** | ✅ ACK từng gói | ❌ Không |
| **Gửi lại nếu mất?** | ✅ Có | ❌ Không |
| **Tốc độ** | Chậm hơn (có overhead) | Nhanh hơn |
| **Dùng cho** | Web, Email, File, Database | Video call, DNS, Game, IoT |

---

## Chương 21: VLAN — "Vách ngăn ảo trong nhà máy"

### 21.1 Tình huống: Virus trong mạng phẳng

Sáng thứ Hai, một nhân viên văn phòng mở file đính kèm email lạ. **Ransomware** bắt đầu lây lan.

**Với mạng nhà máy bạn hiện tại (không có VLAN):**
```
Tất cả 34 thiết bị trong cùng 1 mạng 192.168.120.0/21

Ransomware từ PC kế toán:
  → Quét toàn bộ dải .120.1 → .127.254
  → Tìm thấy PostgreSQL server (port 5432 mở) → Mã hóa database
  → Tìm thấy máy in RICOH (port 9100 mở) → Thay firmware độc hại
  → Tìm thấy Advantech IPC (.125.9) → Có thể ảnh hưởng dây chuyền SX!
  Thiệt hại: CẢ NHÀ MÁY bị ảnh hưởng
```

**Với VLAN:**
```
Ransomware từ PC kế toán (VLAN 10):
  → Chỉ thấy các PC khác trong VLAN 10
  → KHÔNG thể sang VLAN 20 (Camera) hay VLAN 30 (Sản xuất)
  → Camera và máy sản xuất AN TOÀN ✅
  Thiệt hại: Chỉ VLAN 10 bị ảnh hưởng → cô lập và xử lý dễ hơn
```

### 21.2 VLAN là gì?

**VLAN (Virtual LAN)** = chia **1 switch vật lý** thành **nhiều switch ảo** tách biệt hoàn toàn.

```
Không có VLAN:                    Có VLAN:
┌─────────────────────┐           ┌──────┐ ┌──────┐ ┌──────┐
│  1 SWITCH vật lý    │           │ VLAN │ │ VLAN │ │ VLAN │
│  💻📷⚙️🖨️ lẫn lộn  │   →       │  10  │ │  20  │ │  30  │
│  Ai cũng thấy nhau  │           │  VP  │ │  Cam │ │  SX  │
└─────────────────────┘           │ 💻🖨️│ │ 📷📷 │ │  ⚙️  │
                                   └──────┘ └──────┘ └──────┘
                                   Tách biệt, trên CÙNG switch!
```

### 21.3 VLAN hoạt động thế nào — "Thẻ màu" cho từng gói tin

Switch Managed đánh **tag ID** vào mỗi frame (theo chuẩn 802.1Q):

```
Frame không VLAN:
  [MAC đích | MAC nguồn | Dữ liệu]

Frame có VLAN tag:
  [MAC đích | MAC nguồn | TAG: VLAN-ID=10 | Dữ liệu]
                            ↑
                      "Frame này thuộc VLAN 10 — Văn phòng"

Switch chỉ chuyển frame đến port cùng VLAN ID → tách biệt hoàn toàn
```

### 21.4 Thiết kế VLAN cho nhà máy bạn (đề xuất)

| VLAN | Tên | Subnet | Thiết bị | Ghi chú |
|:---:|:---|:---|:---|:---|
| **10** | Văn phòng | `192.168.10.0/24` | PC Dell, Máy in | Nhân viên hàng ngày |
| **20** | Camera | `192.168.20.0/24` | Hikvision ×2 | Chỉ NVR được xem |
| **30** | Sản xuất | `192.168.30.0/24` | Advantech, Techno | Cô lập hệ thống CN |
| **40** | Quản lý | `192.168.40.0/28` | Fortinet, switch | Chỉ IT admin |
| **99** | Guest | `192.168.99.0/24` | Điện thoại khách | Không vào mạng nội bộ |

**Quy tắc giao tiếp giữa VLAN:**
```
VLAN 10 ←→ VLAN 20:  ✅ Được (nhân viên xem camera qua phần mềm)
VLAN 10 ←→ VLAN 30:  ❌ Không (không cần thiết, giảm rủi ro)
VLAN 30 → VLAN 40:   ❌ Không (máy CN không được vào switch management)
Guest   → Tất cả:    ❌ Không (khách chỉ ra Internet)
```

---

## Chương 22: Mô hình OSI — "Bản đồ tầng lớp mạng"

### 22.1 Tại sao cần biết OSI?

Khi mạng có vấn đề, bạn cần **biết tìm lỗi ở đâu**. Mô hình OSI cho bạn bản đồ để tìm kiếm có hệ thống từ dưới lên trên.

### 22.2 7 tầng OSI — Gắn với thực tế nhà máy bạn

```
┌─────────────────────────────────────────────────────────────────┐
│  7. APPLICATION — Ứng dụng                                      │
│  Bạn nhìn thấy: Brave, OneDrive, Email, Database app            │
│  Giao thức: HTTP, HTTPS, DNS, SMTP, FTP, MQTT                   │
│  Khi lỗi: Website không load, ứng dụng báo lỗi kết nối         │
├─────────────────────────────────────────────────────────────────┤
│  6. PRESENTATION — Trình bày (thường gộp vào tầng 7)           │
│  Mã hóa/giải mã TLS/SSL (lock 🔒 trên trình duyệt)            │
│  Nén dữ liệu trước khi gửi                                      │
├─────────────────────────────────────────────────────────────────┤
│  5. SESSION — Phiên làm việc (thường gộp vào tầng 7)           │
│  Quản lý phiên login, giữ session trong khi duyệt web           │
├─────────────────────────────────────────────────────────────────┤
│  4. TRANSPORT — Vận chuyển                                       │
│  TCP hay UDP? Port number bao nhiêu?                             │
│  Giao thức: TCP (web,file), UDP (video,DNS)                     │
│  Khi lỗi: Kết nối bị từ chối "Connection refused" (port bị chặn│
├─────────────────────────────────────────────────────────────────┤
│  3. NETWORK — Mạng                                               │
│  Địa chỉ IP, tìm đường (routing)                                │
│  Thiết bị: Router, Fortinet (layer 3)                           │
│  Khi lỗi: ping fail, "Destination unreachable"                  │
├─────────────────────────────────────────────────────────────────┤
│  2. DATA LINK — Liên kết dữ liệu                                │
│  Địa chỉ MAC, chuyển frame trong LAN                            │
│  Thiết bị: Switch, Access Point                                  │
│  Khi lỗi: ARP fail, không học được MAC                          │
├─────────────────────────────────────────────────────────────────┤
│  1. PHYSICAL — Vật lý                                            │
│  Tín hiệu điện/quang/radio trên môi trường vật lý               │
│  Thiết bị: Cáp mạng, đầu RJ-45, cáp quang, anten WiFi          │
│  Khi lỗi: Đèn switch tắt, "Media disconnected"                  │
└─────────────────────────────────────────────────────────────────┘
```

### 22.3 Quy trình chẩn đoán lỗi — "Từ dưới lên"

**Kịch bản:** Máy bạn không vào được Internet.

```
Bước 1 — Kiểm tra vật lý (Tầng 1):
  ❓ Đèn trên switch có sáng ở cổng bạn cắm không?
  🔧 ipconfig → thấy "Media disconnected"?
  → Nếu có: Thử đổi cáp hoặc cổng switch

Bước 2 — Kiểm tra kết nối IP đến Gateway (Tầng 3 — giao thức ICMP):
  🔧 ping 192.168.120.1
     ✅ Reply → Tầng 1-3 OK, lỗi ở trên
     ❌ Timeout → Fortinet có vấn đề hoặc cùng LAN không thông
  (ping dùng ICMP — thuộc Tầng 3. Nếu ping OK thì Tầng 1, 2, 3 đều ổn)

Bước 3 — Kiểm tra Internet (Tầng 3):
  🔧 ping 8.8.8.8
     ✅ Reply → Internet OK
     ❌ Timeout → FPT hoặc Fortinet không ra ngoài được

Bước 4 — Kiểm tra DNS (Tầng 7):
  🔧 nslookup google.com
     ✅ Trả về IP → DNS OK → vào web được
     ❌ Fail → DNS server 8.8.8.8 không trả lời
     🔧 ipconfig /flushdns → thử lại
```

---

## Chương 23: Bảo mật mạng — Thực tế ở nhà máy bạn

### 23.1 Bức tranh đe dọa hiện tại

```
Từ bên ngoài (Internet) vào nhà máy:
  🦠 Malware qua email spam     (nhân viên mở file đính kèm)
  🎣 Phishing website            (trang web giả ngân hàng, HR...)
  💣 DDoS từ botnet              (Fortinet có thể giảm thiểu)

Từ bên trong nội bộ:
  💾 USB chứa virus              (nhân viên cắm USB từ ngoài)
  🔓 Thiết bị lạ kết nối        (ai đó cắm laptop cá nhân vào mạng)
  📧 Email phishing nội bộ       (tài khoản đồng nghiệp bị chiếm)
```

### 23.2 Điểm yếu cụ thể của nhà máy bạn

| Điểm yếu | Tại sao nguy hiểm | Hành động cụ thể |
|:---|:---|:---|
| **Port 445 (SMB) mở** | WannaCry 2017 lây qua đây; mất hàng triệu máy tính toàn cầu | Tắt SMBv1 trong Windows Features; cập nhật Windows |
| **Không có VLAN** | 1 máy bị nhiễm → cả mạng có thể bị tấn công | Mua switch Managed, cấu hình VLAN |
| **Không có Domain** | Không enforce mật khẩu tập trung, không audit đăng nhập | Xem xét Windows AD hoặc ít nhất quy định mật khẩu |
| **PostgreSQL mở LAN** | DB trong nhà máy có thể bị truy cập từ bất kỳ PC nào | Cấu hình PostgreSQL `listen_addresses`, giới hạn IP |
| **Camera không có VLAN riêng** | Camera bị hack → nghe lén toàn bộ nhà máy | Đưa camera vào VLAN riêng |

### 23.3 Các lớp bảo vệ — Không chỉ dựa vào 1 lớp

**Nguyên tắc Defense in Depth** — giống như tòa nhà có nhiều cửa khóa:

```
Lớp 1: Fortinet Firewall
  → Chặn traffic xấu từ Internet
  → Web Filter chặn trang độc hại
  → IPS phát hiện tấn công

Lớp 2: VLAN (chưa có — nên làm)
  → Cô lập các nhóm thiết bị
  → Hạn chế lan truyền khi bị tấn công

Lớp 3: Windows Firewall (mỗi máy)
  → Chặn kết nối từ mạng nội bộ không cần thiết
  → Bảo vệ ngay cả khi firewall ngoài bị qua

Lớp 4: Antivirus + Microsoft Defender
  → Phát hiện malware trên máy
  → Cập nhật definition thường xuyên

Lớp 5: User Behavior (quan trọng không kém)
  → Không mở file đính kèm email lạ
  → Không cắm USB không rõ nguồn gốc
  → Mật khẩu mạnh (>12 ký tự, không là tên/ngày sinh)
```

---

## Chương 24: Lệnh chẩn đoán mạng — Bộ công cụ hàng ngày

### 24.1 `ipconfig` — "Kiểm tra giấy tờ tùy thân"

```powershell
ipconfig /all
```

**Đọc nhanh kết quả:**
```
Physical Address: 9C-69-D3-69-A1-96  ← MAC (CCCD) card mạng
IPv4 Address:     192.168.125.100    ← IP của bạn
Subnet Mask:      255.255.248.0      ← Ranh giới mạng
Default Gateway:  192.168.120.1      ← Cổng ra Internet
DHCP Server:      192.168.120.1      ← Ai cấp IP (Fortinet)
Lease Expires:    06/04/2026         ← IP hết hạn khi nào
DNS Servers:      8.8.8.8            ← Danh bạ Internet
```

**Lệnh hay dùng:**
```powershell
ipconfig /release    # Trả IP về cho DHCP
ipconfig /renew      # Xin IP mới → dùng khi bị đổi mạng
ipconfig /flushdns   # Xóa DNS cache → dùng khi web không load
```

---

### 24.2 `ping` — "Gõ cửa xem ai còn sống"

```powershell
ping 192.168.120.1      # Gõ cửa Gateway
ping 8.8.8.8            # Gõ cửa DNS Google
ping google.com         # Gõ cửa Google (test DNS + Internet)
ping -t 192.168.120.1   # Gõ liên tục (Ctrl+C để dừng)
```

**Đọc kết quả:**
```
Reply from 192.168.120.1: bytes=32 time<1ms TTL=255
↑ Trả lời    ↑ Ai trả lời    ↑ Kích thước  ↑ Nhanh  ↑ Còn bao nhiêu hop

time<1ms  → Rất nhanh, trong cùng LAN
time=13ms → Bình thường cho Internet Việt Nam
time=200ms → Chậm bất thường → có vấn đề trên đường truyền

Request timed out → Không ai trả lời:
  - Thiết bị đó tắt máy
  - Firewall chặn ICMP (ping bị chặn, không hẳn là lỗi)
  - Đường đi bị đứt
```

**TTL — Đọc để biết thiết bị là gì:**
```
TTL=255 → Thiết bị mạng (Router, Firewall) — gần như đặt ngay cạnh
TTL=128 → Máy Windows (phổ biến)
TTL=64  → Máy Linux/Mac/Điện thoại Android/iOS

TTL=119 khi ping Google → 128 - 119 = 9 hop đi qua
```

**Quy trình xử lý khi mất Internet:**
```
1. ping 192.168.120.1  → Fail? → Lỗi nội bộ (dây, switch)
2. ping 8.8.8.8        → Fail? → Fortinet hoặc FPT đứt
3. ping google.com     → Fail? → DNS có vấn đề
                       → OK?   → Thử refresh trình duyệt
```

---

### 24.3 `tracert` — "Theo dấu hành trình gói tin"

```powershell
tracert google.com
tracert -d 8.8.8.8    # -d: không dịch tên, nhanh hơn
```

**Đọc kết quả:**
```
Tracing route to google.com [142.250.197.46]:

  1  <1ms   192.168.120.1   ← Hop 1: Fortinet (trong nhà máy)
  2  8ms    113.22.0.37     ← Hop 2: Router FPT gần nhất
  3  9ms    42.113.208.7    ← Hop 3: Backbone FPT
  4   *      *       *      ← Router này không trả lời ping (bình thường!)
  5  12ms   209.85.244.25   ← Hop 5: Vào mạng Google
  6  13ms   142.250.4.160   ← Hop 6: Đến đích

Đọc:
  ms nhỏ và đều = đường tốt ✅
  ms tăng đột ngột ở hop X = nghẽn cổ chai ở đó ⚠️
  * * * = router cố ý không trả lời ping, không phải lỗi
  Request timed out hàng loạt = thực sự bị đứt ❌
```

---

### 24.4 `arp -a` — "Danh sách hàng xóm đã gặp"

```powershell
arp -a
```

**Kết quả:**
```
Interface: 192.168.125.100

  IP Address        Physical Address    Type
  192.168.120.1     48-3a-02-82-af-10   dynamic  ← Fortinet
  192.168.125.4     58-38-79-9c-c3-fc   dynamic  ← Máy in RICOH
  192.168.125.6     e0-ca-3c-2d-0f-7d   dynamic  ← Camera 1
  192.168.127.255   ff-ff-ff-ff-ff-ff   static   ← Broadcast
  224.0.0.22        01-00-5e-00-00-16   static   ← Multicast

dynamic: Học được tự động, sẽ xóa sau ~2 phút không dùng
static:  Cố định, không xóa (broadcast, multicast)
```

**Ứng dụng thực tế:**
- Xem có thiết bị lạ không (tra OUI 3 cặp đầu MAC)
- Kiểm tra Gateway có trong bảng không (nếu không + ping fail = lỗi ARP)

---

### 24.5 `netstat -an` — "Xem tất cả cửa đang mở và kết nối đang có"

```powershell
netstat -an                        # Tất cả
netstat -an | findstr LISTEN       # Chỉ port đang mở
netstat -an | findstr ESTABLISHED  # Chỉ kết nối đang hoạt động
netstat -ano                       # Thêm PID (số hiệu tiến trình)
```

**Kết quả:**
```
TCP  0.0.0.0:445            0.0.0.0:0    LISTENING    ← SMB mở toàn bộ
TCP  127.0.0.1:5432         0.0.0.0:0    LISTENING    ← PostgreSQL chỉ local
TCP  192.168.125.100:54996  142.x.x:443  ESTABLISHED  ← Đang vào Google
TCP  192.168.125.100:55001  52.x.x.x:443 ESTABLISHED  ← OneDrive đồng bộ
UDP  0.0.0.0:5353            *:*                       ← mDNS

Phát hiện kết nối lạ:
  Nếu thấy ESTABLISHED đến IP lạ và port lạ → kiểm tra PID
  netstat -ano | findstr :PORT_LẠ
  tasklist | findstr PID_ĐÓ  → biết chương trình nào kết nối
```

---

### 24.6 `nslookup` — "Hỏi danh bạ Internet"

```powershell
nslookup google.com          # Tên → IP
nslookup 142.250.197.46      # IP → Tên (reverse lookup)
nslookup google.com 1.1.1.1  # Dùng DNS server Cloudflare thay vì mặc định
```

**Kết quả:**
```
Server:   dns.google
Address:  8.8.8.8         ← DNS đang dùng

Name:     google.com
Addresses: 142.250.197.46
           2404:6800:... ← IPv6 của Google

Lỗi phổ biến:
  "can't find google.com: Non-existent domain"
  → DNS server không trả lời, hoặc tên miền không tồn tại

Cách xử lý:
  ipconfig /flushdns       → Xóa cache cũ
  nslookup google.com 8.8.8.8  → Thử DNS khác → OK = DNS mặc định bị lỗi
```

---

### 24.7 Bảng tra cứu nhanh — Dùng lệnh nào cho tình huống nào?

| Tình huống | Lệnh cần dùng |
|:---|:---|
| Kiểm tra IP, Gateway, DNS của máy | `ipconfig /all` |
| Máy không có IP (DHCP fail) | `ipconfig /release` → `ipconfig /renew` |
| Web không load, mạng ổn | `ipconfig /flushdns` |
| Thiết bị X có còn sống không? | `ping [IP thiết bị X]` |
| Mạng có bị đứt gói không? | `ping -t [IP Gateway]` xem có `timeout` không |
| Tìm điểm mạng chậm ở đâu | `tracert google.com` |
| Thiết bị nào đang trong mạng? | `arp -a` |
| Port nào đang mở trên máy? | `netstat -an \| findstr LISTEN` |
| Có kết nối lạ nào không? | `netstat -an \| findstr ESTABLISHED` |
| Tên miền này là IP gì? | `nslookup [tên miền]` |
| Test kết nối đến port cụ thể | `Test-NetConnection -ComputerName [IP] -Port [PORT]` |

---

## Chương 25: Tổng kết 3 Phần — Bức tranh hoàn chỉnh

### 25.1 Mọi thứ gắn kết — Khi bạn mở teamviewer.com

```
Giây 0: Bạn gõ "teamviewer.com" trên Brave

Giây 0.001: Brave hỏi DNS "teamviewer.com = IP gì?"
            → UDP:53 đến 8.8.8.8
            → Khác mạng → qua Fortinet → NAT → FPT → DNS Google
            → Trả về: 104.18.x.x

Giây 0.050: TCP Handshake với 104.18.x.x:443
            → Fortinet kiểm tra rule: ✅ Được phép
            → NAT: 125.100:54996 → 113.22.x.x:40001

Giây 0.100: TLS Handshake (mã hóa HTTPS)
            → Tầng 6 hoạt động

Giây 0.150: Request trang web
            → Tầng 7 HTTP GET /

Giây 0.300: Server gửi HTML/CSS/JS về
            → Đường về: Google datacenter → FPT → Modem → Fortinet
            → Fortinet tra NAT: 40001 → 125.100:54996 → về máy bạn

Giây 0.500: Brave hiển thị trang ✅

Tóm tắt:
  Tầng 7: HTTP/HTTPS
  Tầng 6: TLS mã hóa
  Tầng 4: TCP port 443, port nguồn 54996
  Tầng 3: IP routing + NAT qua Fortinet
  Tầng 2: MAC, ARP, Switch
  Tầng 1: Cáp Cat6, ASIX adapter, cáp quang FPT
```

### 25.2 Bảng nhớ nhanh toàn bộ

| Khái niệm | Ẩn dụ | Bài học cốt lõi |
|:---|:---|:---|
| IP | Số nhà | Mỗi thiết bị 1 số, không trùng |
| Subnet Mask | Ranh giới phường | Xác định ai là hàng xóm |
| MAC | Số CCCD | Gắn cứng phần cứng, không đổi |
| Gateway | Cổng thành | Cửa duy nhất ra Internet |
| DHCP | Nhân viên phát số | Tự động, không cần đặt tay |
| DNS | Danh bạ | Dịch google.com → 142.x.x.x |
| Switch | Ngã tư nội bộ | Phân luồng bằng MAC |
| Router | Trạm liên vận | Kết nối mạng khác nhau bằng IP |
| Firewall | Kiểm soát viên | Cho/chặn theo rule |
| NAT | Tổng đài 34 người, 1 số máy | Ẩn IP nội bộ, dùng chung IP công cộng |
| ARP | Người đi hỏi thăm | Tìm MAC từ IP trong LAN |
| Port | Số phòng | Chương trình nào nhận dữ liệu |
| TCP | Bưu phẩm bảo đảm | Đảm bảo nhận đủ, đúng thứ tự |
| UDP | Thư thường | Nhanh, chấp nhận mất vài gói |
| VLAN | Vách ngăn ảo | Tách nhóm thiết bị trên cùng switch |
| OSI | Bản đồ tầng lớp | Chẩn đoán lỗi từ tầng 1 lên |

### 25.3 3 câu tự kiểm tra Phần 3

> **Câu 1:** Bạn mở 3 tab Chrome cùng kết nối Google. Google chỉ thấy 1 IP là `113.22.x.x`. Làm sao Fortinet biết reply từ Google cho tab nào?
> → Port nguồn khác nhau (54996, 54997, 54998). NAT Table ghi nhớ từng cặp.

> **Câu 2:** Zoom bị giật khi mạng yếu, còn tải file Word thì không bị mất dữ liệu. Giải thích tại sao.
> → Zoom dùng UDP — mất gói thì hình mờ nhưng tiếp tục. Word download dùng TCP — mất gói thì gửi lại, chậm nhưng không mất byte nào.

> **Câu 3:** Máy kế toán bị nhiễm ransomware. Nhà máy có VLAN hay không ảnh hưởng thế nào đến mức độ thiệt hại?
> → Không có VLAN: cả 34 thiết bị có thể bị tấn công. Có VLAN: hacker chỉ thấy được VLAN văn phòng, không sang được camera hay máy sản xuất.

---

> 📖 **Tiếp theo → [Phần 4: Chẩn đoán & Xử lý sự cố thực tế](./kien-thuc-mang-phan4.md)**
> Bạn sẽ học: Các kịch bản sự cố thực tế xảy ra ở nhà máy và cách xử lý từng bước.
