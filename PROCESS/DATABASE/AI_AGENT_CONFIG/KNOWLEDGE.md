# 🧠 KNOWLEDGE CHEAT SHEET — HỆ SINH THÁI 15 CSDL VINATECH

## 1. Bản Đồ 3 Trụ Cột Doanh Nghiệp

| Trụ Cột | Các CSDL Thành Phần | Vai Trò Nghiệp Vụ Chính |
| :--- | :--- | :--- |
| **1. Groupware & Văn Phòng** | `VINATECH_GROUP`, `WCMS_STANDARD_NEW`, `streamdocs`, `VINATECH_SPREADSHEET`, `VINATECH_DATA_KSOX` | Phê duyệt 17 Form, sao kê ngân hàng FirmBanking, bảng tính Excel Online JSON, kiểm toán K-SOX. |
| **2. ERP Sổ Cái** | `NEOE` (ERP Douzone iU), `DZICUBE` (Bizbox Alpha), `erpdb` (Legacy NeoPlus) | Sổ cái tài chính, định mức BOM, Master Item, hạch toán tự động ABDOCU, lưu trữ lịch sử kế toán. |
| **3. Nhà Xưởng MES/POP** | `SmartFactoryV2`, `SmartFramework`, `VINATECH_POP`, `AndonDB`, `VINATECH_RESTFUL`, `VINATECH_WEBSOCKET`, `SmartFactoryIncubator` | Điều hành 2 nhà máy, Lot/Barcode, Routing, Kiosk MAC & PLC, Andon TV alert, SSO Token, R&D Cell testing. |

---

## 2. Bảng Tra Cứu Khóa Ngoại Trọng Yếu Giữa Các CSDL

```
[Groupware: VINA_DOCUMENT_POH]
       │ (NO_PO)
       ▼
[ERP Douzone: PU_POH / PU_POL]
       │ (CD_ITEM / NO_PO)
       ▼
[MES: STB_MaterialStock / STB_MaterialLotInfo]

───────────────────────────────────────────────

[Groupware: VINA_DOCUMENT_DAILY_PLAN]
       │ (DayPlanNo)
       ▼
[MES: STB_DayProdPlan]
       │ (DayPlanNo)
       ▼
[POP: VINA_EQUIPMENT_MAPPING] ──(Barcode)──► [MES: STB_SetInfo / STB_ProdRouteHist]

───────────────────────────────────────────────

[Groupware: VINA_DOCUMENT_PAYMENT]
       │ (DOCUMENT_SAVE_CODE)
       ▼
[Bizbox Alpha: ABDOCU / ABDOCU_D]
       │ (NO_DOCU)
       ▼
[ERP Douzone: FI_DOCU / FI_DOCU_D]

───────────────────────────────────────────────

[Ngân Hàng Shinhan/Woori/Vietin]
       │ (Sao kê tự động)
       ▼
[WCMS_STANDARD_NEW: WCMS_ACCOUNT_TRNX_LOG] ──(ERP_FLAG = 'Y')──► [ERP: FI_DOCU]
```

---

## 3. Các Bảng Lớn Nhất & Yêu Cầu Kỹ Thuật

- `SmartFactoryV2.dbo.STB_ProdRouteHist`: Hàng chục triệu dòng. **BẮT BUỘC** lọc `JobDate` hoặc `Barcode` + `WITH(NOLOCK)`.
- `NEOE.dbo.FI_DOCU_D`: Sổ chi tiết kế toán ERP (hàng triệu dòng). Bắt buộc lọc `CD_COMPANY` và `DT_DOCU`.
- `DZICUBE.dbo.ABDOCU_D`: Chi tiết chứng từ nháp. Bắt buộc lọc `CD_COMPANY` và `DT_DOCU`.
- `VINATECH_GROUP.dbo.VINA_DOCUMENT_SAVE`: Chứa nội dung HTML Rich-Text trong cột `DOCUMENT_SAVE_CONTENT` (`ntext`). **CẤM** SELECT cột này nếu không cần thiết để tránh tràn bộ nhớ.
