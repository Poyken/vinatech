USE [SmartFactoryV2]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE [dbo].[usp_Vietnam_PhoenixContactLabelPrint_get]
    @pLotNo NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        SI.LotNumber AS [Mã Lot],
        MBI.ModelName AS [Tên Model],
        SI.MaterialCode AS [Mã Vật Tư],
        -- YYMMDD Format from Winding JobDate
        CONVERT(VARCHAR(6), SI.InputJobDate, 12) AS [DateCode],
        SI.InputJobDate AS [Ngày Sản Xuất],
        SI.ProdLotQty AS [Số Lượng],
        GETDATE() AS [Giờ In]
    FROM STB_SetInfo SI WITH(NOLOCK)
    JOIN STB_ModelBasicInfo MBI WITH(NOLOCK) ON SI.MaterialCode = MBI.ModelCode
    WHERE (SI.LotNumber = @pLotNo OR SI.ControlNo = @pLotNo)
      AND SI.MaterialCode IN ('ECVT30-197', 'ECVT30-098')
END
GO

-- ĐĂNG KÝ MODEL LABEL
IF NOT EXISTS (SELECT 1 FROM STB_ModelLabelInfo WHERE ModelCode = 'ECVT30-197' AND LabelType = 'Phoenix_Label')
BEGIN
    INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
    VALUES ('ECVT30-197', 'Phoenix_Label', 'Phoenix_Contact_V1', GETDATE(), 'Antigravity')
END
GO

IF NOT EXISTS (SELECT 1 FROM STB_ModelLabelInfo WHERE ModelCode = 'ECVT30-098' AND LabelType = 'Phoenix_Label')
BEGIN
    INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
    VALUES ('ECVT30-098', 'Phoenix_Label', 'Phoenix_Contact_V1', GETDATE(), 'Antigravity')
END
GO

-- CẤU HÌNH GIAO DIỆN B790 TỐI GIẢN (Trong SmartFramework)
-- Vì STB_ScreenObjects thường nằm ở SmartFramework, em sẽ chỉ định rõ Database
DELETE FROM SmartFramework.dbo.STB_ScreenObjects WHERE ScreenName = 'InTemPhoenixContact'
GO

INSERT INTO SmartFramework.dbo.STB_ScreenObjects (ScreenName, ObjectType, ObjectName, Caption)
VALUES 
('InTemPhoenixContact', 'SearchFunction', 'usp_Vietnam_PhoenixContactLabelPrint_get', '^SearchFunction^'),
('InTemPhoenixContact', 'Action', 'PrintWeightLabel', '^Print Phoenix Label^')
GO
