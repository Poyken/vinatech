# CHI TIẾT PHASE 4: ĐÓNG GÓI + KIỂM TRA OQC + KHO THÀNH PHẨM

> Mô tả từng bước: Làm gì → Ai làm → Làm như thế nào → Làm để làm gì

---

## BƯỚC 1: ĐÓNG GÓI TRÊN LINE – B523

### B523 – Gộp box, chia box và in tem đóng gói

| | Chi tiết |
|---|---|
| **Làm gì?** | Sau khi hàng đã qua hết các công đoạn SX, gộp nhiều sản phẩm vào box (thùng), in tem cho box, chia nhỏ box nếu cần |
| **Ai làm?** | OP (công nhân) trên cell line, nhân viên đóng gói |
| **Làm khi nào?** | Sau khi hàng hoàn thành công đoạn cuối trên cell line |
| **Mục đích?** | Sản phẩm được đóng gói + có tem mã vạch → sẵn sàng cho QC kiểm tra và nhập kho thành phẩm |

**Cách làm - Phần 1: In tem box to**
1. Tại B523, sau khi gộp box → thông tin box to hiện ở **Bảng 3**
2. Chọn dòng cần in → ấn **"In tem"**

> ⚠️ **Quy tắc in tem:**
> - Chỉ in **1 lần duy nhất** → in lần 2 sẽ báo lỗi
> - Muốn in lại → **liên hệ EA team**
> - **Phải in tem box to TRƯỚC** khi chia box → không in = không chia được

**Cách làm - Phần 2: Chia box**
1. Chọn dòng **PackingID** (mã đóng gói) cần chia
2. Ấn **"Chia box"**
3. Nhập **số lượng box mới** cần chia → xong

> ⚠️ Sau khi chia, cũng phải **in tem box nhỏ trước** mới chia tiếp được

**Liên kết:**
- Số lượng sản phẩm trong 1 box được config (cấu hình) ở **A418** theo kích cỡ (size) sản phẩm
- Config A418 lấy thông tin MBISizeD từ **A410** (thông tin model)

---

## BƯỚC 2: QC KIỂM TRA THÀNH PHẨM – OQC

### C512 – Tạo lot kiểm tra OQC

| | Chi tiết |
|---|---|
| **Làm gì?** | Tạo 1 lot (lô) kiểm tra cho QC, dựa trên mã barcode (mã vạch) của sản phẩm |
| **Ai làm?** | Nhân viên OQC (Outgoing Quality Control - kiểm tra chất lượng đầu ra) |
| **Làm khi nào?** | Sau khi sản xuất đã đóng gói (B523) và cung cấp barcode |
| **Mục đích?** | Tạo "đơn kiểm tra" để OQC biết cần kiểm tra gì, bao nhiêu mẫu |

**Cách làm:**
1. Mở **C512** → dán **mã barcode** (do sản xuất cung cấp) → Tìm kiếm
2. Thông tin lot hiện ra → ấn **"Tạo Lot"**

> ⚠️ **Nếu không có dữ liệu:**
> - **TH1**: Lot này đã tạo rồi → sang **C530** kiểm tra
> - **TH2**: Chưa config (cấu hình) hạng mục kiểm tra ở **A410** → phải config trước
> - Vẫn không thấy → liên hệ **EA team**

**Điều kiện trước:**
- Model phải config ở **C151** (hạng mục kiểm tra OQC cho từng sản phẩm)
- Nếu model không có trong C151 → vào **A410** → điền trường **"Loại kiểm tra"** + **"Loại OQC"** → Lưu → tắt C151 mở lại

---

### C530 – Kiểm tra OQC theo từng mẫu

| | Chi tiết |
|---|---|
| **Làm gì?** | QC kiểm tra thực tế từng mẫu sản phẩm: đo đạc, so sánh với tiêu chuẩn |
| **Ai làm?** | Nhân viên OQC |
| **Làm khi nào?** | Sau khi tạo lot ở C512 |
| **Mục đích?** | Đảm bảo sản phẩm đạt chất lượng trước khi xuất cho khách hàng |

**Cách làm (5 bước, lặp lại cho từng hạng mục):**
1. Nhập mã barcode + mã nhân viên → Tìm kiếm
2. **Chọn hạng mục** cần kiểm tra (bảng trái)
3. **Nhập giá trị đo** ở bảng bên phải → **Lưu** (bảng phải)
4. **Chọn kết quả Pass** (đạt) hoặc Fail (không đạt) ở bảng trái → **Lưu** (bảng trái)
5. Lặp lại cho từng hạng mục
6. Xong hết → ấn **"Đánh giá OK"** → **Lưu**

> ⚠️ **Màn hình này chậm** (nhiều truy vấn dữ liệu) → thao tác từ từ, đợi load xong mới bấm tiếp

---

### C540 – Lịch sử kiểm tra OQC

| | Chi tiết |
|---|---|
| **Làm gì?** | Xem lại kết quả kiểm tra OQC đã thực hiện ở C530 |
| **Ai làm?** | OQC, quản lý |
| **Mục đích?** | Tra cứu, đối chiếu kết quả kiểm tra, phục vụ báo cáo |

---

### C546 – Kiểm tra ESR (khi xuất kho)

