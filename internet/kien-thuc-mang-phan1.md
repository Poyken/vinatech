# 📚 HỆ THỐNG KIẾN THỨC MẠNG — Phần 1: NỀN TẢNG

> 🎯 **Mục tiêu:** Đọc xong phần này, bạn sẽ hiểu tại sao máy tính của bạn có thể in tài liệu ra máy in RICOH, xem camera Hikvision, và vào được Google — mà không cần cắm dây trực tiếp giữa chúng.

---

## Chương 1: Câu chuyện bắt đầu từ khu nhà máy

### 1.1 Tình huống thực tế

Hôm nay bạn cần in tài liệu. Bạn nhấn Ctrl+P trên máy tính. Tài liệu xuất hiện ở máy in RICOH cách bạn 20 mét.

**Câu hỏi:** Làm sao máy tính biết phải gửi lệnh in đến đúng cái máy in đó, mà không phải camera hay máy tính của đồng nghiệp?

**Câu trả lời ngắn:** Vì mỗi thiết bị trong mạng có **địa chỉ riêng**, và máy tính biết địa chỉ của máy in.

Câu chuyện dài hơn — đó chính là nội dung của Phần 1 này.

### 1.2 Nhà máy của bạn nhìn từ góc độ mạng

Hiện tại trong mạng nhà máy bạn có khoảng **34 thiết bị** cùng kết nối với nhau:

```
💻 Các máy tính Dell (PC văn phòng)
📷 Camera Hikvision (giám sát)
🖨️ Máy in RICOH (dùng chung)
⚙️ Máy tính Advantech (điều khiển dây chuyền)
🔒 Fortinet (cổng ra Internet, bảo mật)
```

Tất cả đều kết nối vào **cùng một hệ thống mạng** — giống như các căn phòng trong cùng một tòa nhà đều dùng chung hệ thống điện thoại nội bộ.

---

## Chương 2: Địa chỉ IP — "Số nhà" của mỗi thiết bị

### 2.1 Vấn đề: Làm sao phân biệt 34 thiết bị?

Trong nhà máy có 34 thiết bị. Khi bạn gửi lệnh in, làm sao hệ thống biết gửi đến **máy in RICOH** chứ không phải **camera** hay **máy tính của đồng nghiệp**?

→ **Giải pháp:** Đặt cho mỗi thiết bị một **số nhà** riêng — gọi là **địa chỉ IP**.

### 2.2 IP trông như thế nào?

```
Địa chỉ IP của bạn: 192.168.125.100
                     │   │   │   │
                     │   │   │   └── Số thứ 4 (từ 0-255)
                     │   │   └────── Số thứ 3 (từ 0-255)
                     │   └────────── Số thứ 2 (từ 0-255)
                     └────────────── Số thứ 1 (từ 0-255)
```

4 số, cách nhau bằng dấu chấm, mỗi số từ **0 đến 255**.

> **Tại sao tối đa 255?** Vì mỗi số được lưu trong 8 bit nhị phân. 8 bit tối đa = `11111111` = 255.

### 2.3 Địa chỉ thực tế của thiết bị trong nhà máy bạn

| Thiết bị | Địa chỉ IP | Hình dung |
|:---|:---:|:---|
| 💻 Máy tính của bạn | `192.168.125.100` | Phòng 100 tầng 125 |
| 🖨️ Máy in RICOH | `192.168.125.4` | Phòng 4 tầng 125 |
| 📷 Camera Hikvision 1 | `192.168.125.6` | Phòng 6 tầng 125 |
| 📷 Camera Hikvision 2 | `192.168.125.77` | Phòng 77 tầng 125 |
| ⚙️ Máy Advantech | `192.168.125.9` | Phòng 9 tầng 125 |
| 🔒 Fortinet (Gateway) | `192.168.120.1` | Phòng bảo vệ cổng chính |

→ Khi bạn in tài liệu, máy tính gửi lệnh đến đúng **`192.168.125.4`** = máy in RICOH. Không thể nhầm.

### 2.4 IP nội bộ vs IP công cộng — Hai loại địa chỉ

