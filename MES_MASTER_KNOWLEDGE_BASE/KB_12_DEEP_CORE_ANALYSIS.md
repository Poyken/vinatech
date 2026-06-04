# KB_12 — Phân Tích Sâu Cốt Lõi Hệ Thống (Deep Core Analysis)

> **Mục đích:** Giải thích BẢN CHẤT THÂM SÂU của hệ thống — những gì không thấy trên UI, không có trong document cũ. Từ việc phân tích từng dòng code của 10+ SP quan trọng nhất. Dành cho IT/Developer.
> ← [Về INDEX](KB_INDEX.md)

---

## 1. 🧠 DNA Hệ Thống — 5 Triết Lý Thiết Kế Cốt Lõi

### Triết lý 1: "Database là não, UI chỉ là tay"
Hầu hết các hệ thống MES phương Tây nhúng business logic vào application layer (C#, Java). NAIS làm ngược lại: **toàn bộ logic nghiệp vụ nằm trong Database**.
- Khi bấm nút "Hoàn thành", UI chỉ đọc tên SP từ `SmartFramework.STB_ScreenObjects` rồi gọi nó.
- SP tự tính toán, tự validate, tự write. UI không biết gì.
- **Hệ quả:** Sửa SP = sửa logic, không cần deploy phần mềm. Khó test và debug nếu không có quyền DB.

### Triết lý 2: "Barcode là passport, Routing History là visa stamp"
Một viên tụ điện = Một "người" đi qua hải quan quốc tế.
- `ControlNo`/`Barcode` = Số hộ chiếu (không đổi suốt đời).
- `STB_SetInfo` = Sổ hộ chiếu.
- `STB_ProdRouteHist` = Visa stamp tại từng điểm.
- Bỏ qua trạm = Vi phạm xuất nhập cảnh → bị chặn.
Hệ thống tự động tìm công đoạn `N+1` từ `RouteIndex` chứ không cần config thủ công "bước này đến bước nào".

### Triết lý 3: "Validation tại Database, không phải UI"
Ví dụ B597 có 3 cổng chặn cứng từ SP `usp_Vietnam_RawMaterialInputHist_uid`:
1. Check HOLD.
2. Check Expiry Date (tính bằng `MMExtInt01`).
3. Check BOM ngầm trong `stb_vvt_materialbo`.

### Triết lý 4: "Tồn kho được tính trong lúc chạy, không phải lưu sẵn"
SP `usp_vvt_MaterialLotInfo_get` (Màn F721) tính hạn sử dụng real-time mỗi lần load, thay vì lưu vào field `ExpiredDate` cố định. Cảnh báo Warning sẽ tự bật (15 ngày cho cuộn, 30 ngày cho vật tư thường).

### Triết lý 5: "Audit Trail không thể xóa, không thể sửa"
Bảng `STB_ProcedureLog` là camera an ninh. Mỗi lần SP quan trọng chạy đều INSERT thông tin User, Barcode, Time, Parameters. Khi OP khiếu nại mất dữ liệu, IT có thể xem lại bảng này để biết ai làm.

---

## 2. 🔄 Luồng Dữ Liệu Thực Tế Từ Source Code

### 2.1 Luồng chính tại B530 (Đóng Lot / Nhập sản lượng)
Khi OP bấm "Hoàn thành", `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` thực thi qua 17 bước, đáng chú ý:
- **GATE Điện Cực:** Check YP=dương, BY=âm đã scan chưa.
- **Xóa Dữ liệu tạm:** DELETE `STB_InterimProdQtyInfo` (InbrinskQty).
- **GATE 20 Phút:** Bắt buộc chờ 20 phút giữa 2 công đoạn (Bug: Đang bị lỗi `@SIExtInt01 = Null` làm gate này không hoạt động).
- **Ghi Takt Time:** Cho VVT.

### 2.2 Luồng B597 (Scan NVL) — Lớp Validation khổng lồ
- Cơ chế **Chain Barcode**: Trace lịch sử đổi mã barcode đến 6 cấp qua bảng `STB_LotChangeMaterialHistory`.
- Trích xuất **ModelSize**: Kích thước như 0813 (8x13mm) được bóc từ `STB_ModelBasicInfo` để match với điện giải.

### 2.3 Luồng F721 — UPDATE khi đang SELECT
SP `usp_vvt_MaterialLotInfo_get` (F721) thực tế có lệnh **UPDATE** 2 bảng `STB_MaterialDocLotInfo` và `STB_MaterialLotInfo` mỗi khi chạy. Hàm `fn_VVT_getdatebyVendorLot` parse mã Vendor Lot để điền ngày sản xuất nếu bị thiếu. Việc này là auto-heal nhưng tiềm ẩn lỗi Race condition.

---

## 3. 🗃️ Bảng Ẩn Chứa Logic Quan Trọng (Custom Vietnam)

Những bảng này do team Vietnam tự tạo thêm, không nằm trong framework gốc Hàn Quốc. Nếu không biết chúng, bạn không thể debug được.

| Bảng | Mục đích thực tế |
|------|------------------|
| `stb_vvt_materialbo` | "BOM Ngầm" của B597. Define Model Size nào dùng loại Tancha/Sleeve mã nào. Nếu có model mới, PHẢI thêm vào đây. |
| `STB_LotChangeMaterialHistory` | Lưu lịch sử đổi Barcode (OldBarcode → NewBarcode). B597 dùng bảng này để dò ngược 6 cấp lấy mã gốc. |
| `stb_vvt_OpenExpiredMaterial` | Danh sách "Ân Xá" cho NVL hết hạn. Thêm LotID vào bảng này = Bypass kiểm tra Hạn Sử Dụng. |
| `STB_InterimProdQtyInfo` | Bảng nháp số lượng giữa chừng (InbrinskQty tại B530). Bị xóa trắng mỗi lần Submit. |
| `stb_slittinglocationconfig_vvt` | Cấu hình Slitting động. Tránh việc hard-code cấu hình trong SP. |

---

## 4. ⚠️ 5 Điểm Nguy Hiểm ẨN — Developer Phải Biết

1. **Nguy hiểm 1 (F721 Update)**: SP F721 Write khi đang Read. Không có transaction. Nếu parse Date sai, sẽ ghi Date sai hàng loạt.
2. **Nguy hiểm 2 (Bug Null)**: Logic `IF @SIExtInt01 = Null` trong SP B530 làm Gate 20 phút bị tắt ngấm. (SQL phải dùng `IS NULL`).
3. **Nguy hiểm 3 (No Rollback)**: Bending/Tapping (B717) chỉ lưu 1 lần, ghi đè hoặc insert, nếu sai chỉ có thể Update bằng tay trong DB, trên UI không có nút Sửa/Xóa.
4. **Nguy hiểm 4 (Hardcode User)**: SP `usp_Set_VVT_Info_get` (B452) hardcode danh sách User được phép đổi Line (`mrluan`, `phuong`). Mất quyền nếu đổi username.
5. **Nguy hiểm 5 (Hardcode Model)**: Cả tá model name được Hardcode trong `usp_Vietnam_RawMaterialInputHist_uid`. Có model mới → Phải vào SP gõ thêm dòng SELECT.

---

## 5. 📡 Các Functions Quan Trọng

### `fn_VVT_getdatebyVendorLot(MaterialCode, LotNo)`
- **Mục đích:** Chuyển mã Lot của Vendor thành Date (`YYYY-MM-DD`).
- **Nơi dùng:** F721, Chi tiết Lot.
- **Rủi ro:** Vendor đổi định dạng mã → Hàm crash → Tồn kho F721 bị lỗi (Ngày SX rỗng).

### `fn_GetJobDateShiftTime(DateTime, CompanyCode, WorkCenter, Line, Route, NULL)`
- **Mục đích:** Tính Ca sản xuất tự động (`JobDate`, `ShiftCode A/B/C`).
- **Tại sao:** Ngăn gian lận ca bằng cách tự động tính từ thời gian Scan thực tế, khóa cứng không cho Client chọn ngày/ca.

---

## 6. 🎯 Golden Rules Khi Debug NAIS

1. **Lỗi FIFO / Hết hạn B597:**
   - Kiểm tra HOLD: `SELECT * FROM STB_MaterialHoldInfo WHERE LotID = '...' AND IsRelease = 0`
   - Kiểm tra Expiry: `LotAttr10` + (`MMExtInt01` * 30 ngày)
   - Bảng Ân Xá: `SELECT * FROM stb_vvt_OpenExpiredMaterial WHERE LotID = '...'`
2. **Lỗi B530 "Chưa nhập đủ":**
   - Check BOM: `SELECT * FROM STB_ProductionOrderRouting WHERE PONo = '...'`
   - Check lịch sử Scan: `SELECT * FROM STB_RawMaterialInputHist WHERE ProdLotQty = '...'`
3. **F721 Tồn kho trắng trơn hoặc Exception:**
   - K.tra `LotAttr10`: `SELECT LotAttr10 FROM STB_MaterialDocLotInfo WHERE LotID = '...'` (Nếu NULL = hàm VendorLot Date bị fail).

*Cập nhật: 2026-05-22*
