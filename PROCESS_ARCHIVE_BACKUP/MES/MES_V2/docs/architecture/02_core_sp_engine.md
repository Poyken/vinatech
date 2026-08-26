# ⚙️ 02 — Core Stored Procedure Engine (Live Execution Map)

Hệ thống MES NAIS xử lý giao dịch sản xuất thông qua 4 Stored Procedure cốt lõi đóng vai trò là "trái tim" của hệ thống:

---

## 1. 💓 4 Stored Procedure Cốt Lõi

| # | Stored Procedure | Dung lượng | Chức Năng Chính | Màn Hình Gọi |
|---|---|---|---|---|
| 1 | `usp_DoProcessProdRouteHist` | 406 dòng | **Tim đập** — Ghi nhận sản lượng mỗi khi OP quét barcode tại từng công đoạn | B530, B802, SmartApp |
| 2 | `usp_DoProcessProdGIMaterialByBOM` | 268 dòng | **Backflush BOM** — Tự động trừ tồn kho NVL theo định mức BOM cấu hình | SP #1 gọi |
| 3 | `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` | 22K ký tự | **Variant mở rộng** — Kiểm tra 7 cổng chặn (Gate time 20p, Takt, V-33 cascade) | SmartApp / B530 |
| 4 | `usp_Vietnam_DoProcessProdPacking_VVT` | 217 dòng | **Đóng gói** — Xử lý gộp box, sinh BoxID và trừ kho thành phẩm | B523, HN523 |

---

## 2. 🚦 7 Cổng Chặn (Validation Gates) Trong B530

Khi công nhân quét sản phẩm tại B530 hoặc SmartApp, SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` sẽ lần lượt duyệt qua 7 cổng chặn an toàn:

```
[QUÉT BARCODE TẠI B530]
        │
        ├──▶ [GATE 1] Điện cực: Kiểm tra cuộn slitting đã qua QC chưa (usp_CheckInputElectrodeInputForCodeProduct)
        ├──▶ [GATE 2] NVL: Kiểm tra nguyên liệu đầu vào đã đủ thẻ chưa (V-23 Lắp cao su phải quét NVL trước)
        ├──▶ [GATE 3] Thứ tự Route: Kiểm tra công đoạn trước đã hoàn thành (CompleteRoute = 'Y') chưa
        ├──▶ [GATE 4] Aging Gate Time: Kiểm tra thời gian ủ Aging đủ tiêu chuẩn (tối thiểu 20 phút / 72 giờ)
        ├──▶ [GATE 5] OQC Status: Kiểm tra cờ phế phẩm / cờ khóa OQC
        ├──▶ [GATE 6] Trùng lặp: Kiểm tra barcode đã chốt sản lượng tại công đoạn này chưa
        └──▶ [GATE 7] Backflush: Trừ tồn kho NVL trong STB_MaterialLotInfo và ghi nhận STB_MaterialDocDetail
```