**Hình dung:** Trong tòa nhà có **số phòng nội bộ** (chỉ dùng trong tòa nhà). Khi gọi điện ra ngoài, bạn phải dùng **số điện thoại chính thức** của công ty.

```
IP NỘI BỘ (Private IP) — chỉ dùng trong mạng nhà máy:
  192.168.x.x   ← Nhà máy bạn đang dùng dải này
  10.x.x.x
  172.16.x.x đến 172.31.x.x

  → Ai cũng có thể dùng, không trùng ngoài Internet
  → Không thể truy cập từ Internet (ẩn hoàn toàn)

IP CÔNG CỘNG (Public IP) — dùng trên Internet toàn cầu:
  Ví dụ: 113.22.0.37 (IP công cộng của FPT nhà máy bạn)

  → Mỗi IP là DUY NHẤT trên toàn thế giới
  → Ai cũng có thể kết nối đến (nếu không có firewall chặn)
```

**Ví dụ thực tế:**
```
Bạn tìm Google → máy bạn dùng IP nội bộ: 192.168.125.100
                → Fortinet "dịch" thành IP công cộng: 113.22.x.x
                → Google thấy bạn đến từ: 113.22.x.x
                → Google gửi kết quả về: 113.22.x.x
                → Fortinet "dịch ngược" lại → về đúng máy bạn

Quá trình "dịch địa chỉ" này gọi là NAT (học ở Phần 2)
```

---

## Chương 3: Địa chỉ MAC — "Số CCCD" của card mạng

### 3.1 Chưa đủ — Tại sao cần thêm MAC?

IP là **địa chỉ có thể thay đổi** (hôm nay bạn ở phòng 100, tuần sau chuyển sang phòng 200). Nhưng thiết bị phần cứng thì theo bạn.

**Vấn đề:** Khi gói tin đến switch (thiết bị phân luồng mạng), switch cần biết **cổng vật lý nào** mà thiết bị đang cắm vào — không thể dùng IP vì IP có thể thay đổi.

→ Giải pháp: **MAC Address** — mã số được ghi vào phần cứng card mạng khi sản xuất, **không đổi được**.

### 3.2 MAC trông như thế nào?

```
MAC của máy bạn: 9C-69-D3-69-A1-96
                  ─────┬─────  ─────┬─────
                       │             │
               3 cặp đầu (OUI)  3 cặp sau
               = Mã nhà sản xuất  = Số serial riêng
```

- **`9C-69-D3`** = OUI của hãng **ASIX Electronics** (nhà sản xuất chip USB adapter của bạn)
- **`69-A1-96`** = số serial riêng của card mạng đó

**Bảng OUI thiết bị trong nhà máy bạn:**

| OUI (3 cặp đầu) | Nhà sản xuất | Thiết bị |
|:---:|:---:|:---|
| `48-3A-02` | **Fortinet** | Gateway/Firewall |
| `E0-CA-3C` | **Hikvision** | Camera an ninh |
| `8C-EC-4B` | **Dell** | Máy tính văn phòng |
| `58-38-79` | **RICOH** | Máy in |
| `CC-82-7F` | **Advantech** | Máy tính công nghiệp |
| `9C-69-D3` | **ASIX** | USB-to-Ethernet (máy bạn) |

> **Ứng dụng thực tế:** Khi chạy lệnh `arp -a`, bạn thấy danh sách MAC. Chỉ cần tra 3 cặp đầu là biết thiết bị đó là gì — rất hữu ích khi điều tra thiết bị lạ trong mạng.

### 3.3 IP và MAC — Hai địa chỉ, hai mục đích khác nhau

Hình dung như giao hàng trong nội thành:

```
IP Address  = Địa chỉ nhà (123 Lê Lợi, Q1)
              → Dùng để tìm đường đến khu vực đó

MAC Address = Tên người nhận (Nguyễn Văn A)
              → Dùng để giao đúng cho người khi đã đến tòa nhà
```

