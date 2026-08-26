# GW_07 — Kho Thành Phẩm & Quản Lý Mã Kho (Finished Good Warehouse)

> **Màn hình MES liên quan:** FG01 (Xuất kho tạm), B750 (In tem pallet), B752 (Kiểm tra chi tiết)
> **Liên kết nghiệp vụ:** [GW_08 — Luồng Bán Hàng & Xuất Khẩu](GW_08_BAN_HANG.md)
> ← [Về INDEX](GW_INDEX.md)

---

## 1. 📤 Xuất Ra Kho Tạm / Trung Chuyển (FG01)

Chuỗi thao tác hiện trường tại kho vận sau khi hàng hóa ra lò từ trạm kế hoạch ngày:

### Bước 1: Vào menu "Xuất ra kho tạm" (FG01)
- Trên thiết bị cầm tay (PDA) hoặc máy tính tại kho, chọn màn hình **FG01**.

### Bước 2: Scan Packing ID
- Sử dụng súng bắn Barcode để quét dữ liệu thùng **Packing ID** của từng box cần xuất.

### Bước 3: Nhập khách hàng thực tế
- Nhập hoặc chọn tên khách hàng thực tế nhận lô hàng để tích hợp vào thông tin kiện hàng.

### Bước 4: Kiểm tra lại lần cuối → Nhấn **"Lưu dữ liệu"**
- Xác nhận luân chuyển trạng thái hàng sang "Xuất ra kho trung chuyển/ kho tạm".

---

## 2. 🏷️ In Tem Pallet (B750)

Sau khi lưu dữ liệu xuất ra kho tạm thành công trên FG01:

1. Di chuyển qua trạm **B750** trên MES.
2. Thực hiện lệnh: **In tem thông tin lô hàng (Pallet Label)**.
3. **Dán niêm phong lên cụm Pallet bốc xếp** đã bọc màng PE bảo vệ.

---

## 3. 🚛 Xuất Lên Xe / Container (Shipment)

- Nhấn vào menu lệnh **"Xuất lên công te lơ"** (hoặc Xe vận tải).
- Thực hiện bắn thẳng lệnh xuất theo kiện (Scan từng thùng/Pallet bốc lên xe) → Hệ thống tự động đối chiếu với *Shipment Request* trên Groupware và ghi nhận lượng xuất kho thực tế.

---

## 4. 🔍 Kiểm Tra Chi Tiết Pallet (B752)

- Khi bốc dỡ hàng lên xe hoàn tất, Kỹ sư/Thủ kho tiến hành kiểm kê tổng lượng Pallet trong lòng Container.
- Vào màn hình giám sát **B752** của MES để xem lưới chi tiết, đối chiếu số lượng thực tế bốc lên so với kế hoạch xuất kho.

---

## 5. 📋 Luồng Vận Hành Hiện Trường Kho Thành Phẩm

```
[Kế hoạch ngày] Hàng hoàn tất đóng gói (B523)
     ↓
[FG01] Bắn Barcode scan Packing ID → Nhập khách hàng → Lưu (Chuyển kho tạm/trung chuyển)
     ↓
[B750] In tem thông tin lô hàng (Pallet Label) → Dán lên cụm Pallet bọc PE
     ↓
[Xuất lên Container] Quét kiện xuất lên xe (Bắn thẳng lệnh xuất theo kiện)
     ↓
[B752] Giám sát chi tiết lưới Pallet thực xuất trong lòng Container để đối chiếu
```

---

## 🗃️ Bảng Tra Cứu Mã Kho Việt Nam (Warehouse Code Master List)

Dưới đây là bảng đối chiếu chi tiết 100% danh mục mã kho (Material Warehouse Code) từ file Excel `Code_Warehouse_In_VietNam.xlsx` sử dụng trên hệ thống ERP và MES tại các nhà máy Vinatech Việt Nam:

