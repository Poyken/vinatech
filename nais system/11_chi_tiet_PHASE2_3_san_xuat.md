# CHI TIẾT PHASE 2: KẾ HOẠCH SẢN XUẤT + PHASE 3: SẢN XUẤT TRÊN CELL LINE

> Mô tả từng bước: Làm gì → Ai làm → Làm như thế nào → Làm để làm gì

---

## PHASE 2: LẬP KẾ HOẠCH SẢN XUẤT

### BƯỚC 1: TẠO LỆNH SẢN XUẤT THEO THÁNG – B310

#### B310 – Tạo PO (Production Order - Lệnh sản xuất)

| | Chi tiết |
|---|---|
| **Làm gì?** | Tạo 1 lệnh sản xuất cho cả tháng, ghi rõ sản xuất con hàng nào, bao nhiêu cái |
| **Ai làm?** | Bộ phận hỗ trợ sản xuất (Support production) hoặc quản lý sản xuất |
| **Làm khi nào?** | Đầu mỗi tháng, khi có kế hoạch sản xuất mới |
| **Mục đích?** | Là "đầu vào" cho mọi hoạt động SX trong tháng. Không có PO → không có kế hoạch ngày → không sản xuất được |

**Cách làm:**
1. Mở **B310** → ấn **"Tạo PO thủ công"**
2. Popup (cửa sổ nhỏ) hiện ra → điền thông tin:
   - Chọn **sản phẩm** cần sản xuất
   - **BomVersion** (phiên bản BOM - danh sách nguyên vật liệu): bắt buộc nhập **99**
   - **ProQty** (số lượng sản xuất): nhập số lượng **cả THÁNG**, không phải theo ngày
3. Ấn **OK** để tạo PO
4. **Quan trọng**: Tích chọn PO vừa tạo → ấn **"Chốt"** (xác nhận)
5. Nhìn các **tab bên dưới** → kiểm tra công đoạn sản xuất đã đúng chưa

**Các nút khác:**
- **POCancel** (hủy PO): xóa PO vừa tạo nếu sai

> ⚠️ **Phải "Chốt" thì PO mới có hiệu lực.** Nếu chỉ tạo mà chưa Chốt → PO chưa dùng được.

---

### BƯỚC 2: CHIA KẾ HOẠCH THEO NGÀY – B450

#### B450 – Kế hoạch lắp ráp theo ngày

| | Chi tiết |
|---|---|
| **Làm gì?** | Chia PO (kế hoạch tháng) thành kế hoạch từng ngày: ngày nào, line nào, ca nào, bao nhiêu cái |
| **Ai làm?** | Bộ phận hỗ trợ sản xuất hoặc quản lý sản xuất |
| **Làm khi nào?** | Sau khi đã Chốt PO ở B310, trước ngày sản xuất |
| **Mục đích?** | Để sản xuất biết ngày nào làm gì, bao nhiêu cái, trên line nào |

**Cách làm:**
1. Mở **B450** → ấn **"POSelectDialog"** (chọn PO)
2. Popup hiện → nhập **số PO** (đã tạo ở B310) → tìm kiếm → chọn → **OK**
3. Thông tin PO hiện ra → điền **4 cột bắt buộc** (có màu đậm):

| Cột | Ý nghĩa | Ví dụ |
|-----|---------|-------|
| **Mã line** | Sản xuất trên line (dây chuyền) nào | LINE-01 |
| **Ngày theo kế hoạch** | Ngày sản xuất cụ thể | 2026-03-07 |
| **PlanShiftCode** (mã ca) | Ca sản xuất: **1** = ca ngày, **2** = ca đêm | 1 |
| **Số lượng kế hoạch** | Số lượng sản xuất trong ngày đó | 500 |

4. Ấn **Save** (lưu)
5. Ấn **"FixDayPlan"** (chốt kế hoạch ngày) → sản xuất mới tạo được lot

> ⚠️ **"FixDayPlan" là bước quyết định:** Chưa ấn = sản xuất **KHÔNG tạo lot được**.
> 💡 **Mẹo:** Có thể tạo kế hoạch ngày trước nhiều ngày, đến ngày SX mới ấn FixDayPlan.

---

## PHASE 3: SẢN XUẤT TRÊN CELL LINE

### BƯỚC 3: NHẬP THẺ CÔNG ĐOẠN – B540

