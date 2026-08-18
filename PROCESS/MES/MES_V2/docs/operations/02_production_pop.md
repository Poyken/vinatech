# ⚡ 02 — POP Production Execution & Routing

> **Quy tắc vàng POP:**
> $$\text{POP Sản Xuất} = \text{B530} = \text{B540 (Scan NVL)} + \text{B523 (Đóng gói)} + \text{C321 (Nhập kho TP)}$$

---

## 1. 🏭 Quy Trình Sản Xuất Cell Line Chi Tiết

```
[B310] Tạo Lệnh Sản Xuất (PO Tháng)
    ↓
[B450] Lập Kế Hoạch Ngày ───▶ Tích "IsFixed = 1" ───▶ Bấm "Tạo Lot" (STB_SetInfo) ───▶ In Tem
    ↓
[B540] Quét NVL & Thẻ Công Đoạn (V22 Sấy ➔ V23 Lắp cao su ➔ V24 Cuộn ➔ V25 Bọc vỏ)
    ↓
[B597] Kiểm Tra NVL Đầu Vào (Check cờ HOLD, Expiry, BOM)
    ↓
[B530] Chốt Sản Lượng Công Đoạn ───▶ Bắt buộc chọn Status = "Making"
    ↓
[B523] Đóng Gói Thùng Hàng & In Tem Label
    ↓
[C321] Nhập Kho Thành Phẩm (Finish Goods Stock In)
```

---

## 2. ⚠️ Các Bẫy Kỹ Thuật Khi Vận Hành Sản Xuất

1. **B450 Không Tạo Được Lot:** Cột `IsFixed` chưa được tích chọn. SP `usp_DoFixDayProdPlan` chặn sinh serial nếu chưa chốt kế hoạch.
2. **B530 Kẹt Công Đoạn V25:** Khi chốt sản lượng tại B530, nếu cột Status không chọn `Making`, SP `usp_DoProcessProdRouteHistForCalc_SmartApp_VNT` sẽ chặn không cho ghi nhận sang công đoạn tiếp theo.
3. **B540 ProdQtyFinishYN:** Không thể tích chọn trực tiếp trên UI B540; hệ thống tự động cập nhật cờ này khi hoàn tất chốt sản lượng tại B530.
4. **JobDate Ca Đêm:** Khi sản xuất ca 3 (sau 00:00), `JobDate` của Lot phải giữ nguyên ngày làm việc của ca để không bị lệch báo cáo sản lượng trên B782.
