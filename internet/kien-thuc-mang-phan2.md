# 📚 HỆ THỐNG KIẾN THỨC MẠNG — Phần 2: THIẾT BỊ MẠNG & KẾT NỐI VẬT LÝ

> 🎯 **Mục tiêu:** Hiểu rõ từng thiết bị trong nhà máy làm gì, tại sao cần chúng, và chúng phối hợp với nhau thế nào khi bạn in tài liệu hay mở Google.

> ⬅️ **Trước đó:** [Phần 1 — Nền tảng IP, MAC, Subnet, Gateway, DHCP, DNS](./kien-thuc-mang-phan1.md)

---

## Chương 9: Tại sao cần nhiều loại thiết bị?

### 9.1 Câu hỏi bắt đầu

Bạn có thể thắc mắc: "Tại sao không cắm hết 34 thiết bị vào một cái hộp duy nhất cho đơn giản?"

**Lý do:** Mỗi loại thiết bị mạng giải quyết một vấn đề khác nhau, ở một tầng khác nhau:

```
Vấn đề 1: "Làm sao kết nối 34 thiết bị với nhau trong nhà máy?"
→ Giải pháp: SWITCH — kết nối và phân luồng nội bộ

Vấn đề 2: "Làm sao ra được Internet?"
→ Giải pháp: ROUTER — kết nối hai mạng khác nhau

Vấn đề 3: "Làm sao ngăn hacker vào mạng?"
→ Giải pháp: FIREWALL — kiểm soát traffic vào/ra

Vấn đề 4: "Làm sao laptop dùng WiFi kết nối vào mạng?"
→ Giải pháp: ACCESS POINT — cầu nối không dây

Vấn đề 5: "Làm sao tín hiệu cáp quang FPT vào được mạng nhà máy?"
→ Giải pháp: MODEM — chuyển đổi tín hiệu
```

Trong nhà máy bạn, **Fortinet FortiGate** một mình làm nhiệm vụ Router + Firewall + DHCP + NAT — đây là giải pháp phổ biến cho doanh nghiệp vừa và nhỏ.

---

## Chương 10: Switch — "Ngã tư thông minh trong nhà máy"

### 10.1 Tình huống: Bạn nhấn Ctrl+P để in

Lệnh in từ máy bạn đi đến máy in RICOH. Giữa chúng có gì?

```
💻 Máy bạn (.125.100)
         │ cáp Ethernet
         ▼
   ┌───────────────────────────────┐
   │         SWITCH                │
   │  [Port 4]........[Port 6]    │
   │       ↑                ↑     │
   │   Bạn ở đây      Máy in ở đây│
   └───────────────────────────────┘
         │ cáp Ethernet
         ▼
🖨️ Máy in RICOH (.125.4)
```

Switch chính là thiết bị trung gian **kết nối tất cả** thiết bị trong mạng nội bộ.

### 10.2 Switch hoạt động thế nào? — Học như con người

Switch **học và ghi nhớ** thiết bị nào đang cắm vào cổng nào, qua **MAC Address Table**:

**Ngày đầu tiên — Switch chưa biết gì:**
```
Bạn gửi lệnh in → Switch nhận frame:
  Nguồn: 9C-69-D3 (bạn, Port 4)   Đích: 58-38-79 (máy in, chưa biết ở đâu)

Switch ghi nhớ: "9C-69-D3 ở Port 4"
Switch chưa biết máy in ở đâu → Gửi ra TẤT CẢ port (gọi là Flood)
  → PC đồng nghiệp nhận nhưng thấy không phải mình → bỏ qua
  → Máy in nhận → trả lời

Máy in trả lời:
  Nguồn: 58-38-79 (máy in, Port 6)   Đích: 9C-69-D3 (bạn)

Switch ghi nhớ thêm: "58-38-79 ở Port 6"
Gửi thẳng về Port 4 (bạn) — không phiền ai khác ✅
```

