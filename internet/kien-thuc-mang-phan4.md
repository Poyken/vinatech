# 📚 HỆ THỐNG KIẾN THỨC MẠNG — Phần 4: CHẨN ĐOÁN & XỬ LÝ SỰ CỐ THỰC TẾ

> 🎯 **Mục tiêu:** Biết cách xử lý các sự cố mạng thực tế hay xảy ra tại nhà máy — từ "mất mạng" đến "máy không in được" đến "Internet chậm".

> ⬅️ **Trước đó:** [Phần 3 — Port, TCP/UDP, VLAN, Bảo mật, Lệnh chẩn đoán](./kien-thuc-mang-phan3.md)

---

## Chương 26: Framework xử lý sự cố — Tư duy đúng trước khi làm gì

### 26.1 Sai lầm phổ biến nhất

Hầu hết mọi người khi gặp sự cố mạng:
1. Restart máy ngay (đôi khi may mắn fix được, không hiểu tại sao)
2. Thử cách này, thử cách kia ngẫu nhiên
3. Gọi IT sau nửa giờ loay hoay

**Cách đúng:** Chẩn đoán có hệ thống từ **tầng thấp lên cao** (theo mô hình OSI).

### 26.2 Quy trình 5 bước chuẩn

```
Bước 1: XÁC ĐỊNH RÕ VẤN ĐỀ
  ❓ "Mất mạng hoàn toàn" hay "Chỉ một website không vào được"?
  ❓ "Mọi người đều bị" hay "Chỉ mình tôi"?
  ❓ "Mới xảy ra" hay "Bị từ lúc nào"?
  ❓ "Trước đây có hoạt động không"?

Bước 2: THU HẸP PHẠM VI
  Nếu chỉ mình bị → Lỗi trên máy bạn hoặc cổng switch của bạn
  Nếu cả phòng bị → Lỗi switch phòng hoặc uplink lên Fortinet
  Nếu cả nhà máy bị → Lỗi Fortinet hoặc FPT đường truyền

Bước 3: KIỂM TRA TỪ TẦNG THẤP LÊN
  Tầng 1 (Vật lý) → Tầng 3 (IP) → Tầng 7 (Ứng dụng)

Bước 4: CÔ LẬP VẤN ĐỀ
  Tìm chính xác điểm nào bị lỗi

Bước 5: SỬA & XÁC NHẬN
  Sửa → Test lại → Ghi chú lại nguyên nhân và cách sửa
```

---

## Chương 27: Sự cố 1 — "Máy tôi không vào được Internet"

### 27.1 Tình huống

Buổi sáng bạn đến công ty, mở máy, khởi động Brave, gõ google.com — **trang không load**.

### 27.2 Quy trình xử lý từng bước

**Bước 1: Xác định phạm vi**
```powershell
# Hỏi đồng nghiệp: "Bạn vào mạng được không?"
# Giả sử: "Tôi bình thường" → Chỉ máy bạn bị
```

**Bước 2: Kiểm tra vật lý (Tầng 1)**
```
Nhìn đèn trên adapter ASIX:
  ✅ Đèn xanh sáng → dây, kết nối vật lý OK
  ❌ Đèn không sáng → thử đổi cổng switch, thử cáp khác
```

**Bước 3: Kiểm tra IP (Tầng 3)**
```powershell
ipconfig

# Nếu thấy:
IP: 192.168.125.100  → Có IP bình thường, tiếp tục bước 4
IP: 169.254.x.x      → DHCP FAIL! Máy tự cấp IP "ảo" → xem bước 3a
IP: (trống)          → Không có IP → xem bước 3a
```

**Bước 3a: Xin IP mới (nếu DHCP fail)**
```powershell
ipconfig /release
ipconfig /renew

# Nếu vẫn fail → Kiểm tra:
#   Cáp mạng có bị đứt không?
#   Fortinet DHCP server có đang chạy không? (hỏi IT)
#   MAC bạn có bị blacklist trên DHCP không?
```

