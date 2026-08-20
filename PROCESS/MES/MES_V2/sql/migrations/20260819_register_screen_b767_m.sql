-- =========================================================================================
-- Registration: Register Screen [B767_M] VVT_SanminaShipmentPlan in SmartFramework
-- Target DB   : SmartFramework
-- Purpose     : Poka-Yoke Sanmina Label Printing - Screen Registration
-- Author      : Antigravity MES Engineer
-- Date        : 2026-08-19
-- =========================================================================================

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;

-- 1. Register Screen in SmartFramework.dbo.STB_ScreenInfo
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
        'B767_M',
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
    PRINT 'Registered VVT_SanminaShipmentPlan (B767_M) in STB_ScreenInfo.';
END
ELSE
BEGIN
    UPDATE SmartFramework.dbo.STB_ScreenInfo
    SET TCode = 'B767_M',
        Caption = N'^Thiết lập kế hoạch xuất Sanmina^',
        ParentName = 'vi_Productionqty',
        ShowInMenu = 1,
        ChangeDateTime = GETDATE(),
        ChangeUserID = 'Antigravity'
    WHERE Name = 'VVT_SanminaShipmentPlan';
    PRINT 'Updated VVT_SanminaShipmentPlan (B767_M) in STB_ScreenInfo.';
END
GO

-- 2. Register Screen Objects in SmartFramework.dbo.STB_ScreenObjects

-- 2.1 Search Function: usp_SanminaShipmentPlan_get
IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'VVT_SanminaShipmentPlan' AND ObjectName = 'usp_SanminaShipmentPlan_get')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
    VALUES ('VVT_SanminaShipmentPlan', 'SearchFunction', 'usp_SanminaShipmentPlan_get', NULL, N'Get Sanmina Shipment Plans');
END

-- 2.2 Execute Function: usp_SanminaShipmentPlan_iud
IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'VVT_SanminaShipmentPlan' AND ObjectName = 'usp_SanminaShipmentPlan_iud')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
    VALUES ('VVT_SanminaShipmentPlan', 'ExecuteFunction', 'usp_SanminaShipmentPlan_iud', NULL, N'IUD Sanmina Shipment Plans');
END

-- 2.3 Action: SavePlan
IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'VVT_SanminaShipmentPlan' AND ObjectName = 'SavePlan')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
    VALUES ('VVT_SanminaShipmentPlan', 'Action', 'SavePlan', N'^Lưu Kế Hoạch^', N'Lưu thông tin Lô xuất');
END

-- 2.4 Action: ActivatePlan
IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'VVT_SanminaShipmentPlan' AND ObjectName = 'ActivatePlan')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
    VALUES ('VVT_SanminaShipmentPlan', 'Action', 'ActivatePlan', N'^Kích Hoạt Lô Xuất^', N'Kích hoạt Lô xuất đang in');
END

-- 2.5 Action: CompletePlan
IF NOT EXISTS (SELECT 1 FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'VVT_SanminaShipmentPlan' AND ObjectName = 'CompletePlan')
BEGIN
    INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption, Description)
    VALUES ('VVT_SanminaShipmentPlan', 'Action', 'CompletePlan', N'^Hoàn Tất Lô Xuất^', N'Đóng Lô xuất');
END

PRINT 'Registered screen objects for VVT_SanminaShipmentPlan successfully.';
GO
