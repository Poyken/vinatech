# CHI TIẾT PHASE 1: KHO NGUYÊN VẬT LIỆU NHẬP HÀNG

> Mô tả từng bước: Làm gì → Ai làm → Làm như thế nào → Làm để làm gì

---

## BƯỚC 0: CẤU HÌNH NHÀ CUNG CẤP VÀ NVL (làm 1 lần)

### F130 – Chỉ định vật liệu theo nhà cung cấp

| | Chi tiết |
|---|---|
| **Làm gì?** | Chọn 1 nhà cung cấp (NCC), rồi đánh dấu những nguyên vật liệu nào mà NCC đó cung cấp |
| **Ai làm?** | Nhân viên kho nguyên vật liệu |
| **Làm khi nào?** | Khi có nhà cung cấp mới, hoặc NCC cung cấp thêm vật liệu mới |
| **Mục đích?** | Để hệ thống biết NCC nào cung cấp NVL nào → khi nhập hàng hệ thống tự liên kết |

**Cách làm:**
1. Mở màn hình **F130** → ấn biểu tượng **tick xanh** (nút tìm kiếm) → dữ liệu hiện ra
2. **Bảng bên trái**: Danh sách nhà cung cấp → chọn NCC cần thiết lập
3. **Bảng bên phải**: Danh sách tất cả NVL → tick ô **"Sử dụng"** cho những NVL mà NCC này cung cấp
4. Ấn **Save** (lưu) để hệ thống ghi nhận

### F140 – Chỉ định nhà cung cấp theo vật liệu

| | Chi tiết |
|---|---|
| **Làm gì?** | Chọn 1 loại NVL, rồi đánh dấu những NCC nào cung cấp được NVL đó |
| **Ai làm?** | Nhân viên kho nguyên vật liệu |
| **Làm khi nào?** | Khi thêm NVL mới vào hệ thống, cần gán NCC cho nó |
| **Mục đích?** | Giống F130 nhưng nhìn từ góc ngược lại (NVL → NCC thay vì NCC → NVL) |

**Cách làm:**
1. Mở **F140** → tìm kiếm
2. **Bảng trái**: Chọn mã nguyên liệu
3. **Bảng phải**: Tick **"Sử dụng"** cho NCC cung cấp NVL này
4. Ấn **Save**

> 💡 **F130 và F140 là 2 cách nhìn khác nhau của cùng 1 việc.** Dùng F130 khi muốn gán nhiều NVL cho 1 NCC. Dùng F140 khi muốn gán nhiều NCC cho 1 NVL.

---

## BƯỚC 1: GHI NHẬN NVL ĐẦU VÀO – F312

### F312 – Viết ghi chú nguyên vật liệu đầu vào

| | Chi tiết |
|---|---|
| **Làm gì?** | Ghi lại thông tin lô hàng NVL mới nhập về (số hóa đơn invoice, mã NVL, số lượng) |
| **Ai làm?** | Nhân viên kho nguyên vật liệu |
| **Làm khi nào?** | Mỗi khi có NVL mới được giao đến kho |
| **Mục đích?** | Tạo "phiếu nhập" trên hệ thống để theo dõi NVL từ lúc nhận hàng |

**Cách làm:**
1. Mở **F312** → ấn **tìm kiếm**
2. Ấn dấu **(+)** (thêm mới) → 1 dòng mới xuất hiện (bôi đỏ)
3. Điền các cột có **tiêu đề màu đậm** (bắt buộc phải điền):
   - Thông tin giao dịch (mã NCC, số invoice xuất nhập khẩu...)
4. Xong phần trên → ấn **(+)** ở **bảng bên dưới** để thêm chi tiết NVL:
   - Cột **"Mã nguyên liệu"** tự hiện theo thông tin bên trên
   - Các ô **màu xanh đậm** bắt buộc nhập
5. Nhập **RequestQty** (số lượng yêu cầu) = số lượng NVL thực tế được giao
6. Ấn **Save** (lưu)

> 💡 **Bước này giống như viết phiếu nhận hàng.** Chưa nhập kho chính thức, chỉ ghi nhận "hàng đã đến".

---

## BƯỚC 2: NHẬP KHO VÀ TẠO TEM – F330

### F330 – Nhập kho và in tem nguyên vật liệu

| | Chi tiết |
|---|---|
| **Làm gì?** | Xác nhận NVL nhập kho chính thức, tách thành từng tem (mỗi tem = 1 lot nhỏ), gán mã lot |
| **Ai làm?** | Nhân viên kho nguyên vật liệu |
| **Làm khi nào?** | Sau khi đã ghi chú NVL ở F312 |
| **Mục đích?** | Để NVL có tem mã vạch (barcode), có mã lot → mới xuất ra sản xuất được |

**Cách làm - Phần 1: Xác nhận hàng nhập về**
1. Mở **F330** → tìm đến phiếu đã tạo ở F312
2. Nhìn cột **DocStatusName** (trạng thái tài liệu):
   - Ban đầu = **"Create"** (mới tạo)
3. Chọn phiếu đó → ấn **"Xử lý hàng nhập về"**
4. Trạng thái đổi thành **"ARRIVAL"** (đã tiếp nhận) → lúc này mới tạo được tem

**Cách làm - Phần 2: Tách tem**
1. Điền **PackingQty** (số lượng đóng gói) = số lượng NVL trên **1 tem**
   - Ví dụ: nhập 1000 cái, muốn chia 10 tem → mỗi tem 100 cái → PackingQty = 100