| So sánh | IP Address | MAC Address |
|:---|:---|:---|
| **Ẩn dụ** | Địa chỉ nhà | Số CCCD |
| **Thay đổi được?** | ✅ Có (DHCP cấp mới) | ❌ Không (gắn cứng) |
| **Phạm vi dùng** | Cả mạng, qua router | Chỉ trong cùng mạng LAN |
| **Ai dùng?** | Router, máy tính | Switch (phân luồng nội bộ) |
| **Ví dụ** | `192.168.125.100` | `9C-69-D3-69-A1-96` |

---

## Chương 4: Subnet Mask — "Ranh giới khu phố"

### 4.1 Câu hỏi quan trọng nhất

Bạn muốn in tài liệu → máy tính cần gửi đến máy in `192.168.125.4`.

Câu hỏi: Máy tính **làm sao biết** máy in đang ở **cùng tòa nhà** (gửi trực tiếp) hay ở **tòa nhà khác** (phải qua người trung gian)?

→ **Subnet Mask** chính là thứ giúp máy tính trả lời câu hỏi này.

### 4.2 Ẩn dụ: Phân biệt người trong phường với người khác phường

Hãy hình dung bạn sống ở **Phường Bến Nghé, Quận 1, TP.HCM**.

- Muốn gặp người **trong cùng phường** → đi bộ đến nhà họ trực tiếp
- Muốn gặp người **khác phường/quận** → phải ra đường lớn, gọi xe (đi qua ngã lớn)

Trong mạng máy tính:
- **Cùng mạng** → gửi trực tiếp qua switch (nhanh)
- **Khác mạng** → phải qua Gateway (Fortinet) rồi mới đến đích

**Subnet Mask chính là thứ định ra ranh giới "phường" để máy tính quyết định.**

### 4.3 Subnet Mask là gì? — Không cần nhớ nhị phân

Subnet Mask của nhà máy bạn: **`255.255.248.0`**

Cách đọc đơn giản nhất: Mask `255.255.248.0` nói với máy tính rằng:

> "Hai số đầu (`192.168`) và **phần lớn** số thứ ba là TÊN KHU PHỐ. Phần còn lại là SỐ NHÀ."

```
IP của bạn:    192 . 168 . 125 . 100
Subnet Mask:   255 . 255 . 248 .   0
               ─────────────────────
                       ↓
Khu phố bạn ở: 192.168. 120.   0    ← "Phường 120"
```

**Kết quả:** Máy bạn thuộc **"Phường 192.168.120.0"**

Mọi thiết bị có địa chỉ từ `192.168.120.1` đến `192.168.127.254` đều là **hàng xóm cùng phường** — gửi trực tiếp, không cần qua Fortinet.

### 4.4 Tại sao `255.255.248.0` lại ra "Phường 120"? — Giải thích bước từng bước

> ⚡ Phần này hơi kỹ thuật. Nếu bạn chỉ cần dùng được thì **đọc 4.3 là đủ**. Đọc phần này nếu muốn hiểu sâu hơn.

Máy tính dùng phép **AND** để tìm khu phố. Phép AND rất đơn giản:

```
Quy tắc AND (như nhân thông thường nhưng chỉ với 0 và 1):
  1 AND 1 = 1   (cả hai đều có → có)
  1 AND 0 = 0   (một bên không có → không có)
  0 AND 1 = 0
  0 AND 0 = 0
```

**Áp dụng với IP `192.168.125.100` và Mask `255.255.248.0`:**

```
Số 255 trong binary = 11111111 (8 số 1)
  192 AND 255:  giữ nguyên → 192  ✓

Số 255 trong binary = 11111111
  168 AND 255:  giữ nguyên → 168  ✓

Số 248 trong binary = 11111000  (5 số 1, rồi 3 số 0)
  125 AND 248:  (phần phức tạp — tính bên dưới)

Số 0 trong binary = 00000000
  100 AND 0:    xóa hết → 0  ✓
```

**Tính riêng `125 AND 248`:**

```
125 viết dạng nhị phân: 0 1 1 1 1 1 0 1
248 viết dạng nhị phân: 1 1 1 1 1 0 0 0
                         ─────────────────
AND từng cột:            0 1 1 1 1 0 0 0  =  120

Vì: cột 1: 0×1=0, cột 2: 1×1=1, cột 3: 1×1=1,
    cột 4: 1×1=1, cột 5: 1×1=1, cột 6: 1×0=0,
    cột 7: 0×0=0, cột 8: 1×0=0
```

