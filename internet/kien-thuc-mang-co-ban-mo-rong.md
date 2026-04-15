# 📚 HỆ THỐNG KIẾN THỨC MẠNG — Phụ lục: CÁC KHÁI NIỆM CƠ BẢN MỞ RỘNG

> 🎯 **Mục tiêu:** Giải thích sâu hơn những khái niệm nền tảng hay bị bỏ qua — đọc sau Phần 1 để có hiểu biết vững chắc hơn trước khi học tiếp.

> ⬅️ **Trước đó:** [Phần 1 — Nền tảng IP, MAC, Subnet, Gateway, DHCP, DNS](./kien-thuc-mang-phan1.md)

---

## Chương A1: Bandwidth, Throughput & Latency — 3 khái niệm hay nhầm nhất

### A1.1 Tình huống thực tế

FPT bán cho nhà máy gói **100 Mbps**. Nhưng khi bạn download file từ server Hàn Quốc, tốc độ chỉ đạt **3 MB/s**. Tại sao?

Để hiểu, cần phân biệt 3 thứ hoàn toàn khác nhau:

### A1.2 Bandwidth (Băng thông) — Đường rộng bao nhiêu

```
Hình dung: Đường cao tốc rộng bao nhiêu làn xe

Bandwidth 100 Mbps = Đường cao tốc 100 làn
→ Lý thuyết, tối đa có thể truyền 100 triệu bit mỗi giây
→ Đây là CON SỐ MÀ FPT BÁN CHO BẠN

Quy đổi: 100 Mbps ÷ 8 = 12.5 MB/s
         (1 byte = 8 bit)
→ Tốc độ tối đa lý thuyết khi download = 12.5 MB/s
```

### A1.3 Throughput (Thông lượng thực tế) — Xe thực sự chạy được bao nhiêu

```
Đường cao tốc 100 làn nhưng:
  - Đang có xe tai nạn chặn 20 làn
  - Trời mưa to, tất cả chạy chậm lại
  - Có trạm thu phí làm chậm tốc độ

→ Throughput thực tế: chỉ 60 làn chạy ổn định

Trong mạng, Throughput thực tế thấp hơn Bandwidth vì:
  - Mất gói tin → TCP gửi lại → mất băng thông
  - Độ trễ cao → chờ ACK → chậm
  - Overhead giao thức (TCP header, IP header...)
  - Chất lượng đường truyền FPT lúc giờ cao điểm
  - Server Hàn Quốc bận → gửi chậm dù mạng FPT ổn
```

### A1.4 Latency (Độ trễ) — Mất bao lâu để gói tin đi từ A đến B

```
Hình dung: Bạn gọi điện cho người ở Hàn Quốc
  - Tiếng của bạn mất 0.1 giây để đến bên kia
  - Đây là LATENCY — không liên quan đến đường rộng hay hẹp

Trong mạng:
  ping 192.168.120.1 → time<1ms  ← gần, trong phòng
  ping 8.8.8.8       → time=13ms ← ra Internet Việt Nam
  ping server.co.kr  → time=60ms ← sang Hàn Quốc

Latency ảnh hưởng đến trải nghiệm:
  ✅ Download file lớn → Bandwidth quan trọng hơn
  ⚠️ Video call (Zoom) → Latency quan trọng hơn
     (latency cao → giọng bị delay → khó chịu khi hội thoại)
  ⚠️ Game online → Latency cực kỳ quan trọng
```

### A1.5 Giải thích tình huống ban đầu

```
Download từ server Hàn Quốc chỉ 3 MB/s dù có gói 100 Mbps:

Nguyên nhân có thể:
  1. Server Hàn Quốc giới hạn tốc độ download (thường gặp)
  2. Đường truyền Việt Nam → Hàn Quốc bị nghẽn (international link)
  3. Gói tin bị mất nhiều → TCP liên tục gửi lại → throughput giảm
  4. Server Hàn Quốc đang bận phục vụ nhiều người

→ Bandwidth 100 Mbps của FPT chỉ là đường trong nước
→ Ra quốc tế = đường khác, chất lượng khác hoàn toàn
```

**Bảng so sánh nhanh:**

| Khái niệm | Đơn vị thường dùng | Ảnh hưởng đến |
|:---|:---:|:---|
| **Bandwidth** | Mbps, Gbps | Tốc độ tối đa có thể đạt |
| **Throughput** | MB/s (thực tế) | Tốc độ bạn thực sự cảm nhận |
| **Latency** | ms (millisecond) | Độ mượt của video call, game, remote desktop |

---

## Chương A2: Unicast, Broadcast, Multicast — 3 cách gửi dữ liệu trong mạng

### A2.1 Unicast — Gửi riêng cho 1 người

