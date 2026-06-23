# Clone 7 HY Screens — Deployment Scripts

## Thứ tự chạy (BẮT BUỘC)

```
01_register_hy_screens.sql     → STB_ScreenInfo (7 records)
02_clone_hy_layouts.sql        → STB_ScreenLayoutInfo (7 layouts, binary+XML)
03_clone_hy_screen_objects.sql → STB_ScreenObjects (~200 records)
04_grant_hy_permissions.sql    → STB_UserTypeBasicPermission (Admin)
```

## Hướng dẫn

1. Mở SSMS, kết nối đến `dbserver.hycap.co.kr,5398`
2. Chọn DB: `SmartFramework`
3. Chạy từng script theo thứ tự **01 → 02 → 03 → 04**
4. Mỗi script mặc định **ROLLBACK** → xem kết quả trước
5. Khi xác nhận OK → đổi `ROLLBACK` thành `COMMIT` → chạy lại

## Lưu ý quan trọng

- Script 02 nên chạy **trên server** hoặc qua kết nối ổn định (layouts lớn đến 2.7MB)
- Script 01 + 02 **PHẢI** chạy cùng session hoặc liên tiếp → tránh lỗi menu init
- Encoding: UTF-8 (scripts không chứa Korean variables)

## Screens đã có sẵn (KHÔNG cần tạo)

| TCode | Screen Name | Ghi chú |
|---|---|---|
| HY121 | QCInspectionGroupCode_HY | Simplified QC Group |
| C121_HY | QcInspectionGroupItem_HY | Full QC Group + Item |
| C122_HY | MaterialInspectionCriteria_HY | Material QC Criteria |

## Screens mới (7 screens)

| TCode | Gốc | Mô tả |
|---|---|---|
| HY220 | C220 | IQC Confirmation |
| HY310 | B310 | Create PO |
| HY442 | B442 | Daily Plan Electrode |
| HY470 | B470 | Electrode Process Steps |
| HY552 | B552 | Electrode Measure Result |
| HY802 | B802 | Electrode Report |
| HY460 | C460 | Electrode QC Inspection |

## Prerequisite: Electrode Lines

Hưng Yên hiện chưa có Electrode production lines.
Cần tạo thêm `STB_LineInfo` records (ví dụ: `VVHYEL-01`) trước khi các màn hình electrode hoạt động.
