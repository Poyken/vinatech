-- ==========================================================================================
-- Author:       Antigravity (AI Coding Assistant)
-- Create date:  2026-06-29
-- Description:  Dọn dẹp các stored procedure dư thừa, trùng lặp tên (khác biệt ký tự _) 
--               trên database SmartFactoryV2 của hệ thống MES.
--               Kịch bản này thực thi DROP 5 stored procedure đã xác định là dư thừa.
-- ==========================================================================================

USE SmartFactoryV2;
GO

-- 1. CẬP NHẬT CẤU HÌNH MÀN HÌNH (SmartFramework) & DROP SP CŨ
-- Chuyển hướng màn hình MaterialQcInspectionItem_HY sang gọi SP đúng chuẩn
BEGIN TRAN;

-- Xem cấu hình trước khi sửa
SELECT ScreenName, ObjectName, ObjectType 
FROM SmartFramework.dbo.STB_ScreenObjects WITH(NOLOCK)
WHERE ScreenName = 'MaterialQcInspectionItem_HY' AND ObjectType = 'SearchFunction';

-- Cập nhật cấu hình sang SP đúng chuẩn
UPDATE SmartFramework.dbo.STB_ScreenObjects
SET ObjectName = 'usp_MaterialQcInspectionItem_ByMaterial_HY_get'
WHERE ScreenName = 'MaterialQcInspectionItem_HY' AND ObjectType = 'SearchFunction';

-- Xem cấu hình sau khi sửa
SELECT ScreenName, ObjectName, ObjectType 
FROM SmartFramework.dbo.STB_ScreenObjects WITH(NOLOCK)
WHERE ScreenName = 'MaterialQcInspectionItem_HY' AND ObjectType = 'SearchFunction';

-- SAU KHI CHẠY THỬ MÀN HÌNH MỚI BẰNG LỆNH COMMIT TRAN:
-- Bạn có thể tiến hành DROP SP cũ bằng lệnh dưới đây:
/*
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_MaterialQcInspectionItemByMaterial_HY_get]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[usp_MaterialQcInspectionItemByMaterial_HY_get];
    PRINT 'SUCCESS: Dropped procedure [usp_MaterialQcInspectionItemByMaterial_HY_get]';
END
*/

-- NẾU THẤY ĐÚNG => COMMIT TRAN;
-- NẾU THẤY SAI => ROLLBACK TRAN;
GO

-- 2. DROP usp_ElectrodeMixStepInfoPowerBI_get (Thay bằng usp_ElectrodeMixStepInfo_PowerBI_get)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_ElectrodeMixStepInfoPowerBI_get]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[usp_ElectrodeMixStepInfoPowerBI_get];
    PRINT 'SUCCESS: Dropped procedure [usp_ElectrodeMixStepInfoPowerBI_get]';
END
ELSE
BEGIN
    PRINT 'INFO: Procedure [usp_ElectrodeMixStepInfoPowerBI_get] does not exist or was already dropped.';
END
GO

-- 3. DROP usp_PowerBi_Defect_Price_get (Thay bằng usp_PowerBIDefectPrice_get)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_PowerBi_Defect_Price_get]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[usp_PowerBi_Defect_Price_get];
    PRINT 'SUCCESS: Dropped procedure [usp_PowerBi_Defect_Price_get]';
END
ELSE
BEGIN
    PRINT 'INFO: Procedure [usp_PowerBi_Defect_Price_get] does not exist or was already dropped.';
END
GO

-- 4. DROP usp_View_SecurityBN (Thay bằng usp_View_Security_BN)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_View_SecurityBN]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[usp_View_SecurityBN];
    PRINT 'SUCCESS: Dropped procedure [usp_View_SecurityBN]';
END
ELSE
BEGIN
    PRINT 'INFO: Procedure [usp_View_SecurityBN] does not exist or was already dropped.';
END
GO

-- 5. DROP usp_VPCCommInspTypeInfo_popup (Thay bằng usp_VPC_CommInspTypeInfo_Popup)
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[usp_VPCCommInspTypeInfo_popup]') AND type in (N'P', N'PC'))
BEGIN
    DROP PROCEDURE [dbo].[usp_VPCCommInspTypeInfo_popup];
    PRINT 'SUCCESS: Dropped procedure [usp_VPCCommInspTypeInfo_popup]';
END
ELSE
BEGIN
    PRINT 'INFO: Procedure [usp_VPCCommInspTypeInfo_popup] does not exist or was already dropped.';
END
GO