| Mã Kho (Warehouse Code) | Công ty (Company) | Nhà máy (Work Center) | Tên Kho Tiếng Hàn | Tên Kho Tiếng Việt | Ghi Chú / Ý Nghĩa |
|-------------------------|-------------------|-----------------------|-------------------|-------------------|-------------------|
| **HEADQUARTER_BG_WH** | VVT | VVT_F2 | Bg_본사(베트남) | - | Không rõ ý nghĩa |
| **HEADQUARTER_VN_WH** | VVT | VVT_F1 | 본사(베트남) | - | Không rõ ý nghĩa |
| **HOLDING_BG_WH** | VVT | VVT_F2 | Bg_Hold원자재창고(베트남) | Kho nguyên vật liệu chờ xử lý Bắc Giang | Kho Hold kiểm tra chất lượng F2 |
| **HOLDING_VN_WH** | VVT | VVT_F1 | Hold원자재창고(베트남) | Kho nguyên vật liệu chờ xử lý Bắc Ninh | Kho Hold kiểm tra chất lượng F1 |
| **MODULE_BG_WH** | VVT | VVT_F2 | Bg_모듈(베트남) | Kho nguyên liệu cho hàng module Bắc Giang | Kho vật tư chuyên biệt cho Module F2 |
| **MODULE_VN_WH** | VVT | VVT_F1 | 모듈(베트남) | Kho nguyên liệu cho hàng module Bắc Ninh | Kho vật tư chuyên biệt cho Module F1 |
| **NG_RAW_BG_WH** | VVT | VVT_F2 | Bg_NG원자재창고(베트남) | Kho nguyên liệu bị NG nhà máy Bắc Giang | Kho chứa hàng lỗi/hỏng chờ trả Vendor F2 |
| **NG_RAW_VN_WH** | VVT | VVT_F1 | NG원자재창고(베트남) | Kho nguyên liệu bị NG nhà máy Bắc Ninh | Kho chứa hàng lỗi/hỏng chờ trả Vendor F1 |
| **NOI_DIA_BG** | VVT | VVT_F2 | Bg_NOI_DIA_BG | Xuất trả nhà cung cấp trong nước từ nhà máy Bắc Giang | Trả hàng nội địa F2 |
| **NOI_DIA_VN** | VVT | VVT_F1 | NOI_DIA_VN | Xuất trả nhà cung cấp trong nước từ nhà máy Bắc Ninh | Trả hàng nội địa F1 |
| **NUOC_NGOAI_BG** | VVT | VVT_F2 | Bg_NUOC_NGOAI_BG | Xuất trả nhà cung cấp nước ngoài từ nhà máy Bắc Giang | Trả hàng nhập khẩu F2 |
| **NUOC_NGOAI_VN** | VVT | VVT_F1 | NUOC_NGOAI_VN | Xuất trả nhà cung cấp nước ngoài từ nhà máy Bắc Ninh | Trả hàng nhập khẩu F1 |
| **PROD_BG_WH** | VVT | VVT_F2 | Bg_완제품창고(베트남) | Kho thành phẩm Bắc Giang | Kho lưu trữ thành phẩm chính F2 |
| **PROD_STBY_BG_WH** | VVT | VVT_F2 | Bg_제품입고대기창고(베트남) | - | Kho chờ nhập thành phẩm F2 (không rõ ý nghĩa) |
| **PROD_STBY_VN_WH** | VVT | VVT_F1 | 제품입고대기창고(베트남) | - | Kho chờ nhập thành phẩm F1 (không rõ ý nghĩa) |
| **PROD_VN_WH** | VVT | VVT_F1 | 완제품창고(베트남) | Kho thành phẩm Bắc Ninh | Kho lưu trữ thành phẩm chính F1 |
| **ROH_BG_WH** | VVT | VVT_F2 | Bg_원자재창고(베트남) | Kho nguyên vật liệu Bắc Ninh *(⚠️ Lỗi dịch trong Excel)* | Kho NVL chính F2 (Bắc Giang) |
| **ROH_VN_WH** | VVT | VVT_F1 | 원자재창고(베트남) | Kho nguyên vật liệu Bắc Giang *(⚠️ Lỗi dịch trong Excel)* | Kho NVL chính F1 (Bắc Ninh) |
| **ROUTE_BG_WH** | VVT | VVT_F2 | Bg_공정창고(베트남) | Sản xuất Bắc Giang | Kho công đoạn sản xuất F2 |
| **ROUTE_VN_WH** | VVT | VVT_F1 | 공정창고(베트남) | Sản xuất Bắc Ninh | Kho công đoạn sản xuất F1 |
| **TOTAL_MATERIALS** | VVT | VVT_F1 | TOTAL_MATERIALS | - | Không có dữ liệu |
| **W21_BG_WH** | VVT | VVT_F2 | Bg_전극슬리팅창고 | - | Kho điện cực Slitting F2 (không có dữ liệu) |
| **W21_VN_WH** | VVT | VVT_F1 | 전극슬리팅창고 | - | Kho điện cực Slitting F1 (không có dữ liệu) |
| **W27** | VVT | VVT_F3 | 창고(비나에너솔) | - | Kho nhà máy F3 (Vina Enersol Hà Nam) |