**Từ lần thứ hai trở đi:**
```
Bạn gửi lệnh in → Switch tra bảng:
  "58-38-79 ở Port 6"
  → Gửi thẳng vào Port 6 → đến máy in ngay lập tức
  → Không ai khác bị phiền ✅
```

**Bảng Switch hiện tại (sau khi học xong):**
```
┌──────────────────────┬────────┬────────────┐
│    MAC Address       │  Port  │  Còn hiệu  │
│                      │        │  lực (s)   │
├──────────────────────┼────────┼────────────┤
│ 9C-69-D3-xx (Bạn)   │  4     │  280       │
│ 58-38-79-xx (In)    │  6     │  195       │
│ E0-CA-3C-xx (Cam 1) │  5     │  240       │
│ 8C-EC-4B-xx (PC đồng│  1     │  310       │
│  nghiệp)            │        │            │
│ 48-3A-02-xx (FW)    │  24    │  299       │
└──────────────────────┴────────┴────────────┘
  Mỗi entry sống ~300 giây, không dùng thì tự xóa
```

### 10.3 ARP — "Cách tìm địa chỉ thực (MAC) từ số nhà (IP)"

Nhưng đợi đã — máy tính bạn chỉ biết IP của máy in (`192.168.125.4`), không biết MAC. Switch cần MAC. Ai giải quyết chuyện này?

→ **ARP (Address Resolution Protocol)** — giao thức "hỏi thăm đường"

```
Tình huống: Bạn muốn in, cần gửi đến 192.168.125.4 nhưng chưa biết MAC

Bước 1 — Hỏi to khắp mạng:
  "Xin hỏi, ai có IP 192.168.125.4? Cho tôi biết MAC nhé!"
  Gửi đến: FF-FF-FF-FF-FF-FF (địa chỉ broadcast — TẤT CẢ thiết bị đều nhận)
  → Switch flood ra mọi port

Bước 2 — Máy in trả lời:
  "Tôi có IP đó! MAC của tôi là 58-38-79-9C-C3-FC"
  Gửi trực tiếp về cho bạn

Bước 3 — Bạn ghi nhớ vào ARP Cache (khoảng 2 phút):
  192.168.125.4 → 58-38-79-9C-C3-FC

Bước 4 — Lần sau không cần hỏi lại, gửi thẳng luôn
```

**Xem những thiết bị đã biết địa chỉ:**
```powershell
arp -a
# Kết quả:
# 192.168.120.1   48-3a-02-82-af-10   dynamic  ← Gateway (Fortinet)
# 192.168.125.4   58-38-79-9c-c3-fc   dynamic  ← Máy in RICOH
# 192.168.125.6   e0-ca-3c-2d-0f-7d   dynamic  ← Camera Hikvision
```

### 10.4 Switch loại nào? — Phân loại cho nhà máy

| Loại Switch | Đặc điểm | Phù hợp |
|:---|:---|:---|
| **Unmanaged** | Cắm vào là chạy, không cài đặt | Nhà, văn phòng nhỏ |
| **Managed** | Cấu hình VLAN, theo dõi traffic | Nhà máy bạn (nên dùng) |
| **PoE Switch** | Cấp điện qua cáp cho camera/AP | Nhà máy có camera IP |
| **Layer 3 Switch** | Routing giữa các VLAN | Mạng lớn, nhiều VLAN |

> **Nhà máy bạn hiện tại:** Dùng switch Unmanaged hoặc Managed cơ bản. Nên nâng lên **Managed PoE Switch** để hỗ trợ VLAN và cấp điện cho camera.

---

## Chương 11: Router — "Người chỉ đường giữa các thành phố"

### 11.1 Switch chưa đủ — Tại sao cần Router?

Switch chỉ biết làm việc trong **cùng một mạng** (cùng subnet). Nó không biết cách gửi gói tin ra Internet hoặc sang mạng khác.

**Hình dung:** Switch như hệ thống đường **nội thành** — chỉ đưa bạn đến các địa chỉ trong cùng thành phố. Router như **trạm liên vận** — kết nối các tuyến xe giữa các tỉnh thành khác nhau.

