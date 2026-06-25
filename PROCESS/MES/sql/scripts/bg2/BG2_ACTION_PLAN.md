# BG2 Action Plan — Các Bước Vận Hành Tốt Hơn

> **Ngày:** 2026-06-24 | **Priority:** Theo thứ tự từ trên xuống

---

## 🔴 P0 — Fix Ngay (Ảnh hưởng data production)

### 1. Fix duplicate trong STB_RepairInfor

**Vấn đề:** 97% records (2,253/2,322) bị duplicate do bug trong `usp_AddRepairInfor_BG2`.

**Bước 1:** Chạy script dedup trên SSMS (file: `fix_repair_dedup.sql`)
**Bước 2:** Fix SP `usp_AddRepairInfor_BG2` — thêm check trùng trước INSERT

Script dedup: xem file `fix_repair_dedup.sql` cùng thư mục.

### 2. Fix hardcoded Route Codes trong SP packing

**Vấn đề:** `usp_Vietnam_GetProdPackingForBarcodeForBacGiang2` hardcode `VP07, VP18, VP12`.
Nordex (ND series) hoàn toàn bị bỏ qua.

**Fix:** Thay hardcode bằng query lấy routes từ `STB_ProductionOrderRouting` hoặc config.

---

## 🟡 P1 — Cải Thiện (Trong tuần)

### 3. Thống nhất naming convention

**Hiện tại:** Mix 4 kiểu: `BG2`, `VVTF4`, `BacGiang2`, `VVT_F4`

**Đề xuất chuẩn:** Dùng `BG2` cho tên SP ngắn, `VVT_F4` cho WorkCenterCode.
Không cần rename ngay — nhưng SP mới phải theo chuẩn.

### 4. Review commented-out code

**SP:** `usp_CompleteRouteFinalForBacGiang2` line 46-96
- Block INSERT vào `STB_MaterialQcInfo` bị comment ra
- Xác nhận: intentional hay quên bỏ comment?
- Nếu intentional → thêm comment giải thích
- Nếu cần → bỏ comment, enable lại

### 5. Fix typos trong error messages

- `usp_CompleteRouteFinalForBacGiang2`: "rổi" → "rồi", "côn đoạn" → "công đoạn"
- Ảnh hưởng UX — user thấy lỗi chính tả khi dùng

---

## 🟢 P2 — Dài Hạn (Khi có thời gian)

### 6. Refactor SP quá lớn

- `usp_VN_ShowAllFinishGoodMES_BG2` (129K) → chia thành sub-SPs
- Không cấp bách nhưng impossible to debug nếu có bug

### 7. Thêm WITH(NOLOCK) cho SP repair

- `usp_AddRepairInfor_BG2`: thiếu NOLOCK ở SELECT
- `usp_CompleteRouteFinalForBacGiang2`: thiếu NOLOCK ở SELECT trước UPDATE
- Không critical nhưng có thể gây lock trên production

### 8. Cleanup backup tables

- 14 bảng `STB_DefectRepairInfo_*` (từ 2020 đến 2026)
- Xác nhận còn cần không → archive hoặc xóa giảm clutter

---

## Checklist Theo Dõi

- [ ] P0-1: Fix duplicate STB_RepairInfor
- [ ] P0-2: Fix hardcoded routes VP07/VP12/VP18
- [ ] P1-3: Thống nhất naming cho SP mới
- [ ] P1-4: Review commented-out code CompleteRouteFinal
- [ ] P1-5: Fix typos error messages
- [ ] P2-6: Refactor SP 129K
- [ ] P2-7: Thêm NOLOCK
- [ ] P2-8: Cleanup backup tables