**Bước 4: Ping từng điểm**
```powershell
# Test 1: Ping Gateway
ping 192.168.120.1
```
```
✅ Reply → Gateway OK → tiếp tục
❌ Timeout → Lỗi giữa bạn và Fortinet
   → Kiểm tra: cáp từ máy đến switch, switch có nguồn điện không
   → Thử: ipconfig /release → /renew → ping lại
```
```powershell
# Test 2: Ping Internet (bỏ qua DNS)
ping 8.8.8.8
```
```
✅ Reply → Đường ra Internet OK, lỗi ở DNS → bước 5
❌ Timeout → Fortinet không ra Internet được
   → Kiểm tra với đồng nghiệp: họ ping được 8.8.8.8 không?
   → Nếu cả nhà máy fail → Gọi FPT báo sự cố đường truyền
```
```powershell
# Test 3: Ping Google qua tên miền
ping google.com
```
```
✅ Reply → DNS cũng OK → vấn đề ở ứng dụng (Brave/cache)
❌ Timeout (nhưng 8.8.8.8 OK) → Lỗi DNS → sang bước 5
```

**Bước 5: Xử lý DNS nếu bị lỗi**
```powershell
ipconfig /flushdns   # Xóa cache DNS cũ

nslookup google.com  # Test DNS trực tiếp
# Nếu fail → DNS server 8.8.8.8 không trả lời
# → Thử đổi DNS tạm: netsh interface ip set dns "Ethernet 2" static 1.1.1.1
```

**Bước 6: Nếu vẫn không vào web dù ping OK**
```
# Vấn đề có thể ở tầng ứng dụng:
- Thử trình duyệt khác (Edge thay vì Brave)
- Tắt VPN hoặc proxy nếu đang dùng
- Xóa cache trình duyệt: Ctrl+Shift+Delete
- Kiểm tra ngày giờ máy đúng không (lệch giờ → HTTPS lỗi SSL)
```

**Tóm tắt quyết định:**
```
Không vào web
  ↓ ping 192.168.120.1
  Fail → Lỗi dây/switch nội bộ
  OK
  ↓ ping 8.8.8.8
  Fail → Fortinet hoặc FPT đứt
  OK
  ↓ ping google.com
  Fail → Lỗi DNS → flushdns → đổi DNS
  OK
  ↓ Kiểm tra trình duyệt, proxy, VPN, giờ máy
```

---

## Chương 28: Sự cố 2 — "Máy tôi không in được ra RICOH"

### 28.1 Tình huống

Bạn nhấn Ctrl+P, chọn máy in RICOH, nhấn Print — máy không in, báo lỗi "Không kết nối được máy in."

### 28.2 Quy trình xử lý

**Bước 1: Xác định phạm vi**
```
Hỏi đồng nghiệp: "Bạn in được không?"
✅ Đồng nghiệp in được → Lỗi trên máy bạn
❌ Không ai in được    → Lỗi máy in hoặc kết nối của máy in
```

**Bước 2: Kiểm tra máy in còn online không**
```powershell
ping 192.168.125.4

✅ Reply → Máy in đang bật, kết nối mạng OK
❌ Timeout → Máy in tắt, bị đứt mạng, hoặc IP thay đổi
```

**Nếu ping fail:**
```
Đến gần máy in kiểm tra:
  1. Màn hình máy in có sáng không?
  2. Đèn mạng trên máy in có nhấp nháy không?
  3. Dây mạng có cắm chặt không?

Tìm IP thực tế của máy in:
  arp -a → Có thấy 58-38-79-xx không?
  Hoặc: In trang cấu hình trực tiếp từ máy in (thường giữ nút OK)
  → IP thay đổi (DHCP cấp lại) → Cập nhật port máy in trong Windows
```

**Bước 3: Kiểm tra kết nối port máy in**
```powershell
# Máy in RICOH thường dùng port 9100 (RAW printing)
Test-NetConnection -ComputerName 192.168.125.4 -Port 9100

# Nếu TcpTestSucceeded: True → Kết nối OK, lỗi ở driver/cài đặt
# Nếu TcpTestSucceeded: False → Port bị chặn hoặc máy in có vấn đề
```

**Bước 4: Kiểm tra printer driver và port Windows**
```
Control Panel → Devices and Printers → Chuột phải RICOH → Printer properties
  → Ports tab → Xem port có đúng IP 192.168.125.4 không
  → Nếu sai IP → sửa lại
  → Nếu đúng → thử Remove device → Add printer lại
```