**Kết quả:** `192.168.125.100 AND 255.255.248.0 = 192.168.120.0` = địa chỉ khu phố của bạn.

### 4.5 Vậy "Phường 120" trải từ đâu đến đâu?

```
┌────────────────────────────────────────────────────────────────┐
│   Mạng: 192.168.120.0 / Mask 255.255.248.0                    │
│                                                                │
│   Địa chỉ đầu tiên: 192.168.120.0   ← Tên phường (không dùng)│
│   Thiết bị đầu tiên: 192.168.120.1  ← Fortinet Gateway        │
│                  ↕  (2044 địa chỉ giữa)                       │
│   Thiết bị cuối:    192.168.127.254                           │
│   Địa chỉ cuối:    192.168.127.255  ← Broadcast (không dùng) │
│                                                                │
│   Tổng sức chứa: 2046 thiết bị                               │
└────────────────────────────────────────────────────────────────┘
```

**Tại sao từ `.120` đến `.127`?** Vì Mask `248` chỉ cho phép số thứ 3 dao động trong 8 giá trị: 120, 121, 122, 123, 124, 125, 126, 127. Mỗi giá trị × 256 địa chỉ = 2048 tổng, trừ 2 = 2046 host.

### 4.6 Ứng dụng: Máy tính quyết định gửi trực tiếp hay qua Gateway?

Mỗi khi gửi dữ liệu, máy tính tự động làm 3 bước (nhanh đến mức không nhận ra):

```
Tình huống: Bạn in tài liệu → máy tính gửi đến 192.168.125.4 (Máy in)

Bước 1: Tính "phường" của MÌNH
        192.168.125.100 AND 255.255.248.0 = 192.168.120.0
        → Tôi ở phường .120.0

Bước 2: Tính "phường" của ĐÍCH (máy in)
        192.168.125.4   AND 255.255.248.0 = ?
        125 AND 248 = 120
        → 192.168.120.0
        → Máy in cũng ở phường .120.0

Bước 3: So sánh
        .120.0 = .120.0 → CÙNG PHƯỜNG!
        → Gửi TRỰC TIẾP qua switch, không cần Fortinet
        → Lệnh in đến máy in ngay lập tức ✅
```

**So sánh với trường hợp khác mạng:**

```
Tình huống: Bạn mở Google → máy tính gửi đến 142.250.197.46

Bước 1: Phường của mình     = 192.168.120.0
Bước 2: Phường của Google?
        142 AND 248 = 136  (không phải 120!)
        → Phường 142.136.0.0
Bước 3: Khác phường!
        → KHÔNG thể gửi thẳng
        → Gửi đến GATEWAY (Fortinet) để chuyển tiếp
        → Fortinet sẽ đưa ra Internet cho bạn ✅
```

**Bảng quyết định nhanh:**

| Máy bạn gửi đến | Phường đích | Kết quả | Đi đường nào? |
|:---|:---:|:---:|:---|
| 🖨️ Máy in `.125.4` | `.120.0` | ✅ Cùng | Switch → Máy in (< 1ms) |
| 📷 Camera `.125.6` | `.120.0` | ✅ Cùng | Switch → Camera (< 1ms) |
| ⚙️ Advantech `.125.9` | `.120.0` | ✅ Cùng | Switch → Advantech (< 1ms) |
| 🌐 Google `8.8.8.8` | `8.8.0` | ❌ Khác | Switch → Fortinet → FPT → Google (~50ms) |
| 📧 Server Hàn Quốc | Khác hẳn | ❌ Khác | Switch → Fortinet → FPT → HQ (~100ms) |

### 4.7 Ký hiệu `/21` — Cách viết tắt

Thay vì viết `255.255.248.0` dài dòng, người ta dùng dấu `/` + số lượng bit 1:

