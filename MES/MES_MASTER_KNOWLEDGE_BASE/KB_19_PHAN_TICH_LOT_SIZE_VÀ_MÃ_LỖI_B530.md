# KB_19 - Báo Cáo Phân Tích & Đối Soát Dữ Liệu Thay Đổi Quy Mô Lot No Và Danh Mục Mã Lỗi B530

> **Hệ thống liên quan:** MES (Phân hệ sản xuất & QC)  
> **Màn hình liên quan:** B530 (Nhập sản lượng công đoạn), B523 (Gộp Box Cell), C530 (Nhập kết quả kiểm tra)  
> **Tài liệu đối chiếu:** `Thay đổi số lượng lot no.xlsx` & `File báo cáo chỉnh sửa lỗi hệ thống ...xlsx`  
> ← [Về INDEX](KB_INDEX.md)

---

## 1. Bối Cảnh
Trong quá trình vận hành hệ thống MES tại nhà máy Vinatech Bắc Giang (BG), bộ phận sản xuất và chất lượng đã phát hành hai yêu cầu thay đổi cấu hình dữ liệu quan trọng:
1. **Thay đổi quy mô Lot No sản phẩm** (Lot Size) kết hợp thay đổi phương pháp sấy và số lượng mẫu test phá hủy.
2. **Chuẩn hóa danh mục mã lỗi hiển thị trên màn hình B530** (disable 28 mã trùng lặp/dư thừa và thêm mới 7 mã lỗi thực tế).

Tài liệu này ghi nhận kết quả đối soát thực tế giữa yêu cầu trong các file Excel và hiện trạng cấu hình trên cơ sở dữ liệu `SmartFactoryV2` (tính đến ngày 05/06/2026).

---

## 2. Kết Quả Đối Soát & Tình Trạng Hiện Tại

### 2.1 File `Thay đổi số lượng lot no.xlsx` (⚠️ CHƯA ĐƯỢC COVER ĐẦY ĐỦ)

