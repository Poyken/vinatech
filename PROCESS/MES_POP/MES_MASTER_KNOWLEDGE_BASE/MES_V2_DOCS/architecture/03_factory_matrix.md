# 🏭 03 — Factory & WorkCenter Mapping Matrix

> Hệ thống MES Vinatech quản trị 6 cơ sở sản xuất trên cùng một CSDL `SmartFactoryV2`, phân biệt thông qua `CompanyCode` (`VNT` / `VVT`) và `WorkCenterCode`.

---

## 1. 🗺️ Bản Đồ Cơ Sở Sản Xuất (WorkCenter Mapping)

| WorkCenter | Company | Nhà Máy | Quy Mô PO | Barcode Prefix | Đặc Thù Vận Hành |
|---|---|---|---|---|---|
| **VVT_F1** | VVT | **Bắc Ninh** (Chính) | 15,944 PO (71%) | `VV...` | Cell Line chính, quy trình V22 $\rightarrow$ V28 |
| **VNT_F1** | VNT | **Bắc Ninh** (Legacy) | 3,081 PO | `VJ...` | Cell Line cũ |
| **VNT_F2** | VNT | **Electrode / MEA** | 1,004 PO | `MEA...` | Trạm Mixing, Coating, Rollpress, Slitting |
| **VVT_F2** | VVT | **Bắc Giang 1** | 890 PO | `VV...` | Cell/Module BG1 |
| **VVT_F3** | VVT | **Hà Nam** (Chính) | 1,125 PO | `VV...` | 83 màn hình riêng prefix `HN`, công đoạn `VE01` $\rightarrow$ `VE18` |
| **VVT_F4** | VVT | **Bắc Giang 2** | 105 PO | `K164...` | Module Line, màn hình K-series (`K101`, `K109`, `K361`) |
| **VNT_F5** | VNT | **Hưng Yên** | 39 PO | `VNE...` | VinaEnesol, Menu `D000`, tem `D100/D110` |

---

## 2. 🔀 Định Dạng Barcode & Prefix

* **Bắc Ninh (VVT_F1):** Định dạng 14 ký tự: `VV` + `Năm` + `Tháng` + `Loại hàng` + `Serial` (Ví dụ: `VVQL033R07279S`, `VVNP263R033573`).
* **Bắc Giang 2 (VVT_F4):** Định dạng Module 17 ký tự: `K164` + `DateCode` + `Serial` (Ví dụ: `K16418106262500772`).
* **Điện Cực (VNT_F2):** Barcode cuộn cực: `VV` + `Mã PO` + `E` + `Số cuộn` (Ví dụ: `VVQO2020001E36`).
* **Hưng Yên (VVT_F5):** Barcode ghép Box VinaEnesol định dạng `D100`.

---

## 3. 🗺️ Bảng Ánh Xạ WBS Nhà Máy Hưng Yên (VinaEnesol — KB_07_04)

| Mã Công Đoạn HY | Tên Công Đoạn | Công Đoạn Gốc BN/BG | Mã Line Tương Ứng | Kho NVL Đầu Vào |
|---|---|---|---|---|
| **V-22_HY** | Sấy chân không HY | V-22 (Sấy) | `VVHYC-01` | `ROH_HY_WH` |
| **V-23_HY** | Lắp cao su HY | V-23 (Lắp cao su) | `VVHYC-01` | `ROH_HY_WH` |
| **V-24_HY** | Cuộn cực HY | V-24 (Cuộn cực) | `VVHYC-01` | `ROH_HY_WH` |
| **V-25_HY** | Bọc vỏ nhôm HY | V-25 (Bọc vỏ) | `VVHYC-01` | `ROH_HY_WH` |
| **V-26_HY** | Lão hóa Aging HY | V-26 (Aging 24h) | `VVHYC-01` | `VNE_PRODUCT_WH` |
| **V-27_HY** | Ngoại quan / Bending | V-27 (Ngoại quan) | `VVHYC-01` | `VNE_PRODUCT_WH` |
| **V-28_HY** | Đóng gói HY | V-28 (Đóng gói) | `VVHYC-01` | `FGT_HY_WH` |