#### B540 – Nhập thẻ công đoạn (Màn hình chính của sản xuất)

| | Chi tiết |
|---|---|
| **Làm gì?** | Theo dõi và ghi nhận quá trình sản xuất qua từng công đoạn: sấy hàng, kiểm tra, nhập lỗi |
| **Ai làm?** | OP (Operator - công nhân vận hành) trên cell line |
| **Làm khi nào?** | Trong suốt quá trình sản xuất, khi hàng đi qua từng công đoạn |
| **Mục đích?** | Ghi nhận hàng đang ở công đoạn nào, NVL nào được dùng, lỗi bao nhiêu |

**B540 có 3 chức năng chính:**

---

#### Chức năng 1: Sấy hàng

| | Chi tiết |
|---|---|
| **Làm gì?** | Ghi nhận con hàng được sấy trên máy sấy nào, rồi in barcode (mã vạch) cho nó |
| **Mục đích?** | Mỗi con hàng cần barcode để theo dõi qua các công đoạn tiếp theo |

**Cách làm:**
1. Ấn nút **"Sấy hàng"** → màn hình sấy hiện lên
2. Chọn **máy sấy** → ấn **"Tìm kiếm"**
3. Ấn **Lưu** (⚠️ lưu rồi **không sửa được** nữa)
4. Điền **4 cột có màu đậm** (bắt buộc) → phải điền đủ mới in barcode được
5. **In barcode** cho con hàng

> ⚠️ Thiếu thông tin 4 cột đậm → in barcode **báo lỗi**

---

#### Chức năng 2: Kiểm tra thường xuyên (Việt Nam)

| | Chi tiết |
|---|---|
| **Làm gì?** | Nhập thông số kiểm tra sau khi sấy + scan (bắn) mã NVL đã dùng để tạo con hàng |
| **Mục đích?** | Ghi nhận chất lượng + truy xuất nguồn gốc NVL cho từng con hàng |

**Cách làm:**
1. Ấn **"Việt Nam_Kiểm tra thường xuyên"** → màn hình mới hiện lên
2. **Khung A** (bên trái): Nhập thông số kiểm tra
   - Kiểm tra sau sấy: ngoại quan (bề mặt), đo đạc kích thước thực tế
   - Nhập xong → **Lưu**
3. **Khung B** (bên phải): Nhập mã NVL
   - Bắn/scan mã barcode từng NVL đã dùng để tạo con hàng
   - Nhập xong → **Lưu**

> ⚠️ **NVL phải order (đặt) từ kho trước** → kho xuất ra (qua F430) → mới bắn mã lên hệ thống được.
> Nếu NVL chưa xuất từ kho → bắn mã sẽ **không nhận**.

---

#### Chức năng 3: Nhập số lượng sản xuất (Nhập lỗi)

| | Chi tiết |
|---|---|
| **Làm gì?** | Ghi nhận số lượng hàng bị lỗi trên từng công đoạn, phân loại theo từng loại lỗi |
| **Ai làm?** | OP (công nhân) nhập, quản lý kiểm tra |
| **Mục đích?** | Theo dõi tỷ lệ lỗi, biết lỗi gì xảy ra nhiều nhất để cải thiện |

**Cách làm:**
1. Ấn **"Nhập slg sản xuất"** (nhập số lượng sản xuất)
2. Ấn **(+)** → thêm 1 dòng lỗi mới
3. Chọn **loại lỗi** (danh sách lỗi từ C132 - do QC thiết lập trước)
4. Nhập **DefectQty** (số lượng hàng lỗi) cho loại lỗi đó
5. Ấn **"Nhập lỗi"** → popup xác nhận → **Yes**
6. Lặp lại bước 2-5 cho đến khi nhập hết tất cả loại lỗi
7. Ấn **"Hoàn thành kết quả sản xuất"** → **Yes** xác nhận
8. Ra màn hình ngoài → kiểm tra:
   - Số lượng lỗi đã đúng chưa?
   - **Số lượng đầu vào công đoạn tiếp theo** = Số lượng đầu vào - Số lỗi

> 💡 Sau khi "Hoàn thành kết quả sản xuất", hàng **tự chuyển sang công đoạn tiếp theo** trên hệ thống.

---

