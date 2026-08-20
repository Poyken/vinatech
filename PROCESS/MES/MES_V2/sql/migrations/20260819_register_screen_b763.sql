-- =========================================================================================
-- Register Screen [B763] in SmartFramework
-- =========================================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- 1. STB_ScreenInfo
IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenInfo WHERE Name = 'VVT_SanminaShipmentPlan')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenInfo (
        [Name],
        [TCode],
        [IsFolder],
        [IsNeverClose],
        [ParentName],
        [Caption],
        [ShowAfterStart],
        [ShowInMenu],
        [CurrentVersion],
        [CreateDateTime],
        [CreateUserID],
        [IsDelete],
        [AccessType]
    )
    VALUES (
        'VVT_SanminaShipmentPlan',
        'B763',
        0,
        0,
        'vi_Productionqty',
        N'^Thiết lập kế hoạch xuất Sanmina^',
        0,
        1,
        1,
        GETDATE(),
        'Antigravity',
        0,
        'PC,Web'
    );
    PRINT 'Inserted B763 into STB_ScreenInfo.';
END
ELSE
BEGIN
    UPDATE SmartFramework.dbo.STB_ScreenInfo
    SET TCode = 'B763',
        Caption = N'^Thiết lập kế hoạch xuất Sanmina^',
        ParentName = 'vi_Productionqty',
        ShowInMenu = 1,
        ChangeDateTime = GETDATE(),
        ChangeUserID = 'Antigravity'
    WHERE Name = 'VVT_SanminaShipmentPlan';
    PRINT 'Updated B763 in STB_ScreenInfo.';
END
GO

-- 2. STB_ScreenObjects
IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'VVT_SanminaShipmentPlan' AND ObjectName = 'usp_SanminaShipmentPlan_get')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
    VALUES ('VVT_SanminaShipmentPlan', 'SearchFunction', 'usp_SanminaShipmentPlan_get', NULL, N'Get Sanmina Shipment Plans');
END

IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'VVT_SanminaShipmentPlan' AND ObjectName = 'usp_SanminaShipmentPlan_iud')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
    VALUES ('VVT_SanminaShipmentPlan', 'ExecuteFunction', 'usp_SanminaShipmentPlan_iud', NULL, N'IUD Sanmina Shipment Plans');
END

IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'VVT_SanminaShipmentPlan' AND ObjectName = 'SavePlan')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
    VALUES ('VVT_SanminaShipmentPlan', 'Action', 'SavePlan', N'^Lưu Cấu Hình^', N'Lưu cấu hình Lô xuất');
END
GO