```
255.255.248.0 = 11111111.11111111.11111000.00000000
                └─────────────── 21 số 1 ──────────┘

→ Viết tắt: /21
→ Ví dụ đầy đủ: 192.168.120.0/21
```

**Bảng tra cứu thường gặp:**

| Ký hiệu | Subnet Mask | Số thiết bị tối đa | Thích hợp cho |
|:---:|:---|:---:|:---|
| `/24` | `255.255.255.0` | **254** | Nhà, văn phòng nhỏ |
| `/23` | `255.255.254.0` | **510** | Văn phòng vừa |
| `/22` | `255.255.252.0` | **1022** | Công ty vừa |
| **`/21`** | **`255.255.248.0`** | **2046** | **← Nhà máy bạn** |
| `/20` | `255.255.240.0` | **4094** | Doanh nghiệp lớn |
| `/16` | `255.255.0.0` | **65,534** | Tập đoàn lớn |

> 💡 **Công thức:** `Số thiết bị = 2^(32 - số sau dấu /) - 2`
>
> Nhà máy bạn `/21`: → `2^(32-21) - 2 = 2^11 - 2 = 2048 - 2 = **2046**`

---

## Chương 5: Gateway — "Bảo vệ cổng chính"

### 5.1 Hình dung

Nhà máy của bạn giống một **khu công nghiệp có tường rào**. Muốn ra ngoài (ra Internet) hay vào trong, phải qua **cổng bảo vệ duy nhất** — đó chính là **Gateway**.

```
┌──────────────────────────────────────────────────────────┐
│                   MẠNG NỘI BỘ NHÀ MÁY                   │
│                                                          │
│   💻 PC bạn      📷 Camera      🖨️ Máy in               │
│        │               │              │                  │
│        └───────────────┴──────────────┘                  │
│                         │                               │
│              (Giao tiếp nội bộ — tự do)                 │
│                                                          │
│  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─  │
│              (Muốn ra ngoài? Phải qua đây)               │
│                                                          │
│                 [ CỔNG BẢO VỆ / GATEWAY ]               │
│                    Fortinet 192.168.120.1                │
└──────────────────────────┬───────────────────────────────┘
                           │
                    🌐 INTERNET
```

### 5.2 Gateway làm gì cụ thể?

**Ví dụ:** Bạn vào Google.

```
💻 PC bạn (192.168.125.100)
    │
    │  "Gửi gói tin đến 142.250.197.46 (Google)"
    │  → Khác phường → phải qua Gateway
    ▼
🔒 Fortinet Gateway (192.168.120.1)
    │  Nhận gói tin → kiểm tra: "Có được phép không?"
    │  → Được phép → đổi địa chỉ thành IP công cộng → gửi ra FPT
    ▼
☁️ Google (142.250.197.46)
    │  Nhận request → gửi trang web về IP công cộng nhà máy
    ▼
🔒 Fortinet Gateway
    │  Nhận phản hồi → "Đây là cho PC bạn" → chuyển về
    ▼
💻 PC bạn → trang Google hiện ra ✅
```

### 5.3 Fortinet trong nhà máy bạn làm 3 việc cùng lúc

Địa chỉ `192.168.120.1` là **Fortinet FortiGate** — một thiết bị đa năng:

```
┌─────────────────────────────────────────────────┐
│            FORTINET 192.168.120.1               │
│                                                 │
│  1️⃣ GATEWAY/ROUTER                              │
│     Chuyển dữ liệu giữa:                       │
│     Mạng nội bộ (192.168.120.0/21)              │
│     ↕ Internet (qua FPT Telecom)                │
│                                                 │
│  2️⃣ FIREWALL (Lính gác)                         │
│     Chặn: virus, hacker, website xấu           │
│     Cho qua: traffic hợp lệ                    │
│                                                 │
│  3️⃣ DHCP SERVER (Phát số nhà)                   │
│     Tự động cấp IP cho 34 thiết bị             │
│     → Không cần đặt tay từng cái               │
└─────────────────────────────────────────────────┘
```

---

## Chương 6: DHCP — "Nhân viên phát số nhà tự động"

### 6.1 Vấn đề nếu không có DHCP

