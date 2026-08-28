# 🛡️ SCREEN & STORED PROCEDURE MAPPING RULES (VINATECH MES)

## 1. NGUYÊN TẮC ĐỊNH VỊ MÀN HÌNH TỨC THÌ (IMMEDIATE SCREEN MAPPING)
Khi nhận Screen ID hoặc ảnh chụp giao diện từ User:
- **B530 (Nhập sản lượng công đoạn):** SP chính `usp_DoProcessProdRouteHist`, Bảng `STB_ProdRouteHist`.
- **B540 (Chốt sản lượng Cell Line):** SP chính `usp_DoProcessProdRouteHist`, chốt công đoạn cuối.
- **B523 (Gộp/Chia Box Cell):** Bảng `STB_DividePackaging`, `STB_MaterialLotInfo`.
- **B351 (Chuyển đổi Lot/Model):** Bảng `STB_LotChangeMaterialHistory`, `STB_SetInfo`.
- **HN523 / HN544 / HN555 (Hà Nam Packaging):** Tra cứu trực tiếp tại `KB_11_HANAM_FACTORY_SCREENS.md`.
- **F330 / F721 (Kho & Tồn kho WMS):** Bảng `STB_MaterialDocInfo`, `STB_MaterialLotInfo`.

## 2. QUY TẮC PULL & ĐỒNG BỘ SP
- Cấm sửa SP dựa trên trí nhớ cũ; luôn dùng `.\mes.ps1 sp <SP_Name>` để lấy định nghĩa mới nhất từ SQL Server.
- Sau khi phân tích xong, dọn dẹp SP tạm bằng `.\mes.ps1 sp -Clean`.