| | Chi tiết |
|---|---|
| **Làm gì?** | Kiểm tra ESR (Equivalent Series Resistance - điện trở tương đương) cho sản phẩm trước khi xuất kho |
| **Ai làm?** | OQC |
| **Làm khi nào?** | Khi sản phẩm chuẩn bị xuất kho giao cho khách |
| **Mục đích?** | Kiểm tra thông số điện cuối cùng, đảm bảo sản phẩm hoạt động đúng |

**Cách làm:**
1. Mở **C546** → tìm kiếm theo ngày hoặc mã barcode
2. Lot kiểm tra lấy từ **C510** (tạo lot trước đó)
3. Nhập **giá trị đo ESR** → **Save**

> ⚠️ Nếu lot không hiển thị → kiểm tra lại **C510** đã tạo lot chưa

### C541 – Lịch sử kiểm tra ESR
- Xem lại kết quả kiểm tra ESR từ C546

---

## BƯỚC 3: IN TEM XUẤT HÀNG – B453

### B453 – In tem Inner (tem trong) và Outer (tem ngoài)

| | Chi tiết |
|---|---|
| **Làm gì?** | In tem dán lên thùng hàng khi xuất cho khách: tem nhỏ bên trong (inner) và tem lớn bên ngoài (outer) |
| **Ai làm?** | Nhân viên kho thành phẩm |
| **Làm khi nào?** | Khi hàng đã qua OQC, chuẩn bị xuất kho giao khách |
| **Mục đích?** | Dán tem có đầy đủ thông tin (mã hàng, số hóa đơn, số lượng) lên thùng hàng để khách nhận diện |

**In tem INNER (tem trong):**
1. Điền: **Custom Part No** (mã hàng khách), **Invoice No** (số hóa đơn), **Invoice Date** (ngày hóa đơn), **Packet Qty** (số lượng)
2. ⚠️ **KHÔNG tick IsOuter** (không phải tem ngoài)
3. Ấn Tìm kiếm → Ấn **"In tem INNER"**

**In tem OUTER (tem ngoài):**
1. Điền: Custom Part No, Invoice No, Invoice Date, **BoxQTY** (số lượng thùng), **Number Of Total** (tổng số)
2. ✅ **Tick chọn IsOuter** (là tem ngoài)
3. Ấn Tìm kiếm → Ấn **"In tem OUTER"**

> 💡 **Number Of Total**: Nếu không điền → mặc định = 1

---

## BƯỚC 4: KHO THÀNH PHẨM

### FG01, FG00, HN00 – Tồn kho thành phẩm

| Màn hình | Kho | Chi tiết |
|----------|-----|----------|
| **FG01** | Bắc Ninh | Xem tồn kho thành phẩm tại nhà máy Bắc Ninh |
| **FG00** | Bắc Giang | Xem tồn kho thành phẩm tại nhà máy Bắc Giang |
| **HN00** | Hà Nam | Xem tồn kho thành phẩm tại nhà máy Hà Nam |
| **FG02** | Tổng hợp | Xem tổng hợp cả Bắc Ninh + Bắc Giang |

| | Chi tiết |
|---|---|
| **Ai xem?** | Nhân viên kho thành phẩm, quản lý |
| **Mục đích?** | Biết sản phẩm nào còn trong kho, bao nhiêu → phục vụ xuất hàng cho khách |

---

## BƯỚC 5: BÁO CÁO (CHO QUẢN LÝ)

| Màn hình | Nội dung | Ai xem? |
|----------|----------|---------|
| **B781** | Chốt đóng gói + đơn giá chế tạo | Quản lý |
| **B682** | Tổng lỗi lắp ráp (thành phẩm + bán thành phẩm) | Quản lý |
| **B782** | Lỗi chi tiết theo từng công đoạn | Quản lý |
| **B726** | Lỗi NG (Not Good - không đạt) + holding (tạm giữ) | Quản lý |
| **B718** | NG cơ khí (gập chân, uốn chân, tapping...) | Quản lý |
| **B802** | NG điện cực | Quản lý |
| **B791** | Phế công đoạn module | Quản lý |

---

## TÓM TẮT FLOW PHASE 4

```
Ai?              Việc gì?                              Màn hình    Kết quả
────              ────────                              ────────    ───────
OP / Đóng gói   Gộp box + In tem                       B523        Thùng hàng có tem
   ↓
OQC              Tạo lot kiểm tra                       C512        Lot OQC sẵn sàng
   ↓
OQC              Kiểm tra từng mẫu (5 bước)             C530        Sản phẩm Pass/Fail
   ↓
OQC              Kiểm tra ESR (nếu cần)                 C546        Thông số điện OK
   ↓
Kho TP           In tem Inner + Outer                   B453        Thùng hàng có tem xuất
   ↓
Kho TP           Nhập kho TP + Xem tồn kho              FG01/00     Sản phẩm trong kho TP
   ↓
Kho TP           Đóng gói gộp thùng xuất hàng           B525/B528   Hàng sẵn sàng giao khách
   ↓
Quản lý          Xem báo cáo sản lượng, lỗi             B781/B782   Nắm tình hình SX
```

---
*File: 12_chi_tiet_PHASE4_dong_goi_QC_kho.md | Phần 3/4*