Nhà máy có 34 thiết bị. Nếu phải đặt IP tay từng cái:
- Tốn công (34 lần vào cài đặt)
- Dễ nhầm lẫn (hai máy xài cùng IP → xung đột, mất kết nối)
- Có người mới cắm laptop → phải nhớ còn IP nào chưa dùng

→ Đây là lúc **DHCP** giải cứu.

### 6.2 DHCP hoạt động như thế nào?

**Hình dung:** Bạn vào khách sạn. Lễ tân (DHCP Server) tự động phát số phòng cho bạn — bạn không cần chọn, không cần nhớ, chỉ cần nhận chìa khóa và vào phòng.

```
Bạn cắm dây mạng vào laptop (hoặc bật WiFi):

💻 Laptop mới               🔒 Fortinet (DHCP Server)
    │                                │
    │──→ "Xin chào! Tôi mới đến,    │  ← DISCOVER
    │     ai có thể giúp tôi?"       │
    │                                │
    │   ←── "Tôi đây! Tôi đề xuất   │  ← OFFER
    │        cho bạn IP 192.168.125.100, dùng trong 7 ngày"
    │                                │
    │──→ "Cảm ơn! Tôi nhận IP đó"   │  ← REQUEST
    │                                │
    │   ←── "OK! Xác nhận:          │  ← ACK
    │        IP: 192.168.125.100
    │        Mask: 255.255.248.0
    │        Gateway: 192.168.120.1
    │        DNS: 8.8.8.8"
    │
    ✅ Laptop giờ đã có đủ thông tin để dùng mạng
```

**4 bước DORA:** Discover → Offer → Request → Acknowledge

### 6.3 Lease — "Thuê IP có thời hạn"

IP không phải vĩnh viễn. Fortinet "cho thuê" IP trong **7 ngày**:

```
Bạn chạy lệnh: ipconfig /all

DHCP Enabled:  Yes
DHCP Server:   192.168.120.1  ← Fortinet cấp
Lease Obtained: 30/03/2026    ← Nhận lúc nào
Lease Expires:  06/04/2026    ← Hết hạn sau 7 ngày
```

**Điều gì xảy ra sau 7 ngày?**
- Nếu máy vẫn đang bật → tự động gia hạn, ngầm, bạn không thấy gì
- Nếu máy tắt quá 7 ngày → IP có thể được cấp cho thiết bị khác
- Khi bật lại → máy xin IP mới (có thể được IP khác, hoạt động bình thường)

---

## Chương 7: DNS — "Danh bạ điện thoại của Internet"

### 7.1 Vấn đề mà DNS giải quyết

Máy tính **chỉ hiểu số** (địa chỉ IP). Nhưng con người nhớ **tên** tốt hơn số.

```
Bạn dễ nhớ:    google.com
Máy tính cần:  142.250.197.46

Bạn dễ nhớ:    facebook.com
Máy tính cần:  157.240.221.35

Bạn dễ nhớ:    mail.google.com (Gmail)
Máy tính cần:  108.177.125.83
```

→ **DNS** là hệ thống chuyển đổi từ **tên** sang **số**, tự động, không cần bạn làm gì.

### 7.2 Cách DNS hoạt động — Ví dụ từng bước

**Bạn gõ `google.com` vào trình duyệt:**

```
Bước 1: Trình duyệt hỏi hệ điều hành:
        "IP của google.com là bao nhiêu?"

Bước 2: Máy tính tự hỏi mình trước (DNS cache):
        "Tôi đã biết rồi chưa?"
        → Nếu biết rồi → dùng luôn (nhanh hơn)
        → Nếu chưa biết → đi hỏi DNS server

Bước 3: Gửi query đến DNS server (8.8.8.8 — Google Public DNS):
        Hỏi: "google.com = IP gì?"
        Trả lời: "= 142.250.197.46"

Bước 4: Máy tính nhớ lại (cache), rồi kết nối đến 142.250.197.46

Bước 5: Trang Google hiện ra ✅
```

### 7.3 DNS trong nhà máy bạn

```
DNS Server đang dùng: 8.8.8.8 (Google Public DNS)
```