```
Switch xử lý:           Router xử lý:
  PC → Máy in             PC → Google
  PC → Camera             Nhà máy → HQ Hàn Quốc
  (cùng .120.0/21)        (mạng khác nhau hoàn toàn)
```

### 11.2 Router nhìn thấy gì mà Switch không thấy?

- **Switch** chỉ nhìn địa chỉ **MAC** (tầng 2) — chỉ biết dùng trong cùng LAN
- **Router** nhìn địa chỉ **IP** (tầng 3) — biết đường đi xuyên mạng

Router có **ít nhất 2 cổng**, mỗi cổng thuộc một mạng khác nhau:
```
Fortinet FortiGate trong nhà máy bạn:
  Cổng LAN (eth0): 192.168.120.1  ← phía mạng nội bộ
  Cổng WAN (eth1): 113.22.x.x     ← phía FPT Internet
```

### 11.3 Routing Table — "Bảng chỉ đường của Router"

Router có một bảng gọi là **Routing Table**, giống như bảng chỉ đường tại ngã ba:

```
┌────────────────────────────────────────────────────────┐
│           ROUTING TABLE — Fortinet FortiGate           │
├──────────────────┬─────────────┬──────────────────────┤
│  Đến mạng này   │  Đi bằng   │  Qua interface       │
├──────────────────┼─────────────┼──────────────────────┤
│ 192.168.120.0/21 │ Trực tiếp  │ eth0 (LAN)           │
│ 0.0.0.0/0        │ 113.22.0.1 │ eth1 (ra FPT)        │
└──────────────────┴─────────────┴──────────────────────┘

Đọc bảng:
  Dòng 1: Gói tin đến bất kỳ IP nào trong .120.0/21
           → Gửi thẳng ra cổng LAN (không cần Internet)
  Dòng 2: Gói tin đến bất kỳ đâu khác (0.0.0.0/0 = mọi nơi còn lại)
           → Gửi lên đường FPT → ra Internet
```

**Ví dụ:** Bạn gửi đến Google `142.250.197.46`:
```
Bước 1: Tra bảng dòng 1 — 142.250.197.46 có trong .120.0/21 không?
         Không → bỏ qua

Bước 2: Tra bảng dòng 2 — 0.0.0.0/0 khớp với tất cả
         → Gửi ra interface eth1 (FPT) → ra Internet ✅
```

---

## Chương 12: Firewall — "Kiểm soát viên cổng chính"

### 12.1 Tình huống cần Firewall

Nhà máy bạn kết nối Internet — nghĩa là cũng có **đường vào từ Internet**. Không có Firewall, bất kỳ ai trên Internet đều có thể thử kết nối đến máy tính trong nhà máy!

```
Không có Firewall:
  Hacker → Internet → Fortinet → Vào thẳng mạng nhà máy ← NGUY HIỂM!

Có Firewall:
  Hacker → Internet → Fortinet [KIỂM TRA] → ❌ CHẶN lại
  Bạn    → Internet → Fortinet [KIỂM TRA] → ✅ CHO QUA
```

### 12.2 Firewall kiểm tra những gì?

```
Mỗi gói tin đến Fortinet, hệ thống hỏi:

  ❓ IP nguồn có trong danh sách đen không?        → Chặn ngay
  ❓ Gói tin đi vào hay đi ra?                     → Rule khác nhau
  ❓ Port đích có được phép không?                  → Rule theo port
  ❓ Nội dung có chứa virus/malware không?          → Antivirus scan
  ❓ Website có bị chặn theo danh mục không?        → Web Filter
```

### 12.3 Stateful Firewall — "Lính gác nhớ mặt người ra vào"

**Stateless (cũ, đơn giản):** Kiểm tra từng gói tin một cách độc lập, không nhớ gì.

**Stateful (Fortinet dùng):** Nhớ **toàn bộ kết nối** đang diễn ra.

