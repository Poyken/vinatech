USE [SmartFactoryV2]
GO
IF OBJECT_ID('usp_VVT_SortingErrorData_Plate_get', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_Plate_get;
GO
-- =========================================================================================
-- Author:      Antigravity (AI Assistant)
-- Create date: 2026-04-24
-- Description: Get Sorting Error Data for Plate (Standard Model)
-- =========================================================================================
CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_get]
    @pFrom_Date          NVARCHAR(10) = NULL,
    @pToDate_            NVARCHAR(10) = NULL,
    @pMaterial_Code      NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, [Date], [Shift], Person, Vendor, Factory, MaterialCode, LotNo, [QtyCheck], [QtyOK],
        Burr, Dent, Deform, Scratch, NGPlating, RoughFace, Dirty, DentBottom, Discolor, OtherError, [Total]
    FROM STB_VVT_SortingErrorData_Plate
    WHERE (@pFrom_Date IS NULL OR [Date] >= @pFrom_Date)
      AND (@pToDate_ IS NULL OR [Date] <= @pToDate_)
      AND (@pMaterial_Code IS NULL OR MaterialCode LIKE '%' + @pMaterial_Code + '%')
    ORDER BY [Date] DESC, ID DESC;
END;
GO