```
Hình dung: Gửi email cho đúng 1 người

💻 Bạn → 🖨️ Máy in RICOH (.125.4)

Chỉ máy in nhận được gói tin.
PC đồng nghiệp, camera, Advantech → không nhận được.

Đây là cách giao tiếp phổ biến nhất trong mạng:
  - In tài liệu → Unicast
  - Xem camera → Unicast
  - Vào Google → Unicast
```

### A2.2 Broadcast — Gửi cho TẤT CẢ trong mạng

```
Hình dung: Loa phóng thanh phường — tất cả dân làng đều nghe

💻 Bạn → 📢 FF-FF-FF-FF-FF-FF (địa chỉ MAC broadcast)
→ Tất cả 34 thiết bị trong mạng đều nhận gói tin

Ứng dụng thực tế của Broadcast:
  1. ARP Request: "Ai có IP 192.168.125.4? Cho tôi MAC!"
     → Phát cho tất cả, máy in nghe thấy → trả lời

  2. DHCP Discover: Laptop mới cắm vào: "Có DHCP server nào không?"
     → Phát cho tất cả, Fortinet nghe thấy → cấp IP

  3. NetBIOS (cũ): Tìm tên máy tính trong Windows
     → Phát cho tất cả

Hạn chế của Broadcast:
  → Mọi thiết bị đều phải "đọc" gói broadcast (tốn CPU nhỏ)
  → Mạng có 34 thiết bị = OK
  → Mạng có 5000 thiết bị với nhiều broadcast = ẢNH HƯỞNG HIỆU SUẤT
  → Đây là lý do VLAN quan trọng: mỗi VLAN có broadcast domain riêng
```

### A2.3 Multicast — Gửi cho 1 nhóm chọn lọc

```
Hình dung: Gửi thông báo chỉ cho nhóm Zalo "Camera Team"
           (không phải tất cả, không phải chỉ 1 người)

Ví dụ thực tế:
  Camera Hikvision stream video → chỉ gửi cho NVR server (1 thiết bị)
  Nhưng nếu 3 màn hình cùng xem camera → Camera gửi 1 lần → 3 màn hình nhận
  → Tiết kiệm hơn gửi 3 gói Unicast riêng

Địa chỉ Multicast: 224.0.0.0 đến 239.255.255.255
  (bạn thấy trong arp -a: 224.0.0.22 = nhóm mDNS multicast)
```

**Bảng so sánh:**

| Loại | Địa chỉ đích | Ai nhận? | Ví dụ |
|:---|:---:|:---|:---|
| **Unicast** | IP cụ thể (`.125.4`) | 1 thiết bị | Print, Browse web |
| **Broadcast** | `255.255.255.255` hoặc `.127.255` | Tất cả trong mạng | ARP, DHCP |
| **Multicast** | `224.x.x.x` đến `239.x.x.x` | Nhóm đã đăng ký | Video stream, routing |

---

## Chương A3: Hub vs Switch — Tại sao Hub lỗi thời hoàn toàn

### A3.1 Hub là gì?

```
Hub = Thiết bị kết nối nhiều cáp — nhưng RẤT NGU

PC1 ──┐
PC2 ──┤── [HUB] ──┬── PC1
PC3 ──┘           ├── PC2 (nhận hết!)
Máy in ──         ├── PC3 (nhận hết!)
                  └── Máy in (nhận hết!)

Nguyên tắc Hub: Nhận gói tin từ 1 port → gửi ra TẤT CẢ port khác
```

### A3.2 Tại sao Hub gây ra "Collision" (Đụng độ)?

```
Tình huống: PC1 và PC2 cùng gửi dữ liệu lúc 10:00:00.000

PC1 gửi đến Máy in ──►─────────────►──┐
PC2 gửi đến PC3   ──►─────────────►──┤  VA CHẠM! 💥
                                       └── Cả 2 bị hỏng

→ Cả 2 phải chờ ngẫu nhiên rồi gửi lại
→ Mạng càng nhiều thiết bị → càng nhiều collision → CHẬM KINH KHỦNG

10 thiết bị dùng hub → có thể chỉ đạt 30% băng thông lý thuyết!
```

### A3.3 Switch giải quyết thế nào?

```
Switch = Thiết bị thông minh — mỗi cổng là một "làn đường riêng"

PC1 ──[Port 1]──┐
PC2 ──[Port 2]──┤
PC3 ──[Port 3]──┤ SWITCH ← biết MAC của từng thiết bị
Máy in─[Port 4]─┤
Camera─[Port 5]─┘

PC1 gửi đến Máy in:
  Switch đọc: "PC1 → Máy in (Port 4)" → Gửi thẳng Port 1 ↔ Port 4
  PC2, PC3, Camera: KHÔNG BỊ ẢNH HƯỞNG GÌ CẢ
  Lúc đó PC2 vẫn có thể gửi cho PC3 hoàn toàn song song!

→ Không có collision
→ Mỗi cổng switch = 1 Collision Domain riêng biệt
→ 34 thiết bị dùng switch = tất cả đều đạt tốc độ đầy đủ
```