```
Tình huống thực tế:
   
  Bạn → kết nối HTTPS đến VietnamPlus.vn
  → Fortinet ghi: "Có kết nối từ .125.100 đến VietnamPlus"
  
  VietnamPlus gửi trang web về
  → Fortinet tra: "Đây là reply cho kết nối của .125.100" → CHO QUA ✅
  
  Hacker cố gửi gói lạ vào máy bạn
  → Fortinet tra: "Không có kết nối nào liên quan" → CHẶN ❌
```

**Lợi ích:** Bạn không cần mở port inbound cho từng website — Fortinet tự biết gói nào là "reply hợp lệ".

### 12.4 Fortinet FortiGate trong nhà máy bạn — 1 hộp 6 chức năng

```
┌────────────────────────────────────────────────────┐
│          FORTINET FORTIGATE — 192.168.120.1        │
│                                                    │
│  🔀 ROUTER      Kết nối LAN ↔ Internet            │
│  🔒 FIREWALL    Lọc tất cả traffic qua/lại        │
│  🏠 DHCP        Tự động cấp IP cho 34 thiết bị    │
│  🔁 NAT         Dịch 34 IP nội bộ ↔ 1 IP FPT     │
│  🌐 VPN         Kết nối từ xa an toàn             │
│  🦠 IPS/AV      Phát hiện và chặn tấn công        │
└────────────────────────────────────────────────────┘
```

**Ví dụ rules Firewall thực tế:**

| Rule | Hành động | Giải thích |
|:---|:---:|:---|
| LAN → Internet (HTTP/HTTPS) | ✅ Cho | Nhân viên duyệt web |
| LAN → Internet (BitTorrent) | ❌ Chặn | Tránh lãng phí băng thông |
| Internet → LAN (port 22 SSH) | ❌ Chặn | Không cho remote vào từ ngoài |
| Internet → LAN (port 443 nếu có server web) | ✅ Cho | Nếu có web server nội bộ |
| LAN → LAN (Camera → PC) | ✅ Cho | Xem camera từ phòng bảo vệ |

---

## Chương 13: NAT — "Lễ tân tổng đài 34 người, 1 số máy"

### 13.1 Tình huống thực tế

Giờ cao điểm: 10 nhân viên cùng lúc vào Internet. Tất cả đều có IP nội bộ riêng. FPT chỉ cấp **1 IP công cộng** cho nhà máy.

→ **Vấn đề:** Làm sao 10 người dùng chung 1 IP công cộng mà không lẫn lộn?

→ **Giải pháp:** NAT (Network Address Translation)

### 13.2 NAT hoạt động như thế nào?

**Ẩn dụ:** Công ty có 34 nhân viên, nhưng chỉ có 1 số điện thoại ra ngoài. Khi ai gọi vào, tổng đài (Fortinet) biết chuyển cho đúng người:

```
BƯỚC 1 — Gói tin đi ra:

  PC bạn   (125.100:54321) → Google 443
  PC đồng nghiệp (125.17:55001) → Facebook 443

  Fortinet nhận → Ghi bảng NAT → Đổi địa chỉ:
  → 113.22.x.x:40001 → Google (cho bạn)
  → 113.22.x.x:40002 → Facebook (cho đồng nghiệp)

BƯỚC 2 — Gói tin về:

  Google → 113.22.x.x:40001
  Fortinet tra bảng: "40001 = bạn (125.100:54321)"
  → Gửi đúng về máy bạn ✅

  Facebook → 113.22.x.x:40002
  Fortinet tra bảng: "40002 = đồng nghiệp (125.17:55001)"
  → Gửi đúng về máy đồng nghiệp ✅
```

**Bảng NAT Fortinet đang ghi:**
```
┌────────────────────┬──────────────────┬──────────────────┐
│  IP nội bộ:Port   │ IP công cộng:Port│ Thời gian        │
├────────────────────┼──────────────────┼──────────────────┤
│ 125.100:54321      │ 113.22.x.x:40001 │ 14:35:22         │
│ 125.17:55001       │ 113.22.x.x:40002 │ 14:35:45         │
│ 125.6:56000        │ 113.22.x.x:40003 │ 14:36:01 (Camera)│
└────────────────────┴──────────────────┴──────────────────┘
```