| Nội dung yêu cầu | Hiện trạng trên Database | Trạng thái | Ghi chú & Khắc phục |
| :--- | :--- | :--- | :--- |
| **Cấu hình đóng gói Model `1840`** (Thường: 500ea, Hela: 640ea) | Không tìm thấy bất kỳ bản ghi nào của size **`1840`** trong bảng `STB_PackingStandard`. | **Chưa cấu hình** | Sẽ bị lỗi *"Chưa có tiêu chuẩn đóng gói"* khi công nhân quét gộp Box tại màn hình **B523**. Cần chạy script chèn thêm size `1840`. |
| **Quy định số mẫu test phá hủy là `6`** cho các Lot Size lớn (`2k`, `3k`, `4k`...) | Trong Stored Procedure `usp_Vietnam_MaterialFOQcDetail_get`, số lượng mẫu (`SampleQty`) đang bị khởi tạo cứng là **`20`** hoặc **`50`** mẫu. | **Chưa cấu hình động** | Hệ thống chưa tự động điều chỉnh số mẫu test phá hủy về `6` mẫu theo Lot Size. QC hiện phải điều chỉnh thủ công hoặc nhập phế bổ sung bên ngoài. |
| **Điều chỉnh số lượng Lot `FVVQK113R825702`** trong thùng từ 140 về 135 (Sheet 1) | Mã Lot `FVVQK113R825702` và các Barcode thùng liên quan (`VVT_HELA_IN_BOX_260424_0083` -> `0091`) không tồn tại trong DB hiện tại. | **Không tìm thấy** | Đây là dữ liệu cũ từ tháng 04/2024. Có thể đã được đóng/lưu trữ lịch sử hoặc thuộc phân hệ của nhà máy khác. |
| **Cấu hình Lot Size cho các model khác** (1320, 1325, 1346, 1625, VPC...) | Các thông số đóng gói của các size này đã tồn tại trong `STB_PackingStandard`. | **Đã cover một phần** | Cấu hình quy mô Lot sản xuất được kiểm soát tại màn hình tạo PO/kế hoạch ngày (**B310**/**B450**). |

#### Chi tiết cấu hình quy mô Lot No sản xuất & Test phá hủy (Bắc Giang 1)
Dưới đây là bảng tổng hợp chi tiết cấu hình Lot Size, phương pháp sấy (Normal drying vs. Infrared drying), số lượng mẫu test phá hủy và thông số định mức cuộn nguyên liệu cho các model:

| Model | Lot Size Trước | Sấy Trước | Lot Size Sau | Sấy Sau | Quy cách đóng gói | Số mẫu phá hủy trước | Số mẫu phá hủy sau | Đặc tính cuộn nguyên liệu (Foil/Roll Specs) |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **1320** | 1280 | Thường | 2000 / 4000 | Hồng ngoại | 2400 (1 máy 2 khay x 1k) | 21 / 63 | 13 / 39 (test 6) | 1 roll nhỏ = 400m / 167mm * 0.95 * 1000 = 2,275 pcs |
| **1325** | 1280 | Thường | 1700 / 3400 | Hồng ngoại | 2400 (1 máy 2 khay x 850) | 21 / 63 | 15 / 45 (test 6) | 1 roll nhỏ = 400m / 179mm * 0.95 * 1000 = 2,122 pcs |
| **1346** | 600 | Thường | 800 / 1600 | Hồng ngoại | 1200 (1 máy 2 khay x 400) | 17 / 51 | 12 / 36 (test 6) | 1 small roll = 400m / 185mm * 0.95 * 1000 = 2,054 pcs |
| **1625** | 900 | Thường | 1400 / 2400 | Hồng ngoại | 1400 (1 máy 2 khay x 700) | 20 / 60 | 13 / 39 (test 6) | Giữ nguyên |
| **1840** | 500 | Thường | 1000 / 2000 | Hồng ngoại | Thường: 500, Hela: 640 | 36 / 108 | 18 / 54 (test 6) | 1 small roll = 400m / 387mm * 0.95 * 1000 = 981 pcs |
| **1859** | 300 | Thường | 900 | Thường | 1 máy sấy 3 ngăn | - | - (test 6) | 1 small roll = 400m / 338mm * 0.95 * 1000 = 1,124 pcs |
| **VPC 0820** | 3000 | Thường | 3000 | Thường | 1 máy sấy 3 ngăn | - | - (test 6) | - |
| **VPC 0825** | 3000 | Thường | 3000 | Thường | 1 máy sấy 3 ngăn | - | - (test 6) | - |
| **VPC 1030** | 2000 | Thường | 2000 / 3000 | Thường | 1 máy sấy 3 ngăn | - | - (test 6) | 1 small roll = 400m / 165mm * 0.95 * 1000 = 2,303 pcs |
| **VPC 1040** | 2000 | Thường | 2000 / 3000 | Thường | 1 máy sấy 3 ngăn | - | - (test 6) | 1 small roll = 400m / 205mm * 0.95 * 1000 = 1,853 pcs |
| **VPC 1325** | 1000 | Thường | 3000 | Thường | 1 máy sấy 3 ngăn | - | - (test 6) | 1 small roll = 400m / 295mm * 0.95 * 1000 = 1,288 pcs |
| **VPC 1335** | 1000 | Thường | 3000 | Thường | 1 máy sấy 3 ngăn | - | - (test 6) | 1 small roll = 400m / 295mm * 0.95 * 1000 = 1,288 pcs |
| **2245** | 430 | Thường | 1290 | Thường | - | 10.46 | 3.48 (test 2) | 1 small roll = 400m / 575mm * 0.95 * 1000 = 660 pcs |
| **2570** | 300 | Thường | 900 | Thường | - | 8.33 | 2.77 (test 2) | 1 small roll = 400m / 575mm * 0.95 * 1000 = 660 pcs |
| **3562** | 179 | Thường | 537 / 1074 | Thường | 600 (1 ngăn 6 khay, 2 lot) | 50 | 17 (test 2) | 1 small roll = 400m / 1520mm * 0.95 * 1000 = 250 pcs |
| **3582** | 179 | Thường | 358 / 716 / 1074 | Thường | 600 (1 ngăn 4 khay, 2 lot) | 16 | 8 (test 2) | 1 small roll = 400m / 1520mm * 0.95 * 1000 = 250 pcs |
| **35105**| 179 | Thường | 358 / 716 / 1074 | Thường | 600 (1 ngăn 4 khay, 2 lot) | 16 | 8 (test 2) | 1 small roll = 400m / 1520mm * 0.95 * 1000 = 250 pcs |

---

### 2.2 File `File báo cáo chỉnh sửa lỗi hệ thống ...xlsx` (⚠️ ĐÃ COVER ĐẦY ĐỦ 100%)

Toàn bộ các yêu cầu chỉnh sửa danh mục mã lỗi hiển thị trên màn hình **B530** (Nhập sản lượng công đoạn) tại nhà máy Bắc Giang (BG) đã được triển khai hoàn chỉnh. Chi tiết ma trận mã lỗi thay đổi theo từng công đoạn:

| Công đoạn | Trạng thái thay đổi | Mã lỗi | Tên lỗi trên hệ thống | Ghi chú từ nhà máy |
| :--- | :--- | :--- | :--- | :--- |
| **Winding** (Cuốn) | ❌ **Vô hiệu hóa** (Delete) | `V-22_CC_BG` | Winding_NG kích thước điện cực_Electrode NG | Lỗi cũ/trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-22_X12_BG` | Winding_Kiểm tra sample_Sample NG | Lỗi mẫu |
| | ❌ **Vô hiệu hóa** (Delete) | `V-22_Z03_BG` | Winding_NG lẫn băng dính đỏ_Red tape mixed | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-22_Z04_BG` | Winding_NG vết dập_점철부손상 | Lỗi trùng |
| | Add new | `V-22_BM_BG` | Winding_Xocha đen đầu ,đáy _The product has black marks on the top and bottom | Thêm mới thực tế |
| **Rubber/Riveting** (Lắp cao su/Dập tancha) | ❌ **Vô hiệu hóa** (Delete) | `V-23_02_BG` | Rubber_Test chức năng đo short_NG short test | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-23_2DR_BG` | Rubber/riveting_Rơi hàng trong máy_Drop defect | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-23_NE1_BG` | Rubber_NG short_NG short | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-23_NE2_BG` | Rubber_Rơi xô cha trước chèn cao su_Drop defect before rubber insert | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-23_QQ_BG` | Rubber_Bóc tách kiểm tra_Decap to check | Lỗi mẫu |
| | ❌ **Vô hiệu hóa** (Delete) | `V-23_XZ2_BG` | Riveting_ Thiếu vòng đệm_Lack washer | Sửa thành mã chung |
| | ❌ **Vô hiệu hóa** (Delete) | `V-23_X12_BG` | Rubber_Kiểm tra sample_Sample NG | Lỗi mẫu |
| | ❌ **Vô hiệu hóa** (Delete) | `V-24_2RY_BG` | Riveting_NG đo short_Short check voltage | Lỗi trùng |
| | Add new | `V-23_DV_BG` | Rubber/riveting_Dập vỡ Tancha pan_ATL bent or broke when stamped | Thêm mới thực tế |
| | Add new | `V-23_RD_BG` | Rubber/riveting_Rách đáy xocha (rách giấy) khi đưa vào vỏ nhôm | Thêm mới thực tế |
| | Add new | `V-23_XZ3_BG` | Riveting_Riveting_Thiếu,thừa vòng đệm_Insufficient or excessive gasket | Thêm mới thực tế |
| **Curling** (Bo miệng/Rửa) | ❌ **Vô hiệu hóa** (Delete) | `V-24_NE4_BG` | Curling_Cong chân tancha trước curling_Terminal lead it bent | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-24_22CT_BG` | Curling_Cong chân tancha_Terminal lead it bent | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-24_2CT_BG` | Curling_Cong chân tancha_Terminal lead it bent | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-24_2DR_BG` | Curling_Rơi xô cha khi chèn cao su_Xocha drop when insert rubber | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-24_5VV_BG` | Curling_Tràn dịch lỗ cao su_Leakage at rubber hold | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-24_NE22_BG` | Curling_Cong chân tancha trước curling_Terminal lead it bent | Lỗi trùng |
| | Add new | `V-24_NE6_BG` | Curling_NG thừa, thiếu cân nặng_Overweight or underweight | Thêm mới thực tế |
| | Add new | `V-24_NE7_BG` | Curling_ Xước chân tancha_Lead terminal is Scrash | Thêm mới thực tế |
| | Add new | `V-24_NE8_BG` | Curling_Lỗi mẻ miệng curling_Deformation around the mouth of the product | Thêm mới thực tế |
| **Sleeving** (Bọc vỏ) | ❌ **Vô hiệu hóa** (Delete) | `V-25_01_BG` | VISUAL MACHINE REPAIR_VISUAL SUA MAY | Lỗi bảo trì |
| | ❌ **Vô hiệu hóa** (Delete) | `V-25_2CT_BG` | SLEEVING_리드꼬임불량_SLEEVING_LỖI>>> | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-25_X03_BG` | SLEEVING_셋업검증_KIỂM TRA SETUP Máy | Lỗi setup |
| | ❌ **Vô hiệu hóa** (Delete) | `V-25_X12_BG` | SLEEVING_샘플_SLEEVING_MẪU | Lỗi mẫu |
| **Ngoại quan** (QC/OQC) | ❌ **Vô hiệu hóa** (Delete) | `V-27_ZC_BG` | Ngoại quan_NG thiếu cân nặng_Product weight under spec | Đưa về Curling |
| | ❌ **Vô hiệu hóa** (Delete) | `V-27_ZD_BG` | Ngoại quan_NG thừa cân nặng_Product weight out spec | Đưa về Curling |
| | ❌ **Vô hiệu hóa** (Delete) | `V-27_4GV_BG` | Ngoại quan_NG ESR_NG ESR | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-27_5VI_BG` | Ngoại quan_Ngược cực_Reverse polarity | Lỗi trùng |
| | ❌ **Vô hiệu hóa** (Delete) | `V-27_XP1_BG` | Ngoại quan_Cong chân, xước chân_Lead terminal is Scrash | Đưa về Curling |
| | ❌ **Vô hiệu hóa** (Delete) | `V-27_RELY_BG` | Ngoại quan_QC kiểm tra_QC inspect | Lỗi mẫu |

*Giao diện popup lỗi màn B530 load động qua stored procedure `usp_DefectInfo_popup_B530` đã tự động cập nhật danh sách mới.*

---

## 3. Script SQL Kiểm Chứng Thực Tế (Audit Queries)

Dưới đây là các câu lệnh SQL đã dùng để truy vấn và kiểm tra chéo dữ liệu trên Server:

```sql
-- 1. Kiểm tra cấu hình đóng gói của các Model/Size trong STB_PackingStandard
SELECT MaterialTypeCode, Size, Voltage, Farad, VinylBagQty, InnerBoxQty, OutBoxQty 
FROM STB_PackingStandard 
WHERE Size IN ('1320', '1325', '1346', '1625', '1840')
ORDER BY Size;
-- Kết quả: Không tìm thấy dòng nào cho Size '1840'.

-- 2. Kiểm tra trạng thái của các mã lỗi đã disable và thêm mới
SELECT DefectCode, BasicDefectName, DefectGroupCode, IsUsed, ChangeUserID, ChangeDateTime
FROM STB_DefectInfo
WHERE DefectCode IN (
    -- Các mã mới thêm (phải có IsUsed = 1)
    'V-22_BM_BG', 'V-23_DV_BG', 'V-23_RD_BG', 'V-23_XZ3_BG', 'V-24_NE6_BG', 'V-24_NE7_BG', 'V-24_NE8_BG',
    -- Một số mã tiêu biểu bị xóa (phải có IsUsed = 0)
    'V-22_CC_BG', 'V-23_02_BG', 'V-24_2CT_BG', 'V-25_01_BG', 'V-27_ZC_BG'
)
ORDER BY IsUsed DESC, DefectCode;
```

---

## 4. Đề Xuất Khắc Phục Gaps (Next Action Plan)

### Bước 1: Khai báo tiêu chuẩn đóng gói cho size `1840`
Cần thực hiện câu lệnh chèn dữ liệu cấu hình đóng gói cho Model `1840` (hỏi ý kiến bộ phận sản xuất/kế hoạch trước khi chạy trên Production):
```sql
-- Chèn tiêu chuẩn đóng gói Model 1840 (CEL = Cell Line)
INSERT INTO STB_PackingStandard (
    MaterialTypeCode, Size, Voltage, Farad, 
    VinylBagQty, InnerBoxQty, OutBoxQty, 
    CreateDateTime, CreateUserID
)
VALUES (
    'FERT', 
    '1840', 
    0, 0, 
    0, -- Quy cách túi nilon (nếu không dùng thì để 0)
    500, -- Hộp nhỏ (VinylBagQty/InnerBoxQty) - Thường: 500
    1000, -- Thùng to (OutBoxQty) 
    GETDATE(), 
    'vinaadmin'
);
```
*(Lưu ý: Đối với tem Hela đóng gói đặc biệt `640ea`, cần kiểm tra xem có dùng PO/quy trình in riêng không vì trường OutBoxQty chỉ nhận 1 giá trị tiêu chuẩn).*

### Bước 2: Tự động hóa quy trình QC cho Lot Size tăng
Nếu bộ phận QC muốn số lượng mẫu kiểm tra tự động giới hạn ở mức `6` mẫu test hủy thay vì `20` hay `50` như hiện tại, cần chỉnh sửa stored procedure `usp_Vietnam_MaterialFOQcDetail_get` để bổ sung logic phân nhánh `SampleQty` động theo `MaterialCode` và `LotSize`.