### A3.4 Broadcast Domain — Khái niệm liên quan

```
Dù Switch thông minh, nó VẪN KHÔNG chặn Broadcast:
  ARP broadcast → Switch flood ra tất cả port (trừ port nhận)

Collision Domain:  Mỗi port switch = 1 domain riêng ✅
Broadcast Domain:  Cả mạng (tất cả port switch) = 1 domain chung

→ 34 thiết bị = 34 collision domain (tốt!)
→ 34 thiết bị = 1 broadcast domain (có thể ảnh hưởng nếu nhiều hơn)

Đây là lý do VLAN tách Broadcast Domain:
  VLAN 10 (PC văn phòng): broadcast domain riêng
  VLAN 20 (Camera):       broadcast domain riêng
  → Broadcast của VLAN 10 không sang VLAN 20 và ngược lại
```

---

## Chương A4: Địa chỉ IP Đặc biệt — Những số không phải "số nhà bình thường"

### A4.1 127.0.0.1 — Địa chỉ Loopback ("Gửi thư cho chính mình")

```
127.0.0.1 = "localhost" = địa chỉ của chính máy tính này

Không gửi ra mạng — quay vòng lại trong máy tính

Ứng dụng thực tế:
  PostgreSQL trên máy bạn lắng nghe 127.0.0.1:5432
  → Chỉ chương trình trên CHÍNH MÁY mới kết nối được
  → Máy khác trong mạng KHÔNG kết nối được
  → Đây là bảo mật tốt!

Kiểm tra nhanh:
  ping 127.0.0.1
  ✅ Reply luôn → Card mạng đang hoạt động bình thường
  ❌ Fail → Lỗi TCP/IP stack trên máy (hiếm gặp)

Toàn dải 127.0.0.0/8 đều là loopback (127.0.0.1 đến 127.255.255.254)
→ Thông dụng nhất: 127.0.0.1
```

### A4.2 169.254.x.x — APIPA (Khi DHCP Fail)

```
169.254.x.x = Địa chỉ tự cấp khi không tìm được DHCP server

Nguyên nhân thấy 169.254.x.x khi chạy ipconfig:
  1. Cáp mạng bị đứt → không kết nối đến switch → DHCP không phản hồi
  2. Fortinet DHCP server tắt hoặc pool IP đã hết
  3. VLAN cấu hình sai → máy không đến được Fortinet

Windows tự cấp IP trong dải 169.254.0.0/16:
  → Có thể nói chuyện với máy KHÁC cũng bị APIPA trong cùng mạng
  → KHÔNG thể ra Internet vì không có Gateway
  → KHÔNG thể vào bất kỳ dịch vụ nội bộ nào

Khi thấy 169.254.x.x → Làm ngay:
  ipconfig /release
  ipconfig /renew
  → Nếu vẫn 169.254.x.x → Kiểm tra cáp, switch, Fortinet DHCP
```

### A4.3 0.0.0.0 — Địa chỉ "Mọi nơi" / Default Route

```
0.0.0.0 có 2 nghĩa khác nhau tùy ngữ cảnh:

Nghĩa 1 — Trong Routing Table:
  "Default route": 0.0.0.0/0 = "Gửi tất cả những gì không biết gửi đâu ra đây"
  Fortinet routing table:
    192.168.120.0/21 → thẳng ra LAN
    0.0.0.0/0        → ra FPT Internet  ← Default route

Nghĩa 2 — Trong kết nối TCP (netstat):
  0.0.0.0:445 LISTENING
  → Port 445 đang lắng nghe trên TẤT CẢ địa chỉ IP của máy
  → Bất kỳ IP nào đến đây đều được chấp nhận

  So sánh:
  127.0.0.1:5432 LISTENING → Chỉ chấp nhận kết nối từ chính máy này
  0.0.0.0:445   LISTENING → Chấp nhận kết nối từ mọi IP (kể cả mạng nội bộ)
```

### A4.4 255.255.255.255 — Limited Broadcast

```
255.255.255.255 = Broadcast đặc biệt — gửi ra TẤT CẢ mà không cần biết mình ở mạng nào

Dùng khi:
  → Laptop mới cắm vào mạng, chưa có IP
  → Không biết DHCP server ở đâu
  → Gửi DHCP Discover đến 255.255.255.255 (tất cả)
  → Fortinet nhận → cấp IP

So sánh với Directed Broadcast:
  192.168.127.255 = Broadcast trong mạng 192.168.120.0/21 của nhà máy bạn
  (Gửi đến .127.255 = tất cả thiết bị trong "phường" đó)
```

---

## Chương A5: IP Classes & Private Ranges — Tại sao 192.168.x.x là "địa chỉ nhà"

### A5.1 Tại sao cùng 192.168.x.x, nhiều nhà máy khác nhau dùng mà không trùng?

