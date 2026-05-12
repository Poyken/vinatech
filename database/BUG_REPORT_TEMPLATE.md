# Mẫu báo bug / trace MES (dán vào chat)

Điền từng mục; để trống thì ghi `N/A`. Càng đủ thông tin, trace càng nhanh (theo `KB_05_TRACE_BUG_METHODOLOGY.md`).

---

## 1. Bề mặt
- **Màn hình / TCode:** (VD: B597, HN523, F330…)
- **Thao tác:** (bấm nút nào, scan gì, lưu gì)
- **Thông báo lỗi (copy nguyên văn):** 

## 2. Định danh (ít nhất một dòng có giá trị)
- **Barcode sản phẩm:** 
- **ControlNo:** 
- **LotID (ML…):** 
- **MaterialDocNo:** 
- **PONo / DayPlanNo:** 

## 3. Thời gian & môi trường
- **Thời điểm xảy ra (VN):** (ngày + giờ, timezone nếu cần)
- **Môi trường:** Production / UAT / khác
- **Được phép gợi ý SELECT trên DB:** Có / Không (nếu Không — chỉ phân tích tài liệu)

## 4. Bối cảnh thêm (tuỳ chọn)
- **Line / WorkCenter:** (VD: VVBGC-02, VVT_F1…)
- **MaterialCode / Model:** 
- **Đã thử gì:** 
- **Ảnh chụp / file log:** (đính kèm hoặc mô tả)

---

Sau khi gửi, AI sẽ ưu tiên: `KB_INDEX` → KB chuyên đề → `Vinatech_MES_Complete_DataFlow.md` → template SQL trong `KB_05`.