### BƯỚC 3.5: CÁC MÀN HÌNH SONG SONG VỚI B540

#### B597 – Nhập thông số kiểm tra (mã TEST từ C143)

| | Chi tiết |
|---|---|
| **Làm gì?** | Nhập các thông số kiểm tra kỹ thuật mà **sản xuất tự kiểm tra** (không phải QC) |
| **Ai làm?** | OP (công nhân) hoặc Part leader (tổ trưởng) |
| **Liên kết** | Hạng mục kiểm tra lấy từ C143 → chỉ những mã có loại **"TEST"** |
| **Mục đích?** | Sản xuất tự kiểm tra thông số kỹ thuật trong quá trình SX (self-inspection - tự kiểm) |

#### C443 – Kiểm tra PQC (mã QUALITY từ C143)

| | Chi tiết |
|---|---|
| **Làm gì?** | QC (nhóm PQC) kiểm tra chất lượng trên công đoạn sản xuất |
| **Ai làm?** | Nhân viên PQC (Process Quality Control - kiểm soát chất lượng quy trình) |
| **Liên kết** | Hạng mục lấy từ C143 → chỉ những mã có loại **"QUALITY"** |
| **Mục đích?** | QC kiểm tra độc lập, đảm bảo sản xuất đang chạy đúng tiêu chuẩn |

> 💡 **TEST vs QUALITY:** Cùng config ở C143, nhưng:
> - **TEST** → SX tự kiểm ở **B597**
> - **QUALITY** → QC kiểm ở **C443**

#### B530 – Nhập lỗi trên từng công đoạn

| | Chi tiết |
|---|---|
| **Làm gì?** | Nhập số lượng lỗi chi tiết cho từng công đoạn (giống chức năng 3 của B540) |
| **Ai làm?** | OP hoặc Part leader |
| **Liên kết** | Danh sách lỗi từ C132 (QC thiết lập) |

#### B598 – Báo phế nguyên vật liệu

| | Chi tiết |
|---|---|
| **Làm gì?** | Báo cáo NVL bị hỏng/hư trong quá trình sản xuất, không dùng được nữa |
| **Ai làm?** | OP nhập dữ liệu, quản lý kiểm tra và duyệt |
| **Làm khi nào?** | Khi phát hiện NVL hỏng trong quá trình SX |
| **Mục đích?** | Ghi nhận lượng NVL hao phí → tính toán chi phí, đặt hàng bổ sung |

**Cách làm:**
1. Mở **B598** → ấn **(+)** thêm dòng mới
2. Điền: loại NVL bị phế, số lượng, lý do
3. Ấn **Save**

#### C385 – Báo cáo bất thường

| | Chi tiết |
|---|---|
| **Làm gì?** | Tạo báo cáo khi phát hiện vấn đề bất thường trong SX (lỗi nghiêm trọng, sự cố...) |
| **Ai làm?** | QC hoặc SX |
| **Đặc biệt** | Hệ thống **tự gửi email** thông báo đến những người liên quan |
| **Xem lại** | Dùng **C390** để xem lại các báo cáo bất thường đã tạo |

---

### TÓM TẮT FLOW SẢN XUẤT

```
Ai?              Việc gì?                              Màn hình    Kết quả
────              ────────                              ────────    ───────
Support SX       Tạo PO (lệnh SX tháng)                B310        PO được Chốt
   ↓
Support SX       Chia kế hoạch ngày                     B450        Kế hoạch ngày → FixDayPlan
   ↓
OP (công nhân)   Sấy hàng → In barcode                  B540        Hàng có mã vạch
   ↓
OP               Kiểm tra thường xuyên + Scan NVL        B540        Thông số + NVL được ghi nhận
   ↓
OP               Nhập lỗi → Hoàn thành công đoạn         B540        Hàng chuyển công đoạn tiếp
   ↓
OP / PQC         Kiểm tra thông số (SX tự kiểm)          B597        Thông số kỹ thuật OK
PQC              Kiểm tra chất lượng (QC kiểm)            C443        Chất lượng đạt chuẩn
   ↓
OP               Báo phế NVL hỏng                        B598        NVL phế được ghi nhận
QC / SX          Báo cáo bất thường (nếu có)              C385        Email thông báo tự động
```

---
*File: 11_chi_tiet_PHASE2_3_san_xuat.md | Phần 2/4*