```
Câu hỏi thực tế:
  Nhà bạn dùng WiFi: 192.168.1.100
  Nhà máy bạn:       192.168.125.100
  Phòng khách sạn:   192.168.0.150
  Hàng xóm:          192.168.1.50

Tất cả dùng 192.168.x.x — sao không "trùng nhau" và loạn cả Internet?

→ Vì 192.168.x.x là "địa chỉ NỘI BỘ" — chỉ có ý nghĩa bên trong mỗi mạng riêng
→ Giống như nhiều tòa nhà khác nhau đều có "Phòng 101" — không ai nhầm vì chúng trong tòa nhà khác nhau
→ NAT ẩn tất cả địa chỉ này khỏi Internet
```

### A5.2 IP Classes — Phân loại địa chỉ IP (lịch sử, nhưng hay gặp)

```
Ngày xưa (trước năm 1993), người ta chia IP thành các "class":

CLASS A: 1.0.0.0 — 126.255.255.255
  Số đầu: 1-126
  Dành cho: Tổ chức khổng lồ (quân đội, đại học lớn)
  Số host tối đa: ~16 triệu/mạng
  Ví dụ: 10.x.x.x (dải Class A private)

CLASS B: 128.0.0.0 — 191.255.255.255
  Số đầu: 128-191
  Dành cho: Doanh nghiệp lớn, trường đại học
  Số host tối đa: ~65,000/mạng
  Ví dụ: 172.16.x.x đến 172.31.x.x (dải Class B private)

CLASS C: 192.0.0.0 — 223.255.255.255
  Số đầu: 192-223
  Dành cho: Tổ chức nhỏ, văn phòng
  Số host tối đa: 254/mạng
  Ví dụ: 192.168.x.x (dải Class C private → nhà máy bạn)

CLASS D: 224.0.0.0 — 239.255.255.255
  Dành cho Multicast (không cấp cho host thông thường)

CLASS E: 240.0.0.0 — 255.255.255.255
  Dành cho nghiên cứu/dự phòng
```

### A5.3 3 Dải Private IP — RFC 1918

```
Theo tiêu chuẩn RFC 1918 (1996), có 3 dải IP được dành riêng cho mạng nội bộ:

┌─────────────────────┬───────────────────────┬───────────────┐
│  Dải Private        │  Subnet Mask mặc định │  Class gốc    │
├─────────────────────┼───────────────────────┼───────────────┤
│  10.0.0.0/8         │  255.0.0.0            │  A (lớn nhất) │
│  172.16.0.0/12      │  255.240.0.0          │  B (trung)    │
│  192.168.0.0/16     │  255.255.0.0          │  C (nhỏ nhất) │
└─────────────────────┴───────────────────────┴───────────────┘

Quy tắc:
  → Các dải này KHÔNG tồn tại trên Internet công cộng
  → Router Internet sẽ TỪ CHỐI định tuyến gói tin đến các dải này
  → Ai cũng có thể dùng mà không cần đăng ký

Nhà máy bạn:
  192.168.120.0/21 → nằm trong dải 192.168.0.0/16 (Class C private) ✅
  Bạn có thể dùng thoải mái, không trùng với ai trên Internet
```

### A5.4 Tại sao nhà máy dùng /21 thay vì /24 thông thường?

```
/24 (255.255.255.0) → tối đa 254 thiết bị
/21 (255.255.248.0) → tối đa 2046 thiết bị

Nhà máy có kế hoạch mở rộng:
  Hiện tại: 34 thiết bị
  Trong 5 năm: thêm camera, máy móc, WiFi client...
  → Chọn /21 để có "không gian" phát triển, không cần đổi toàn bộ cấu hình mạng sau này

Nguyên tắc: Chọn subnet mask sao cho số host tối đa > số thiết bị dự kiến × 2-3 lần
```

---

## Chương A6: MTU — Tại sao gói tin có giới hạn kích thước?

### A6.1 MTU là gì?

```
MTU (Maximum Transmission Unit) = Kích thước gói tin tối đa có thể gửi đi
                                   mà không cần cắt nhỏ

Ethernet MTU tiêu chuẩn: 1500 bytes

Tương tự: Bạn muốn gửi 1 cuốn sách 500 trang qua bưu điện
  → Bưu điện quy định: Mỗi gói tối đa 50 trang
  → Bạn cắt sách thành 10 gói, gửi 10 lần
  → Người nhận ghép lại theo số thứ tự
```

### A6.2 Gói tin lớn hơn MTU thì sao? — Fragmentation