### 13.3 Port Forwarding — Mở cửa từ ngoài vào (cẩn thận!)

Mặc định NAT **ẩn** hoàn toàn mạng nội bộ khỏi Internet. Nhưng đôi khi cần mở một cửa cụ thể — ví dụ xem camera từ điện thoại khi đang ở nhà:

```
Cấu hình Port Forwarding trên Fortinet:
  Ai vào 113.22.x.x:8080 → chuyển sang 192.168.125.6:80 (camera)

Kết quả:
  Bạn gõ trên điện thoại: http://113.22.x.x:8080
  → Xem được camera nhà máy từ nhà ✅
```

> ⚠️ **Rủi ro:** Port forwarding là "cửa sổ mở vào mạng nội bộ". Phải đặt mật khẩu mạnh cho camera, dùng HTTPS, và chỉ mở khi thực sự cần.

---

## Chương 14: Access Point — "Trạm phát WiFi"

### 14.1 Tại sao không chỉ dùng cáp?

Một số thiết bị **không thể cắm dây**: điện thoại, laptop di động, máy tính bảng kiểm tra chất lượng dây chuyền...

→ **Access Point (AP)** cho phép các thiết bị này kết nối vào LAN qua sóng WiFi, như thể đang cắm dây.

```
📱 Điện thoại (không dây) ─ ─ ─ ─ sóng WiFi ─ ─ ─┐
                                                   │
💻 Laptop di động         ─ ─ ─ ─ sóng WiFi ─ ─ ─┤
                                                   │
                                          ┌────────┴──────┐
                                          │ ACCESS POINT  │
                                          │ (cắm cáp vào) │
                                          └────────┬──────┘
                                                   │ cáp Ethernet
                                          ┌────────┴──────┐
                                          │    SWITCH     │
                                          └───────────────┘
                                               (mạng LAN)
```

### 14.2 Hai băng tần WiFi — Dùng cái nào?

| | 2.4 GHz | 5 GHz |
|:---|:---|:---|
| **Ưu điểm** | Xuyên tường tốt, phủ sóng xa | Tốc độ cao, ít nhiễu |
| **Nhược điểm** | Chậm hơn, nhiều thiết bị dùng chung | Phủ sóng ngắn hơn |
| **Dùng khi** | Cần kết nối qua tường, xa AP | Gần AP, cần tốc độ |

> Máy bạn có **Realtek WiFi 6 (802.11ax)** — chuẩn mới nhất, hỗ trợ cả 2 băng tần, ưu tiên dùng 5 GHz nếu đủ gần AP.

---

## Chương 15: Cáp mạng — "Đường cao tốc vật lý"

### 15.1 Cáp Ethernet Cat5e/Cat6 — Cáp trong nhà máy

```
Nhìn bên ngoài: Như dây điện thoại nhưng to hơn, đầu cắm RJ-45

Bên trong: 8 sợi đồng, xoắn thành 4 cặp:
   🔴⚪ Cặp cam
   🟠⚪ Cặp cam/trắng
   🔵⚪ Cặp xanh dương
   🟢⚪ Cặp xanh lá

Tốc độ:
   Cat5e → 1 Gbps  (1000 Mbps) ← đủ cho hầu hết thiết bị
   Cat6  → 10 Gbps khi cáp ≤ 55m  (tốt hơn, chống nhiễu tốt hơn)
         → 1 Gbps  khi cáp 55m–100m  ← ⚠️ tụt tốc độ nếu cáp dài!
   Cat6a → 10 Gbps đến 100m    ← chuẩn đúng cho 10G (datacenter)

Lưu ý thực tế:
   Nhà máy kéo cáp >55m → dùng Cat6a hoặc chấp nhận 1 Gbps với Cat6
   Hầu hết thiết bị văn phòng 1 Gbps là đủ dù cáp Cat6 hay Cat6a

Giới hạn khoảng cách: 100 mét / đoạn
→ Nhà máy lớn cần đặt switch ở giữa hoặc dùng cáp quang
```