**Tại sao dùng 8.8.8.8?**

| | Google DNS 8.8.8.8 | DNS riêng của công ty |
|:---|:---|:---|
| Chi phí | Miễn phí | Phải cài đặt server riêng |
| Tốc độ | Nhanh, ổn định | Tùy thuộc vào server nội bộ |
| Giải quyết tên nội bộ | ❌ Không được | ✅ Có thể |
| Ví dụ không làm được | `mayinricoh.nhamay.local` | Làm được nếu cấu hình |

**Hạn chế thực tế:** Vì không có DNS nội bộ, bạn không thể gõ tên máy để kết nối — chỉ có thể gõ IP trực tiếp:
```
✅ \\192.168.125.4   (kết nối máy in bằng IP)
❌ \\mayinricoh      (không hoạt động vì không có DNS nội bộ)
```

### 7.4 DNS Cache — Tại sao đôi khi web không load dù mạng ổn?

DNS cache là bộ nhớ lưu kết quả tra cứu. Đôi khi cache cũ → trang web không mở được.

```
Lệnh xóa DNS cache:
  ipconfig /flushdns

Khi nào dùng:
  - Website trước mở được, giờ không mở
  - Vừa đổi DNS server
  - Trang web mở ra nhưng không đúng nội dung
```

---

## Chương 8: Tổng kết — Đọc lại `ipconfig /all` lần này hiểu thật sự

### 8.1 Output ipconfig /all của bạn — Giải thích từng dòng

```
Ethernet adapter Ethernet 2:

   Physical Address: 9C-69-D3-69-A1-96
   ↑ MAC address — số CCCD của card mạng ASIX (USB adapter)
     Không thay đổi, gắn cứng vào phần cứng

   DHCP Enabled: Yes
   ↑ Nhận IP tự động từ DHCP server (Fortinet)
     Bạn không cần đặt IP tay

   IPv4 Address: 192.168.125.100
   ↑ "Số nhà" của bạn trong mạng nhà máy
     Do Fortinet cấp qua DHCP

   Subnet Mask: 255.255.248.0
   ↑ Ranh giới "khu phố" — xác định ai là hàng xóm
     125 AND 248 = 120 → bạn thuộc "phường 192.168.120.0"
     Hàng xóm: mọi IP từ .120.1 đến .127.254

   Default Gateway: 192.168.120.1
   ↑ Fortinet — cổng duy nhất ra Internet
     Mọi gói tin đến IP NGOÀI dải .120~.127 đều qua đây

   DHCP Server: 192.168.120.1
   ↑ Chính Fortinet vừa làm Gateway vừa cấp IP cho bạn

   Lease Obtained: 30/03/2026
   Lease Expires:  06/04/2026
   ↑ IP thuê 7 ngày, tự gia hạn ngầm khi cần

   DNS Servers: 8.8.8.8
   ↑ Google Public DNS — dịch google.com → 142.250.197.46
```

### 8.2 Kết nối toàn bộ câu chuyện — Từ "in tài liệu" đến "mở Google"

**Kịch bản 1: Bạn nhấn Ctrl+P → in ra RICOH**

```
1. Máy tính muốn gửi đến 192.168.125.4 (máy in)
2. Tính khu phố đích: 125 AND 248 = 120 → phường 192.168.120.0
3. Phường đích = phường mình → CÙNG MẠNG
4. Tìm MAC của máy in qua ARP
5. Gửi thẳng qua switch → đến RICOH
   Thời gian: < 1ms ⚡
```

**Kịch bản 2: Bạn mở google.com**

```
1. DNS: dịch "google.com" → 142.250.197.46
2. Máy tính muốn gửi đến 142.250.197.46
3. Tính khu phố đích: 142 AND 248 = 136 → khác phường
4. KHÁC MẠNG → gửi đến Gateway (Fortinet 192.168.120.1)
5. Fortinet nhận, kiểm tra firewall rule → cho qua
6. Fortinet đổi IP nguồn: 125.100 → 113.22.x.x (IP công cộng)
7. Gửi ra FPT Telecom → Internet → Google
8. Google trả lời về → Fortinet dịch ngược lại
9. Về đúng máy bạn
   Thời gian: ~50-100ms 🌐
```

