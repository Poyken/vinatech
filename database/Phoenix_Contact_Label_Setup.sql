USE [SmartFactoryV2]
GO

/****** Object:  StoredProcedure [dbo].[usp_Vietnam_PhoenixContactLabelPrint_get]    Script Date: 2026-05-13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* 
   =============================================
   Author:      Antigravity (AI Assistant)
   Create date: 2026-05-13
   Description: Fetch data for Phoenix Contact Label Print
   Requirement: Datecode YYMMDD from Winding (InputJobDate)
   =============================================
*/
CREATE OR ALTER PROCEDURE [dbo].[usp_Vietnam_PhoenixContactLabelPrint_get]
    @pPackingID NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        DP.PackingID AS [Mã Thùng],
        DP.Qty AS [Số Lượng],
        MBI.ModelName AS [Tên Model],
        SI.MaterialCode AS [Mã Vật Tư],
        -- YYMMDD Format from Winding JobDate
        CONVERT(VARCHAR(6), SI.InputJobDate, 12) AS [DateCode],
        DP.LotNo AS [Mã Lot/ControlNo],
        SI.InputJobDate AS [Ngày Cuốn],
        GETDATE() AS [Giờ In]
    FROM STB_DividePackaging DP WITH(NOLOCK)
    JOIN STB_SetInfo SI WITH(NOLOCK) ON DP.LotNo = SI.ControlNo
    JOIN STB_ModelBasicInfo MBI WITH(NOLOCK) ON SI.MaterialCode = MBI.ModelCode
    WHERE DP.PackingID = @pPackingID 
       OR DP.ParentPackingID = @pPackingID
       OR DP.LotNo = @pPackingID -- Hỗ trợ in theo LotNo như chị yêu cầu
END
GO

-- ĐĂNG KÝ MODEL LABEL (Bao phủ cả mã cũ và mã mới)
-- Chị chạy script này để đảm bảo dù Lot cũ (-098) hay Lot mới (-197) đều in được tem Phoenix.

-- Map cho mã mới (-197)
IF NOT EXISTS (SELECT 1 FROM STB_ModelLabelInfo WHERE ModelCode = 'ECVT30-197' AND LabelType = 'Phoenix_Label')
BEGIN
    INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
    VALUES ('ECVT30-197', 'Phoenix_Label', 'Phoenix_Contact_V1', GETDATE(), 'Antigravity')
END

-- Map cho mã cũ (-098)
IF NOT EXISTS (SELECT 1 FROM STB_ModelLabelInfo WHERE ModelCode = 'ECVT30-098' AND LabelType = 'Phoenix_Label')
BEGIN
    INSERT INTO STB_ModelLabelInfo (ModelCode, LabelType, FormatName, CreateDateTime, CreateUserID)
    VALUES ('ECVT30-098', 'Phoenix_Label', 'Phoenix_Contact_V1', GETDATE(), 'Antigravity')
END
GO