**Bước 5: Thử ping xem máy in hoạt động ổn không**
```powershell
ping -t 192.168.125.4
# Nếu thấy timeout lẻ tẻ → mạng không ổn định → kiểm tra cáp mạng máy in
# Nếu ổn định → Reload driver hoặc restart spooler:
net stop spooler
net start spooler
```

---

## Chương 29: Sự cố 3 — "Mạng chậm bất thường"

### 29.1 Tình huống

Bình thường tải file từ server nhanh. Hôm nay cực kỳ chậm, tải 10MB mất cả phút.

### 29.2 Quy trình xử lý

**Bước 1: Đo tốc độ thực tế**
```powershell
# Ping với nhiều lần để xem độ trễ
ping -n 20 192.168.120.1

# Kết quả bình thường (nội bộ):
# time<1ms mọi lần → mạng nội bộ tốt

# Kết quả có vấn đề:
# time=200ms → chậm bất thường
# Request timed out × 3 → mất gói (packet loss) → mạng không ổn định
```

**Bước 2: Kiểm tra tốc độ Internet**
```powershell
# Tracert xem nghẽn ở hop nào
tracert -d 8.8.8.8

# Nếu:
# Hop 1 (<1ms) ✅, Hop 2 (200ms) ⚠️ → Nghẽn ở FPT ngay bên ngoài Fortinet
# Hop 1 (200ms) ⚠️ → Nghẽn ngay trong nội bộ (switch hoặc Fortinet tải cao)
```

**Bước 3: Xem ai đang dùng băng thông**
```powershell
# Xem các kết nối đang hoạt động
netstat -an | findstr ESTABLISHED

# Nếu thấy nhiều kết nối đến cùng 1 IP lạ → Có thể có phần mềm đang upload/download
# Xem task manager → Performance → Open Resource Monitor → Network
# → Tab Network hiển thị chương trình nào đang dùng mạng nhiều nhất
```

**Bước 4: Kiểm tra lỗi adapter mạng**
```powershell
# Xem thống kê của adapter
netsh interface show interface

# Ý nghĩa:
# Operational State: Connected ← OK
# Admin State: Enabled ← OK

# Kiểm tra lỗi frame:
netsh interface ipv4 show interfaces
# Cột "Errors": số lớn → cáp mạng bị lỗi hoặc switch có vấn đề
```

**Bước 5: Các nguyên nhân phổ biến và cách xử lý**

| Nguyên nhân | Dấu hiệu | Xử lý |
|:---|:---|:---|
| **FPT đường truyền bị lỗi** | Ping 8.8.8.8 chậm, tracert nghẽn hop 2 | Gọi FPT báo sự cố |
| **Fortinet tải cao** | Ping gateway >10ms, cả nhà máy chậm | Kiểm tra Fortinet dashboard |
| **Switch có port lỗi** | Một số PC chậm, số khác bình thường | Thử đổi cổng switch |
| **Cáp mạng hỏng** | Ping chập chờn, nhiều timeout | Thay cáp mới |
| **Virus/malware băng thông** | CPU/network cao bất thường | Quét Defender đầy đủ |
| **Phần mềm update ngầm** | Chậm tạm thời, sau hết bình thường | Chờ hoặc tạm dừng update |

---

## Chương 30: Sự cố 4 — "Không xem được camera Hikvision"

### 30.1 Tình huống

Bạn mở phần mềm Hikvision iVMS-4200, camera không hiển thị hình, báo "Network timeout".

### 30.2 Quy trình xử lý

**Bước 1: Camera còn online không?**
```powershell
ping 192.168.125.6    # Camera 1
ping 192.168.125.77   # Camera 2

✅ → Camera kết nối mạng OK, lỗi ở phần mềm hoặc stream
❌ → Camera mất kết nối hoặc tắt nguồn
```

**Nếu camera mất kết nối:**
```
Đến vị trí camera kiểm tra:
  - Đèn trên camera còn sáng không?
  - Nếu dùng PoE: Switch PoE có nguồn điện không?
  - Nếu không PoE: Nguồn điện camera còn không?
  - Cáp mạng từ camera đến switch có bị đứt không?
```

**Bước 2: Truy cập web interface của camera**
```
Mở trình duyệt → gõ: http://192.168.125.6
  → Nếu hiện trang login Hikvision → Camera OK, lỗi ở phần mềm iVMS
  → Nếu không mở được → Xem lại bước 1
```