### 15.2 Cáp quang (Fiber Optic) — Đường cao tốc FPT

FPT dùng **cáp quang** để nối nhà máy bạn với Internet:

```
Cáp đồng (Ethernet):         Cáp quang (Fiber):
  Truyền tín hiệu điện          Truyền ánh sáng (photon)
  Tốc độ: 1-10 Gbps             Tốc độ: 1-100 Gbps
  Khoảng cách: 100m             Khoảng cách: hàng chục km
  Ảnh hưởng bởi: nhiễu điện    Không bị nhiễu điện từ
  Giá: rẻ                       Giá: đắt hơn

→ FPT dùng cáp quang đến tận modem nhà máy
→ Từ modem trở vào trong → cáp Ethernet bình thường
```

### 15.3 PoE — "Điện + Dữ liệu chung một dây"

**Vấn đề thực tế:** Camera nhà máy cần 2 thứ: **điện** và **dữ liệu**. Thường phải kéo 2 loại dây.

**Giải pháp PoE (Power over Ethernet):** Truyền cả điện lẫn dữ liệu qua **1 cáp Cat6 duy nhất**.

```
Switch PoE                         Camera IP
    │                                  │
    └───────── cáp Cat6 (50m) ─────────┘
               Truyền đồng thời:
               • Dữ liệu video ← → Switch → Server ghi hình
               • Điện 48V DC cấp cho camera hoạt động
```

**Lợi ích thực tế cho nhà máy bạn:**
- Camera `.125.6` và `.125.77` có thể dùng PoE
- Tiết kiệm: không cần kéo dây điện riêng đến từng camera
- Tiện quản lý: tắt/bật camera bằng phần mềm trên switch

### 15.4 USB Adapter của bạn — Tại sao lại cần?

```
💻 Máy bạn (không có cổng RJ-45 tích hợp)
       │
   [USB 3.0] ──── [ASIX AX88179 Adapter] ──── [RJ-45] ──── Switch
                   MAC: 9C-69-D3-69-A1-96
                   Tốc độ: 1 Gbps (Gigabit)
```

- Adapter chuyển giao tiếp từ USB sang Ethernet
- Hoạt động bình thường như card mạng thật
- Nhược điểm nhỏ: đôi khi kém ổn định hơn card mạng cắm trực tiếp vào mainboard

---

## Chương 16: Toàn cảnh nhà máy — Ghép tất cả lại

### 16.1 Sơ đồ vật lý — Các thiết bị cắm vào đâu

```
                         ☁️ INTERNET
                              │
                     cáp quang single-mode FPT
                              │
                    ┌─────────┴──────────┐
                    │    MODEM FPT       │  ← Chuyển quang → Ethernet
                    │    (ONT/ONU)       │
                    └─────────┬──────────┘
                              │ cáp Ethernet
                    ┌─────────┴──────────┐
                    │    FORTINET        │  192.168.120.1
                    │    FORTIGATE       │  MAC: 48-3A-02-xx
                    │  Router+FW+DHCP   │
                    └────────┬───────────┘
                             │
          ┌──────────────────┼──────────────────┐
          │                  │                   │
   ┌──────┴──────┐    ┌──────┴──────┐    ┌──────┴──────┐
   │  SWITCH     │    │  SWITCH     │    │  ACCESS     │
   │  Văn phòng  │    │  Xưởng SX   │    │  POINT WiFi │
   │  (24-port)  │    │  (24-port)  │    └─────────────┘
   └──────┬──────┘    └──────┬──────┘
          │                  │
  ┌───┬───┴──┬───┐    ┌──────┼──────┐
  │   │      │   │    │      │      │
 💻  💻   🖨️  💻  📷   📷    ⚙️
.17 .37  .4 .100 .6   .77   .9
```

### 16.2 Sơ đồ logic — Ai trong "phường" nào