> ⚠️ **Chú ý về lỗi dịch thuật trong file Excel gốc:**
> Trong file Excel gốc, tên tiếng Việt của **ROH_BG_WH** (thuộc nhà máy F2 - Bắc Giang) bị ghi nhầm thành "Bắc Ninh", và **ROH_VN_WH** (thuộc nhà máy F1 - Bắc Ninh) bị ghi nhầm thành "Bắc Giang". Trên thực tế vận hành và cài đặt hệ thống, thủ kho cần hiểu đúng theo phân cấp: **VN = Bắc Ninh (F1)** và **BG = Bắc Giang (F2)**.

---

## 6. 📦 Product Receiving Confirmation Document (Xác Nhận Nhập Kho Vật Lý Sản Phẩm)

**Vào:** Electronic Document → Purchase → Product Receiving Confirmation Document (Mã biểu mẫu: `receivingPhysicalItemConfirmationDocument`)

- **Mục đích:** Dùng để khai báo nhập hoặc xuất kho vật lý cho các Lot sản phẩm thành phẩm/bán thành phẩm nội bộ của công ty.
- **Các trường thông tin cơ bản:**
  - **Phân loại giao dịch (allWarehouseInOutCode):** Chọn `Nhập kho` (`I`) hoặc `Xuất hàng` (`O`).
  - **문서 내용(비고) (documentSaveContent):** Nhập nội dung ghi chú/lý do nhập xuất.
- **Bảng chi tiết Lot hàng (Table 1 / Index 1):**
  - `No.` | `Mục` (Mã/Tên sản phẩm) | `* LotNo` (Mã số Lot sản xuất) | `* Kho (Đăng ký hàng loạt)` (Mã kho nhận/xuất) | `* Số lượng` (Số lượng sản phẩm trong Lot) | `Ghi Chú` | `Sản phẩm nhập kho của công ty` (Check box) | `Thêm/Xóa (Xóa tất cả)`

---

## ❓ Các Lỗi Thường Gặp

| Tình huống | Nguyên nhân | Xử lý |
|-----------|-------------|-------|
| Không scan được Packing ID | Box chưa đóng gói hoàn chỉnh | Hoàn tất đóng gói tại trạm **B523** trước |
| Không in được tem pallet | Chưa lưu dữ liệu FG01 thành công | Kiểm tra lại bước "Lưu dữ liệu" trên màn hình FG01 |
| Packing ID không xuất hiện | Box chưa vào kho tạm | Thực hiện bắn quét lưu thông tin trên FG01 trước |

---

*Cập nhật: 2026-06-12 | Nguồn: Hướng dẫn Finished Good warehouse.pptx + Code_Warehouse_In_VietNam.xlsx + Comprehensive_Groupware_Report.md*