```
Bạn muốn truyền file 10,000 bytes qua mạng Ethernet (MTU=1500):

┌──────────────────────────────────────────────────┐
│  File 10,000 bytes                               │
└──────────────────────────────────────────────────┘
                    ↓ Cắt nhỏ (Fragmentation)
┌─────────────┐ ┌─────────────┐ ┌─────────────┐ ┌──────┐
│ Gói 1:1500b │ │ Gói 2:1500b │ │ Gói 3:1500b │ │..... │
│ #1          │ │ #2          │ │ #3          │ │ #7   │
└─────────────┘ └─────────────┘ └─────────────┘ └──────┘
                    ↓ Gửi đi từng gói
                    ↓ Người nhận ghép lại theo số #
┌──────────────────────────────────────────────────┐
│  File 10,000 bytes — HOÀN CHỈNH                  │
└──────────────────────────────────────────────────┘
```

### A6.3 Tại sao Fragmentation gây vấn đề?

```
Fragmentation không lý tưởng vì:
  1. Nếu 1 mảnh mất → phải gửi lại toàn bộ file (TCP) hoặc bỏ (UDP)
  2. Router/Firewall tốn CPU để cắt và ghép
  3. Fortinet có thể chặn gói tin đã bị fragment vì bảo mật

Giải pháp hiện đại: Path MTU Discovery
  Máy tính tự động tìm MTU lớn nhất có thể đi qua tất cả thiết bị trên đường
  → Thường vẫn là 1500 bytes với Ethernet thông thường

Thực tế với VPN:
  VPN thêm header vào gói tin → gói tin từ 1500 → 1600 bytes
  → Lớn hơn MTU → phải fragment → chậm hơn
  → Đây là lý do VPN đôi khi cảm thấy chậm hơn kết nối thường
```

---

## Chương A7: Full Duplex vs Half Duplex — Ethernet nói chuyện thế nào

### A7.1 Half Duplex — Nói hoặc Nghe, không làm cả hai

```
Hình dung: Bộ đàm radio
  Bạn: "Anh ơi, máy in bị kẹt giấy. Over."
  (Nhả nút → nghe)
  Anh kia: "Oke tôi xuống liền. Over."

  → Chỉ 1 người nói được tại 1 thời điểm
  → Nếu cả 2 cùng nói: cả 2 đều không nghe được gì

Hub dùng Half Duplex:
  PC1 đang gửi → PC2 PHẢI CHỜ
  → Mạng "xếp hàng" gửi tuần tự
  → Collision xảy ra khi 2 máy gửi cùng lúc
```

### A7.2 Full Duplex — Nói và Nghe cùng lúc

```
Hình dung: Điện thoại bình thường
  Bạn có thể vừa nói vừa nghe cùng lúc
  → Không cần chờ, tự nhiên hơn

Switch dùng Full Duplex:
  PC1 đang gửi → PC2 vẫn có thể gửi cùng lúc bình thường
  → Không collision
  → Đạt được tốc độ tối đa trong cả 2 chiều đồng thời

Ví dụ:
  Full Duplex 100 Mbps = 100 Mbps gửi + 100 Mbps nhận CÙNG LÚC
  Half Duplex 100 Mbps = 100 Mbps, nhưng chỉ 1 chiều tại 1 thời điểm
```

### A7.3 Thiết bị hiện đại dùng gì?

```
Tất cả Switch hiện đại → Full Duplex tự động (Auto-negotiation)

Auto-negotiation: 2 thiết bị "thương lượng" tốc độ và duplex khi cắm dây:
  Switch: "Tôi có thể làm 1G Full Duplex"
  PC: "Tôi cũng làm được 1G Full Duplex"
  → Chốt: 1 Gbps Full Duplex ✅

Sự cố Duplex Mismatch (hay gặp với thiết bị cũ):
  PC: Full Duplex 100Mbps
  Switch cũ: Half Duplex 100Mbps
  → PC gửi lúc switch cũng đang gửi → Collision!
  → Mạng chập chờn, chậm bất thường dù đèn switch sáng xanh
  → Xử lý: Cấu hình cứng cùng duplex trên cả 2 thiết bị
```

---

## Chương A8: Encapsulation — Gói tin được đóng gói thế nào qua 5 tầng

### A8.1 Tại sao cần đóng gói?

Khi bạn gửi email, dữ liệu không đi dạng "thô". Nó được đóng gói nhiều lớp giống như bưu kiện có nhiều lớp đóng gói khác nhau, mỗi lớp mang thông tin cho 1 loại thiết bị khác nhau.

### A8.2 Quá trình đóng gói — Từ trên xuống dưới