2. **Số tem** = ReceiveQty (số lượng nhận) ÷ PackingQty (số lượng mỗi tem)
3. Ấn **"Tạo tem"** → tem hiện trong danh sách
4. **ScanQty** (số lượng đã tạo tem): nếu còn ít hơn tổng → tạo thêm được; bằng rồi → hết

**Cách làm - Phần 3: Gán Số Lot No → Đặc tính 10**
1. Cho mỗi tem → điền **"Số lot no"** (số lô)
2. Hệ thống tự sinh ra **"Đặc tính 10"** (thuộc tính đặc biệt)

> ⚠️ **ĐÂY LÀ BƯỚC QUAN TRỌNG NHẤT CỦA KHO NVL:**
> - **Có Đặc tính 10** → NVL xuất ra sản xuất bình thường ✅
> - **Không có Đặc tính 10** → NVL vào **kho holding** (kho tạm giữ) → **không xuất cho sản xuất được** ❌
> - Nếu điền Số lot no mà **không ra Đặc tính 10** → liên hệ **EA team** để xử lý

---

## BƯỚC 2.5: QC KIỂM TRA NVL ĐẦU VÀO – C220

### C220 – Kiểm tra nguyên vật liệu đầu vào (IQC)

| | Chi tiết |
|---|---|
| **Làm gì?** | QC kiểm tra chất lượng NVL mới nhập kho (đo đạc, so sánh với tiêu chuẩn) |
| **Ai làm?** | Nhân viên QC (nhóm IQC - Incoming Quality Control: kiểm tra chất lượng đầu vào) |
| **Làm khi nào?** | Sau khi kho nhập NVL (F330), trước khi xuất ra sản xuất |
| **Mục đích?** | Đảm bảo NVL đạt chất lượng trước khi đưa vào sản xuất |

**Điều kiện trước:**
- NVL này phải được config (cấu hình) hạng mục kiểm tra ở **C122** (do QC thiết lập 1 lần)
- Nếu chưa config → C220 sẽ **trống**, không có hạng mục kiểm tra

**Cách làm:**
1. Mở **C220** → tìm NVL cần kiểm tra
2. Danh sách hạng mục kiểm tra hiện ra (từ C122)
3. QC kiểm tra từng hạng mục, nhập kết quả
4. Lưu kết quả

---

## BƯỚC 3: XUẤT NVL RA LINE SẢN XUẤT – F430

### F430 – Lịch sử xuất/nhập kho nguyên vật liệu

| | Chi tiết |
|---|---|
| **Làm gì?** | Xuất NVL từ kho ra cell line (dây chuyền sản xuất) để công nhân sử dụng |
| **Ai làm?** | Nhân viên kho nguyên vật liệu |
| **Làm khi nào?** | Khi sản xuất yêu cầu (order) NVL |
| **Mục đích?** | Chuyển NVL từ kho → sản xuất, ghi lại lịch sử xuất/nhập |

**Xuất kho (chức năng chính):**
1. Mở **F430** → ấn **"Nguyên liệu đầu ra"** (xuất kho)
2. Popup (cửa sổ nhỏ) hiện lên → chọn NVL và lot cần xuất
3. Xác nhận → NVL xuất ra cell line

> ⚠️ **Lot nào không có "Đặc tính 10"** (từ F330) → sẽ vào **kho holding** (tạm giữ), không xuất được

**Nhập kho lại (khi xuất nhầm):**
1. Ấn **"Nguyên liệu đầu vào"** → chọn NVL cần nhập lại
2. Chỉ dùng khi:
   - Xuất **nhầm line** → nhập lại
   - Hoặc cần chuyển NVL giữa các line

---

## BƯỚC 4: XEM TỒN KHO – F721

### F721 – Danh mục vật liệu tồn kho

| | Chi tiết |
|---|---|
| **Làm gì?** | Xem danh sách tất cả NVL đang có trong kho, theo từng lot |
| **Ai làm?** | Nhân viên kho, quản lý |
| **Làm khi nào?** | Bất kỳ lúc nào cần kiểm tra tồn kho |
| **Mục đích?** | Biết NVL nào còn bao nhiêu, lot nào hết hạn, lot nào trong kho holding |

**Cách làm:**
1. Mở **F721** → chọn **kho NVL** → tìm kiếm
2. Hiển thị tất cả lot NVL hiện có
3. Có thể lọc theo **mã NVL** cụ thể

---

## TÓM TẮT FLOW KHO NVL

```
Ai?          Việc gì?                          Màn hình     Kết quả
────         ────────                          ────────     ───────
Kho NVL      Cấu hình NCC ↔ NVL (1 lần)       F130/F140    NCC và NVL được liên kết
   ↓
Kho NVL      Ghi nhận NVL mới nhập             F312         Phiếu nhập ("Create")
   ↓
Kho NVL      Nhập kho + Tạo tem + Gán lot      F330         NVL có tem, có Đặc tính 10
   ↓
QC (IQC)     Kiểm tra chất lượng NVL           C220         NVL đạt/không đạt chất lượng
   ↓
Kho NVL      Xuất NVL ra cell line             F430         NVL sẵn sàng cho sản xuất
   ↓
Kho NVL      Kiểm tra tồn kho                  F721         Biết NVL còn bao nhiêu
```

---
*File: 10_chi_tiet_PHASE1_kho_NVL.md | Phần 1/4*
