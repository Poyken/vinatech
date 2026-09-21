---
name: vinatech-cross-system-query
description: Kỹ thuật truy vấn liên cơ sở dữ liệu (Cross-Database Join) an toàn giữa Groupware, ERP Douzone, và MES/POP.
---

# 🔗 Vinatech Cross-System Query Skill

Kỹ năng này hướng dẫn thiết lập các câu truy vấn liên CSDL kết nối 3 Trụ Cột của Vinatech mà không gây khóa hoặc nghẽn giao dịch.

## 1. Các Đường Dẫn Khóa Liên Hệ Thống (Cross-DB Keys)
- **PO Flow:** `VINATECH_GROUP.dbo.VINA_DOCUMENT_POH.NO_PO` ➔ `NEOE.dbo.PU_POH.NO_PO` ➔ `SmartFactoryV2.dbo.STB_MaterialLotInfo.PONo`
- **Plan Flow:** `VINATECH_GROUP.dbo.VINA_DOCUMENT_DAILY_PLAN.DOCUMENT_SAVE_CODE` ➔ `SmartFactoryV2.dbo.STB_DayProdPlan.DayPlanNo`
- **Accounting Flow:** `VINATECH_GROUP.dbo.VINA_DOCUMENT_PAYMENT.DOCUMENT_SAVE_CODE` ➔ `DZICUBE.dbo.ABDOCU.NO_DOCU` ➔ `NEOE.dbo.FI_DOCU.NO_DOCU`
- **POP Machine Flow:** `VINATECH_POP.dbo.VINA_EQUIPMENT_MAPPING.EQUIPMENT_ID` ➔ `SmartFactoryV2.dbo.STB_DayProdPlan.LineCode`

## 2. Kỹ Thuật Viết Truy Vấn An Toàn
```sql
-- Ví dụ: Đối chiếu đơn PO từ Groupware sang ERP và MES
SELECT TOP 20
    gw.NO_PO,
    gw.CD_PARTNER,
    erp.DT_PO,
    erp.AM_EXCH,
    mes.MaterialCode,
    mes.StockQty
FROM VINATECH_GROUP.dbo.VINA_DOCUMENT_POH gw WITH(NOLOCK)
LEFT JOIN NEOE.dbo.PU_POH erp WITH(NOLOCK) ON gw.NO_PO = erp.NO_PO
LEFT JOIN SmartFactoryV2.dbo.STB_MaterialStock mes WITH(NOLOCK) ON erp.CD_ITEM = mes.MaterialCode
WHERE gw.NO_PO = @TargetPO;
```

## 3. Quy Tắc Bắt Buộc
1. Không join trực tiếp 2 bảng giao dịch triệu dòng mà không có điều kiện `WHERE` theo ngày hoặc theo khóa chính.
2. Tất cả các bảng tham gia JOIN bắt buộc có `WITH(NOLOCK)`.
3. Chỉ SELECT các trường dữ liệu cần thiết phục vụ trả lời người dùng.