### 8.3 Sơ đồ toàn cảnh nhà máy bạn

```
                      🌐 INTERNET (FPT Telecom)
                             │
              ┌──────────────┴──────────────┐
              │    🔒 FORTINET 192.168.120.1│
              │    ✅ Gateway (cổng ra net)  │
              │    ✅ DHCP (cấp IP)         │
              │    ✅ Firewall (bảo vệ)     │
              └──────────────┬──────────────┘
                             │
           ┌─────────────────┼─────────────────┐
           │                 │                  │
    ┌──────┴──────┐   ┌──────┴──────┐   ┌──────┴──────┐
    │ 💻 PC bạn  │   │ 📷 Camera  │   │ 🖨️ Máy in  │
    │  .125.100  │   │  .125.6    │   │  .125.4    │
    │            │   │            │   │            │
    │MAC:9C69D3  │   │MAC:E0CA3C  │   │MAC:583879  │
    └────────────┘   └────────────┘   └────────────┘
         │                 │                 │
         └─────────────────┴─────────────────┘
         Tất cả trong cùng "phường" 192.168.120.0
         → Nói chuyện trực tiếp, không qua Fortinet
```

### 8.4 Bảng tra cứu nhanh

| Khái niệm | Giá trị trong nhà máy bạn | Giải thích đơn giản |
|:---|:---:|:---|
| **IP của bạn** | `192.168.125.100` | Số nhà của bạn |
| **MAC của bạn** | `9C-69-D3-69-A1-96` | Số CCCD card mạng |
| **Subnet Mask** | `255.255.248.0` (/21) | Ranh giới khu phố |
| **Khu phố của bạn** | `192.168.120.0` | Tên phường (IP AND Mask) |
| **Hàng xóm** | `.120.1` đến `.127.254` | 2046 địa chỉ cùng phường |
| **Gateway** | `192.168.120.1` | Fortinet — cổng ra Internet |
| **DHCP Server** | `192.168.120.1` | Fortinet — cấp IP tự động |
| **DNS Server** | `8.8.8.8` | Google — dịch tên → số |
| **IP công cộng** | `113.22.x.x` (FPT) | Số điện thoại của nhà máy |

### 8.5 3 câu hỏi để tự kiểm tra

> Nếu trả lời được 3 câu này, bạn đã hiểu Phần 1:

**Câu 1:** Tại sao máy in RICOH có địa chỉ `192.168.125.4` mà không phải bất kỳ số nào khác?
> → Vì Fortinet DHCP đã cấp IP đó cho máy in (hoặc máy in được đặt IP tĩnh).

**Câu 2:** Máy bạn (`192.168.125.100`) gửi dữ liệu đến `192.168.125.77` (Camera 2) — có phải qua Fortinet không?
> → Không. `125 AND 248 = 120` = cùng phường → gửi thẳng qua switch.

**Câu 3:** Tại sao khi đổi từ mạng WiFi nhà về mạng nhà máy, IP của bạn thay đổi nhưng MAC thì không?
> → Vì IP do DHCP cấp (thay đổi theo mạng), còn MAC là "CCCD" gắn cứng vào phần cứng.

---

> 📖 **Tiếp theo → [Phần 2: Thiết bị mạng & Cách chúng kết nối](./kien-thuc-mang-phan2.md)**
> Bạn sẽ học: Switch dùng MAC Table thế nào, Router đọc Routing Table ra sao, Firewall lọc traffic như thế nào, và NAT hoạt động chi tiết.

> 📎 **Đọc thêm → [Phụ lục: Các khái niệm cơ bản mở rộng](./kien-thuc-mang-co-ban-mo-rong.md)**
> Bandwidth vs Throughput vs Latency · Unicast/Broadcast/Multicast · Hub vs Switch · IP đặc biệt (127.0.0.1, 169.254.x.x) · IP Classes · MTU · Full/Half Duplex · Encapsulation · ICMP chi tiết · Hostname & Hosts file
