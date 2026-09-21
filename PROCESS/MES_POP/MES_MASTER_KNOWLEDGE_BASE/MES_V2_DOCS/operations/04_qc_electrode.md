# 🔬 04 — Quality Control & Electrode Process

> **Phân hệ:** Quản lý chất lượng (IQC, PQC, OQC, FOQC) và dây chuyền sản xuất điện cực (Mixing $\rightarrow$ Coating $\rightarrow$ Rollpress $\rightarrow$ Slitting).

---

## 1. ⚡ Quy Trình Sản Xuất Điện Cực (Electrode Flow)

```
[Mixing (Trộn keo)] ──▶ [Coating (Tráng cực)] ──▶ [Rollpress (Cán nén)] ──▶ [Slitting (Cắt dải)]
                                                                               │
                                                                               ▼
                                                                STB_SlittingStock_VVT
                                                                • Cực dương: BY
                                                                • Cực âm: YP
```

* **Xóa lịch sử cắt Slitting thừa (B552):**
  ```sql
  BEGIN TRANSACTION;
  DELETE FROM STB_ElectrodeSlittingResult WHERE ElectrodeLotNumber = 'MÃ_LOT_ELECTRODE' AND Seq BETWEEN 10 AND 70;
  COMMIT TRANSACTION;
  ```

---

## 2. 🧪 Quy Trình Kiểm Tra Chất Lượng (QC Matrix)

1. **IQC (C220):** Kiểm tra NVL đầu vào sau khi tiếp nhận F330. Yêu cầu thủ kho bấm "Tạo tem" tại F330 trước để sinh `STB_MaterialDocLotInfo`, nếu không C220 sẽ không tìm thấy phiếu nhập.
2. **PQC (B597 / C443):** Quét kiểm tra NVL trước khi cho vào Line.
   * **Bẫy vỏ nhôm (AluCase):** Bảng `STB_AluCaseMapping_VVT` không tồn tại; logic kiểm tra vỏ nhôm nằm trong `usp_Vietnam_RawMaterialInputHist_uid`.
3. **OQC (C512 / C530):** Kiểm tra xuất xưởng thành phẩm.
   * Nếu Model mới không hiện ở C512: Kiểm tra cấu hình `OqcType` trong `STB_ModelBasicInfo` (A410).
   * Nhà máy Hà Nam: Nếu công đoạn bắt đầu từ `VE02` sẽ không hiển thị ở C512 theo thiết kế.
