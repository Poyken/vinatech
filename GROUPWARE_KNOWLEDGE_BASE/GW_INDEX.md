# 🗂️ GROUPWARE — Knowledge Base Index

> **Cập nhật:** 2026-05-18 | **Nguồn:** extracted_text_utf8.txt + GROUPWARE Purchase Manual
> **Cách dùng:** Đọc file INDEX này trước, sau đó mở file GW chuyên biệt theo nhóm chức năng.

---

## 📋 Danh sách file KB chuyên biệt

| File | Nội dung | Chức năng chính |
|------|----------|-----------------|
| [GW_01_DANG_NHAP.md](GW_01_DANG_NHAP.md) | Đăng nhập, mật khẩu, chọn công ty | Login, Reset password |
| [GW_02_MUA_HANG.md](GW_02_MUA_HANG.md) | Luồng mua hàng đầy đủ: PO → Arrival → IQC → Receiving → Closing | Purchase Order, Arrival, Receiving, Return, Resolution |
| [GW_03_KE_HOACH_SX.md](GW_03_KE_HOACH_SX.md) | Tạo PO tháng, kế hoạch ngày, tạo Lot | Month Production Plan, B310, B450 |
| [GW_04_MASTER_DATA.md](GW_04_MASTER_DATA.md) | Đăng ký mã code, BOM, nhà thầu/khách hàng | Item Registration, BOM, Partner Management |
| [GW_05_HANH_CHINH.md](GW_05_HANH_CHINH.md) | Công tác, ngày nghỉ, tuyển dụng, nghỉ việc, phê duyệt | Business Trip, Holiday Work, HR, Draft Document |
| [GW_06_THANH_TOAN.md](GW_06_THANH_TOAN.md) | Yêu cầu thanh toán, chọn tài khoản, phê duyệt chi phí | Disbursement Document |
| [GW_07_KHO_THANH_PHAM.md](GW_07_KHO_THANH_PHAM.md) | Xuất kho tạm, in tem pallet, xuất lên xe | Finished Good Warehouse, B750, B752 |

---

## ⚡ Tra cứu nhanh theo tình huống

| Tình huống | File & Mục |
|-----------|------------|
| Không đăng nhập được Groupware | GW_01 § 1 |
| Không nhớ mật khẩu | GW_01 § 2 |
| Yêu cầu mua hàng (Expense Report) | GW_02 § 1 |
| Tạo đơn mua hàng (PO) mới | GW_02 § 2 |
| Làm Arrival Confirmation | GW_02 § 3 |
| Không nhập được kho F330 | GW_02 § 3 (chưa duyệt Arrival?) |
| Làm Receiving Confirmation | GW_02 § 4 |
| Không làm được Receiving | GW_02 § 4 (C220 đã PASS chưa?) |
| Trả hàng về nhà cung cấp | GW_02 § 5 |
| Xóa đơn mua hàng bị sai | GW_02 § 6 |
| Đóng sổ thanh toán (Purchase Resolution) | GW_02 § 7 |
| Tạo PO theo tháng | GW_03 § 1 |
| PO không hiện trên MES (B310/B450) | GW_03 § 2 |
| Tạo kế hoạch ngày + Lot | GW_03 § 3 |
| Đăng ký mã vật tư mới (Cell/Module/NVL) | GW_04 § 1 |
| Cập nhật thông tin mã code | GW_04 § 2 |
| Tạo/sửa BOM | GW_04 § 3 |
| Đăng ký nhà thầu/khách hàng mới | GW_04 § 4 |
| Form đi công tác | GW_05 § 1 |
| Báo cáo công tác về | GW_05 § 2 |
| Thay đổi thông tin công tác (Trip Change) | GW_05 § 3 |
| Đăng ký đi làm ngày nghỉ/lễ | GW_05 § 4 |
| Yêu cầu tuyển dụng (Emp Request) | GW_05 § 5 |
| Form nghỉ việc (Employee Retire) | GW_05 § 6 |
| Phê duyệt văn bản nội bộ (Draft) | GW_05 § 7 |
| Làm yêu cầu thanh toán | GW_06 § 1 |
| Duyệt yêu cầu thanh toán | GW_06 § 2 |
| Xuất kho thành phẩm | GW_07 § 1 |
| In tem pallet | GW_07 § 2 |

---

## 🔗 Luồng tích hợp Groupware ↔ MES

```
[GROUPWARE]                          [MES]
Purchase Order → Approved
        ↓
Arrival Confirmation → Approved ──→ F330 (Nhập kho NVL, in tem)
        ↓
                              ──→ C220 (IQC kiểm tra) → PASS
        ↓
Receiving Confirmation ←──────────── Sau khi C220 PASS
        ↓
Purchase Resolution (Đóng sổ)

Month Production Plan → Approved ──→ B310 (PO trên MES)
        ↓
Daily Plan (Kế hoạch ngày) ───────→ B450 (Tạo Lot, in tem)
        ↓
                              ──→ B540 → B597 → B530 → B523
```

> **Lưu ý quan trọng:** BOM Version phải chọn **2001** (mã BOM của Việt Nam). Không chọn version khác.

---

## ⚠️ Các lỗi phổ biến & Checklist

| Lỗi | Nguyên nhân | Xử lý |
|-----|-------------|-------|
| PO không hiện trên B310 | PO chưa được "Xác nhận lô hàng" hoặc BOM version sai | Kiểm tra trạng thái PO trên GW, đổi sang "Sản xuất" |
| Không nhập được F330 | Arrival Confirmation chưa duyệt | Hỏi bộ phận Mua hàng duyệt trước |
| Không làm Receiving Confirmation | C220 IQC chưa Pass | Đội QC làm C220 Pass trước |
| Không đăng nhập được | Sai mật khẩu / sai company | Chọn đúng "Vinatech Vina Co.,Ltd." |
| LOT hàng bị trả về kho lỗi | Đã làm Return Product Document | Kiểm tra trạng thái LOT trong MES |

---

*Cập nhật: 2026-05-25 | Tổng hợp từ: [GROUPWARE] Purchase Manual.pptx + Comprehensive_Groupware_Report.md*