```
┌──────────────────────────────────────────────────────┐
│   MẠNG PHƯỜNG: 192.168.120.0/21                      │
│   Gồm tất cả IP từ .120.1 đến .127.254              │
│                                                      │
│   .120.1   → 🔒 Fortinet (GW/DHCP/FW) — cổng chính │
│   .125.4   → 🖨️  RICOH Máy in                       │
│   .125.6   → 📷 Hikvision Camera 1                  │
│   .125.9   → ⚙️  Advantech (Máy CN)                 │
│   .125.17  → 💻 Dell PC (đồng nghiệp)               │
│   .125.37  → 💻 Dell PC (đồng nghiệp)               │
│   .125.77  → 📷 Hikvision Camera 2                  │
│   .125.100 → 💻 Bạn (ASIX USB Adapter)              │
│   ...20+ thiết bị khác                              │
└──────────────────────────────────────────────────────┘
```

---

## Chương 17: Câu chuyện đầy đủ — Từ "Ctrl+P" đến tờ giấy in ra

**Kịch bản:** Bạn nhấn in tài liệu từ máy `192.168.125.100` đến máy in `192.168.125.4`.

```
Giây 0.000: Bạn nhấn Ctrl+P

Giây 0.001: Máy tính kiểm tra: IP đích (.125.4) có cùng "phường" không?
            125 AND 248 = 120 = cùng phường → KHÔNG CẦN GATEWAY ✅

Giây 0.002: Máy tính kiểm tra ARP cache: có MAC của .125.4 chưa?
            Nếu có → dùng luôn
            Nếu chưa → gửi ARP broadcast hỏi → máy in trả lời MAC

Giây 0.003: Đóng gói dữ liệu:
            [MAC máy in][MAC bạn][IP máy in][IP bạn][Lệnh in]

Giây 0.004: Switch nhận frame, tra bảng MAC:
            "MAC máy in ở Port 6" → gửi thẳng Port 6

Giây 0.005: Máy in nhận lệnh, bắt đầu xử lý

Giây 3-10:  Tài liệu in ra 🖨️ ✅
```

**So sánh với mở Google (xuyên Internet):**
```
Ctrl+P → Máy in:      ~0.005 giây (5ms)  — chỉ qua switch
Mở Google:            ~50-100ms           — qua Fortinet + FPT + Internet
```

---

## Chương 18: Tóm tắt & Tự kiểm tra

### Bảng thiết bị

| Thiết bị | Địa chỉ dùng | Làm gì | Trong nhà máy |
|:---|:---:|:---|:---|
| **Switch** | MAC | Kết nối LAN, gửi đúng cổng | 1-2 cái (24-port) |
| **Router** | IP | Kết nối các mạng khác nhau | Tích hợp trong Fortinet |
| **Firewall** | IP + Port | Lọc, bảo vệ | Fortinet FortiGate |
| **AP** | MAC (WiFi) | Phát sóng WiFi | Có thể có |
| **Modem** | — | Chuyển tín hiệu quang ↔ điện | Modem FPT |
| **PoE Switch** | MAC | Switch + cấp điện cho camera/AP | Nên mua thêm |

### 3 câu tự kiểm tra

> **Câu 1:** Khi máy bạn gửi email đến đồng nghiệp trong cùng mạng nội bộ — gói tin có đi qua Fortinet không?
> → Không. Cùng phường → switch chuyển thẳng.

> **Câu 2:** 10 người cùng vào Internet, Internet thấy bao nhiêu địa chỉ IP của nhà máy?
> → Chỉ 1 IP công cộng (của FPT). NAT ẩn hết 34 IP nội bộ.

> **Câu 3:** Camera Hikvision `.125.6` cần 2 thứ gì để hoạt động? Dùng PoE giải quyết thế nào?
> → Cần điện và dữ liệu mạng. PoE truyền cả hai qua 1 cáp Cat6 từ switch.

---

> 📖 **Tiếp theo → [Phần 3: Port, Giao thức & Bảo mật](./kien-thuc-mang-phan3.md)**
> Bạn sẽ hiểu tại sao website dùng port 443, tại sao video call không bị giật khi mạng mất gói, và cách chẩn đoán sự cố mạng bằng lệnh Windows.