**Bước 3: Kiểm tra port camera**
```powershell
# Hikvision thường dùng port 8000 (RTSP) và 80 (HTTP)
Test-NetConnection -ComputerName 192.168.125.6 -Port 80
Test-NetConnection -ComputerName 192.168.125.6 -Port 8000
```

**Bước 4: Kiểm tra cài đặt trong iVMS-4200**
```
Vào Device Management → Chọn camera → Edit
  → Kiểm tra IP đúng không? (có thể camera bị DHCP đổi IP)
  → Kiểm tra username/password
  → Port có đúng không?
```

---

## Chương 31: Công cụ nâng cao — Wireshark & Nmap

### 31.1 Wireshark — "Kính hiển vi mạng"

**Wireshark** là phần mềm miễn phí cho phép bạn **xem từng gói tin** đi qua card mạng — giống như đứng cạnh đường và đọc nội dung từng chiếc xe chạy qua.

**Khi nào dùng:**
- Nghi ngờ có phần mềm lạ đang gửi dữ liệu ra ngoài
- Debug kết nối ứng dụng không hoạt động đúng
- Học để thực sự hiểu mạng hoạt động thế nào

**Cách cài và dùng cơ bản:**
```
1. Tải: https://www.wireshark.org/download.html
2. Mở Wireshark → Chọn "Ethernet 2" (adapter ASIX của bạn)
3. Nhấn nút Start (hình cá mập)
4. Bạn sẽ thấy hàng trăm gói tin/giây

Filter hữu ích:
  ip.addr == 192.168.120.1       # Chỉ xem gói đến/từ Gateway
  dns                             # Chỉ xem query DNS
  tcp.port == 443                 # Chỉ xem HTTPS
  arp                             # Chỉ xem ARP broadcast
  ip.addr == 8.8.8.8 and dns      # DNS query đến Google
```

**Ví dụ — Bắt gói tin khi gõ google.com:**
```
Bạn gõ google.com, Wireshark sẽ thấy:
  1. DNS query: "google.com = ?" → 8.8.8.8
  2. DNS reply: "= 142.250.197.46"
  3. TCP SYN: 125.100 → 142.250.197.46:443
  4. TCP SYN-ACK: 142.250.197.46 → 125.100
  5. TCP ACK + TLS ClientHello: bắt đầu mã hóa
  6. ... (sau đó mã hóa, không đọc được nội dung)
```

**Phát hiện thiết bị lạ gửi dữ liệu:**
```
Filter: not (ip.addr == 192.168.120.1) and not (ip.addr == 8.8.8.8)
→ Xem còn gói tin nào đến IP lạ không
→ Nếu có → tra IP đó → phần mềm gì đang gửi?
```

### 31.2 Nmap — "Máy quét X-quang mạng"

**Nmap** quét mạng để phát hiện **thiết bị nào đang online** và **port nào đang mở** trên chúng.

> ⚠️ **Quan trọng:** Chỉ dùng Nmap trên mạng bạn có quyền quản lý. Quét mạng người khác là vi phạm pháp luật.

**Cài đặt:**
```
Tải: https://nmap.org/download.html
Cài đặt kèm Zenmap (giao diện đồ họa) → dễ dùng hơn
```

**Các lệnh hay dùng:**

```powershell
# Quét xem thiết bị nào đang online trong subnet
nmap -sn 192.168.120.0/21
# Kết quả: danh sách IP đang phản hồi ping
# → Thấy ~34 thiết bị trong nhà máy bạn

# Quét port của 1 thiết bị cụ thể
nmap -sV 192.168.125.4
# Kết quả:
# PORT     STATE  SERVICE    VERSION
# 80/tcp   open   http       Ricoh Web Server
# 9100/tcp open   jetdirect  Ricoh printing
# 443/tcp  open   https      Ricoh Web Server

# Quét nhanh top 100 port phổ biến
nmap --top-ports 100 192.168.125.100
# → Thấy port nào đang mở trên máy bạn

# Quét phát hiện OS
nmap -O 192.168.125.100
# → Đoán hệ điều hành: Windows 10 (x86-64)
```