```
Tình huống: Bạn gửi lệnh in đến máy in RICOH

TẦNG 7 — APPLICATION (Ứng dụng)
  Dữ liệu: [Lệnh in | Nội dung tài liệu]
  → "Tôi muốn in văn件 này ra RICOH"

TẦNG 4 — TRANSPORT (Vận chuyển — TCP)
  Thêm TCP header:
  [TCP Header: Port nguồn=54321, Port đích=9100, Seq#=1] [Lệnh in | Nội dung]
  → "Gửi ra port 9100 (RAW Printing), từ port 54321 của tôi"
  Đơn vị: SEGMENT

TẦNG 3 — NETWORK (Mạng — IP)
  Thêm IP header:
  [IP Header: Nguồn=192.168.125.100, Đích=192.168.125.4] [TCP Header] [Dữ liệu]
  → "Từ máy tôi gửi đến máy in"
  Đơn vị: PACKET

TẦNG 2 — DATA LINK (Liên kết — Ethernet)
  Thêm MAC header và FCS:
  [MAC Đích=58-38-79...] [MAC Nguồn=9C-69-D3...] [IP Packet] [FCS Checksum]
  → "Qua switch đến cổng của máy in"
  Đơn vị: FRAME

TẦNG 1 — PHYSICAL (Vật lý)
  Chuyển Frame thành tín hiệu điện trên cáp Cat6
  Đơn vị: BIT (0 và 1)
```

### A8.3 Quá trình mở gói — Máy in nhận và xử lý

```
Máy in RICOH nhận tín hiệu điện từ cáp:

TẦNG 1 → TẦNG 2: Đọc Frame
  [MAC Đích] → Tôi! (58-38-79) → Đọc tiếp
  [FCS] → Checksum đúng → Frame hợp lệ
  Bỏ MAC header và FCS → lấy IP Packet

TẦNG 2 → TẦNG 3: Đọc IP Packet
  [IP Đích] → 192.168.125.4 → Đúng là tôi!
  Bỏ IP header → lấy TCP Segment

TẦNG 3 → TẦNG 4: Đọc TCP Segment
  [Port đích] → 9100 → Chuyển cho dịch vụ Printing đang nghe port 9100
  Bỏ TCP header → lấy dữ liệu

TẦNG 4 → TẦNG 7: Xử lý dữ liệu
  Nhận lệnh in → bắt đầu in tài liệu 🖨️
```

**Hình dung bằng ẩn dụ bưu kiện:**

```
Nội dung thư → [Phong bì trong: Từ: 54321, Đến: 9100]
             → [Phong bì IP: Từ: .125.100, Đến: .125.4]
             → [Phong bì MAC: Từ: 9C-69-D3, Đến: 58-38-79]
             → [Sóng điện tử trên dây đồng]

Máy in nhận: Bóc từng lớp từ ngoài vào trong
→ Đến nội dung thực sự → In ra giấy
```

---

## Chương A9: ICMP chi tiết — Ping và Tracert thực sự làm gì

### A9.1 ICMP là gì?

```
ICMP (Internet Control Message Protocol) = Giao thức "thông báo lỗi và kiểm tra đường đi"

Không phải để truyền dữ liệu ứng dụng
Mà để: "Đường có thông không?" và "Có lỗi gì trên đường đi không?"

Thuộc Tầng 3 (cùng tầng với IP)
Không dùng Port (khác với TCP/UDP!)
```

### A9.2 Ping hoạt động thế nào?

```
Bạn chạy: ping 192.168.125.4

Bước 1: PC bạn gửi ICMP Echo Request:
  "Alo, 192.168.125.4 ơi! Bạn có nghe tôi không?"
  (Gói tin: Type=8, Code=0, Sequence=1, Data=32 bytes)

Bước 2: Máy in nhận, gửi lại ICMP Echo Reply:
  "Nghe! Tôi vẫn sống!"
  (Gói tin: Type=0, Code=0, Sequence=1, Data=32 bytes giống hệt)

Bước 3: PC bạn đo thời gian:
  Gửi lúc 10:00:00.000
  Nhận lúc 10:00:00.001
  → Round Trip Time (RTT) = 1ms = "time<1ms" trong kết quả ping

Gửi 4 gói (mặc định Windows), in kết quả:
  Reply from 192.168.125.4: bytes=32 time<1ms TTL=255
  Reply from 192.168.125.4: bytes=32 time<1ms TTL=255
  Reply from 192.168.125.4: bytes=32 time<1ms TTL=255
  Reply from 192.168.125.4: bytes=32 time<1ms TTL=255
```

### A9.3 TTL — Time To Live (Và cách tracert khai thác nó)

```
TTL = Số lần gói tin được phép đi qua Router trước khi bị hủy

Tại sao cần TTL?
  Không có TTL: Nếu có lỗi định tuyến → Gói tin có thể đi vòng vô tận
  Có TTL=64: Mỗi lần qua Router → TTL giảm 1
             TTL = 0? → Router hủy gói, gửi ICMP "Time Exceeded" về nguồn

TTL khởi đầu thông thường:
  Windows: 128
  Linux/Mac/Android: 64
  Router/Firewall: 255

Ví dụ:
  ping google.com → Reply TTL=119
  → Google khởi đầu TTL=128
  → 128 - 119 = 9 hop đi qua
```

### A9.4 Tracert khai thác TTL thế nào?

```
tracert google.com

Cách tracert hoạt động — "Tăng TTL từ 1 lên dần":

Lần 1: Gửi gói với TTL=1
  → Hop 1 (Fortinet) nhận → TTL=1-1=0 → Hủy → Gửi "Time Exceeded" về
  → PC biết: Hop 1 là 192.168.120.1, mất <1ms

Lần 2: Gửi gói với TTL=2
  → Hop 1 (Fortinet): TTL=2-1=1 → Tiếp tục chuyển tiếp
  → Hop 2 (Router FPT): TTL=1-1=0 → Hủy → Gửi "Time Exceeded" về
  → PC biết: Hop 2 là 113.22.0.37, mất 8ms

Lần 3: Gửi gói với TTL=3...(tiếp tục)

Kết quả hiển thị:
  1  <1ms  192.168.120.1    ← Fortinet (trong nhà máy)
  2  8ms   113.22.0.37      ← Router FPT gần nhất
  3  9ms   42.113.208.7     ← Backbone FPT
  ...
  6  13ms  142.250.4.160    ← Đến Google

→ Bạn "thấy" cả hành trình gói tin đi!
```

### A9.5 Tại sao đôi khi ping bị block mà mạng vẫn chạy?

```
Fortinet và nhiều firewall có thể CẤU HÌNH CHẶN ICMP:

Lý do chặn ping:
  Hacker thường dùng ping để "quét" xem thiết bị nào đang online
  → Chặn ICMP = ẩn thiết bị khỏi hacker

Hậu quả:
  ping 8.8.8.8 → Request timed out
  Nhưng vào Google vẫn bình thường!
  → Vì Google có thể chặn ICMP nhưng vẫn trả lời HTTP/HTTPS

Cách kiểm tra chính xác hơn khi ping bị chặn:
  Test-NetConnection -ComputerName 8.8.8.8 -Port 53
  → TcpTestSucceeded: True → kết nối được đến port 53 của Google DNS ✅
```

---

## Chương A10: Hostname & Computer Name — Tại sao không gõ tên máy được?

### A10.1 Tình huống

```
Đồng nghiệp bảo: "Vào \\MAYTINH-KT để lấy file"
Bạn gõ: \\MAYTINH-KT
→ Không thấy gì, báo lỗi "Network path not found"

Nhưng gõ: \\192.168.125.17
→ Mở được thư mục chia sẻ bình thường!
```

### A10.2 Hostname là gì?

```
Hostname = Tên máy tính được đặt trong Windows

Kiểm tra hostname của máy bạn:
  Settings → System → About → Device name
  Hoặc: hostname (lệnh PowerShell)

Hostname của từng máy trong nhà máy:
  192.168.125.100 → MAYTINH-VP01 (máy bạn)
  192.168.125.17  → MAYTINH-KT   (máy kế toán)
  192.168.125.37  → MAYTINH-HR   (máy nhân sự)
```

### A10.3 Tại sao hostname không hoạt động mà IP thì được?

```
Để dùng hostname thay IP, cần có 1 trong 2 thứ:

Cách 1 — DNS Server nội bộ (Active Directory):
  Có máy chủ DNS riêng trong mạng nội bộ
  Ghi nhớ: MAYTINH-KT = 192.168.125.17
  → Khi gõ \\MAYTINH-KT → DNS dịch → 192.168.125.17 → kết nối được

  Nhà máy bạn: KHÔNG có DNS nội bộ
  DNS đang dùng là 8.8.8.8 (Google) → Chỉ biết tên miền Internet
  → 8.8.8.8 KHÔNG biết "MAYTINH-KT" là gì → Fail!

Cách 2 — NetBIOS/mDNS (tự động, trong cùng mạng):
  Windows tự broadcast: "Tôi tên MAYTINH-KT, IP là .125.17"
  Các máy khác nghe và nhớ
  → Có thể dùng tên trong cùng subnet

  Vấn đề:
  → Chỉ hoạt động trong cùng broadcast domain
  → Không ổn định (đôi khi được, đôi khi không)
  → Có VLAN → broadcast khác domain → càng không hoạt động
```

### A10.4 Giải pháp thực tế

```
NGẮN HẠN (miễn phí, không cần install):
  Dùng file "hosts" của Windows:
    C:\Windows\System32\drivers\etc\hosts

  Thêm vào (cần quyền Admin):
    192.168.125.17  MAYTINH-KT
    192.168.125.4   mayinricoh
    192.168.125.6   camera1

  Sau đó:
    \\MAYTINH-KT   → hoạt động ✅
    ping mayinricoh → hoạt động ✅
    Chỉ sửa trên 1 máy, không ảnh hưởng máy khác

  Hạn chế: Phải sửa trên từng máy; nếu IP thay đổi phải sửa lại

DÀI HẠN (cần IT setup):
  → Triển khai Windows Active Directory Domain Controller
  → Có DNS server nội bộ riêng
  → Tất cả máy join Domain → Toàn bộ hostname được quản lý tập trung
  → \\MAYTINH-KT hoạt động cho tất cả máy trong domain
```