**Phát hiện thiết bị mới trong mạng:**
```powershell
# Chạy lệnh này định kỳ, lưu kết quả
nmap -sn 192.168.120.0/21 -oN "scan_$(Get-Date -Format 'yyyyMMdd').txt"
# ⚠️ Ghi chú: Lệnh trên chạy trong PowerShell (Windows).
#              Nếu dùng CMD thay vì PowerShell, tên file tự đặt thủ công:
#              nmap -sn 192.168.120.0/21 -oN scan_20260408.txt

# So sánh 2 lần quét → thấy IP mới → thiết bị lạ kết nối
# Tra OUI của MAC → biết nhà sản xuất → xác định thiết bị
```

---

## Chương 32: Sổ tay xử lý sự cố — Cheat Sheet

### 32.1 Kịch bản và lệnh tương ứng

```
🔴 MẤT MẠNG HOÀN TOÀN:
   ipconfig → Có IP không?
   ping 192.168.120.1 → Fortinet còn sống không?
   ping 8.8.8.8 → Vào Internet được không?

🟡 MẤT WEB NHƯNG MẠNG THÔNG:
   ping 8.8.8.8 → OK
   ping google.com → Fail → DNS lỗi
   ipconfig /flushdns → thử lại
   nslookup google.com → test DNS

🟡 MẠNG CHẬM:
   ping -n 20 192.168.120.1 → Xem latency + packet loss
   tracert -d 8.8.8.8 → Tìm hop nào chậm
   Resource Monitor → Network tab → Xem ai dùng nhiều

🔵 KHÔNG IN ĐƯỢC:
   ping 192.168.125.4 → Máy in còn online?
   Test-NetConnection -ComputerName 192.168.125.4 -Port 9100
   Kiểm tra driver, IP trong Printer Properties

🔵 KHÔNG XEM ĐƯỢC CAMERA:
   ping 192.168.125.6 → Camera còn online?
   http://192.168.125.6 → Truy cập web interface
   Kiểm tra IP + port trong phần mềm quản lý camera

🔵 THIẾT BỊ MỚI KHÔNG VÀO ĐƯỢC MẠNG:
   ipconfig → 169.254.x.x = DHCP fail
   Kiểm tra Fortinet DHCP pool có đủ IP không
   Kiểm tra MAC có bị block không
```

### 32.2 Thông số chuẩn của mạng nhà máy bạn

```
Ghi nhớ để kiểm tra nhanh:

Gateway:   192.168.120.1  (Fortinet FortiGate)
DNS:       8.8.8.8        (Google Public DNS)
Subnet:    255.255.248.0  (/21)
Phường:    192.168.120.0
Host từ:   192.168.120.1 đến 192.168.127.254

Thiết bị cố định:
  Fortinet:  192.168.120.1  (MAC: 48-3A-02-xx)
  Máy in:    192.168.125.4  (MAC: 58-38-79-xx)
  Camera 1:  192.168.125.6  (MAC: E0-CA-3C-xx)
  Camera 2:  192.168.125.77 (MAC: E0-CA-3C-xx)
  Advantech: 192.168.125.9  (MAC: CC-82-7F-xx)
  Bạn:       192.168.125.100 (MAC: 9C-69-D3-69-A1-96)
```

---

## Chương 33: Tự kiểm tra Phần 4

> **Câu 1:** Máy bạn có IP `169.254.x.x`. Điều đó có nghĩa gì và xử lý thế nào?
> → IP `169.254.x.x` là APIPA — máy tự cấp khi không nhận được IP từ DHCP. Xử lý: `ipconfig /release` → `ipconfig /renew`. Nếu vẫn fail → kiểm tra dây mạng và kết nối đến Fortinet.

> **Câu 2:** Đồng nghiệp in được nhưng bạn không in được. Tracert đến `192.168.125.4` thành công. Port 9100 test OK. Vấn đề ở đâu?
> → Vấn đề ở tầng ứng dụng (driver, cấu hình printer trong Windows). Kiểm tra IP trong Printer Properties, thử xóa và thêm lại printer.

> **Câu 3:** Tracert đến Google cho thấy hop 1 `<1ms`, hop 2 `300ms`. Vấn đề ở đâu?
> → Nghẽn ngay đoạn từ Fortinet đến router FPT đầu tiên. Thuộc phạm vi của FPT → gọi báo sự cố đường truyền.

---

> 📖 **Tiếp theo → [Phần 5: Bảo mật nâng cao & Quản lý mạng nhà máy](./kien-thuc-mang-phan5.md)**