---

## Chương A11: Bảng tra cứu nhanh — Tổng hợp toàn bộ phụ lục

| Khái niệm | Giải thích 1 câu | Ví dụ thực tế |
|:---|:---|:---|
| **Bandwidth** | Đường rộng bao nhiêu (lý thuyết) | FPT bán 100 Mbps |
| **Throughput** | Xe chạy thực tế bao nhiêu | Download đạt 3 MB/s dù có 100 Mbps |
| **Latency** | Mất bao lâu từ A đến B | ping HQ = 60ms |
| **Unicast** | 1 → 1 | Gửi lệnh in đến RICOH |
| **Broadcast** | 1 → tất cả | ARP hỏi "Ai có IP .125.4?" |
| **Multicast** | 1 → nhóm chọn lọc | Camera stream cho NVR |
| **Hub** | Flood tất cả, gây collision | Lỗi thời từ lâu |
| **Switch** | Thông minh, từng port riêng | Thiết bị hiện đại dùng |
| **127.0.0.1** | Loopback — gửi cho chính mình | PostgreSQL chỉ nghe 127.0.0.1 |
| **169.254.x.x** | APIPA — DHCP fail | Thấy → Kiểm tra cáp ngay |
| **0.0.0.0/0** | Default route — mọi nơi còn lại | Fortinet gửi ra FPT |
| **MTU 1500** | Giới hạn kích thước gói tin | File lớn → cắt thành nhiều gói |
| **Full Duplex** | Nghe và nói cùng lúc | Switch hiện đại |
| **Half Duplex** | Nghe hoặc nói, không cả hai | Hub (cổ điển) |
| **Encapsulation** | Đóng gói qua nhiều lớp | Data→Segment→Packet→Frame→Bit |
| **ICMP** | Giao thức kiểm tra đường đi | ping, tracert |
| **TTL** | Số hop tối đa gói tin đi được | tracert khai thác TTL để tìm đường |
| **Hostname** | Tên máy tính trong Windows | MAYTINH-KT |
| **Hosts file** | "Danh bạ" thủ công trên từng máy | Map hostname → IP không cần DNS |

---

## Tự kiểm tra — 3 câu

> **Câu 1:** Bạn download file từ server Hàn Quốc, tốc độ chỉ 2 MB/s dù FPT bán gói 100 Mbps. Bạn ping google.com được 15ms. Vấn đề có thể ở đâu? Bạn sẽ kiểm tra thêm thứ gì?
> → Bandwidth 100 Mbps chỉ là đường nội địa. Đường quốc tế Việt Nam–Hàn Quốc là hạ tầng khác, có thể đang nghẽn. Kiểm tra thêm: `tracert server.co.kr` → xem hop nào có latency cao bất thường → nếu hop đầu tiên ra quốc tế (~hop 3-5) đã chậm → nghẽn ở đường truyền quốc tế, không phải lỗi của nhà máy.

> **Câu 2:** Buổi sáng bạn chạy `ipconfig`, thấy IP là `169.254.45.23`. Bạn cần làm gì theo thứ tự?
> → (1) Chạy `ipconfig /release` → `ipconfig /renew`. Nếu vẫn 169.254: (2) Kiểm tra đèn adapter ASIX — có sáng không? (3) Thử cắm lại cáp hoặc đổi cổng switch. (4) Ping `192.168.120.1` — nếu fail → vấn đề vật lý hoặc DHCP của Fortinet. (5) Hỏi đồng nghiệp xem họ có bị không — nếu có → Fortinet/switch chung bị lỗi.

> **Câu 3:** Đồng nghiệp bảo "Gõ `\\MAYTINH-SX` vào File Explorer để vào thư mục chia sẻ xưởng". Bạn gõ nhưng không được. Cách kiểm tra và giải quyết nhanh nhất là gì?
> → (1) Ping `MAYTINH-SX` — nếu fail → hostname resolution không hoạt động. (2) Hỏi đồng nghiệp IP thực của máy đó (chạy `ipconfig`). (3) Thử `\\192.168.125.9` trực tiếp bằng IP — nếu được → vấn đề là hostname. (4) Giải pháp nhanh: Thêm vào `C:\Windows\System32\drivers\etc\hosts` dòng `192.168.125.9  MAYTINH-SX` (mở bằng Notepad quyền Admin).

---

> 📖 **Quay lại series chính:**
> - [Phần 1 — Nền tảng](./kien-thuc-mang-phan1.md)
> - [Phần 2 — Thiết bị mạng](./kien-thuc-mang-phan2.md)
> - [Phần 3 — Port, Giao thức & Bảo mật](./kien-thuc-mang-phan3.md)
> - [Phần 4 — Chẩn đoán sự cố](./kien-thuc-mang-phan4.md)
> - [Phần 5 — Bảo mật nâng cao](./kien-thuc-mang-phan5.md)
