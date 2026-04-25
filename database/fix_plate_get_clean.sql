USE [SmartFactoryV2]
GO

IF OBJECT_ID('usp_VVT_SortingErrorData_Plate_get', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_Plate_get;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_Plate_get]
    @pFrom_Date          NVARCHAR(10) = NULL,
    @pToDate_            NVARCHAR(10) = NULL,
    @pMaterial_Code      NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, 
        [Date], 
        [Shift], 
        [Person],
        [Vendor],
        [Factory],
        MaterialCode,
        MaterialCode AS [Material Code],
        MaterialCode AS [Marterial],
        LotNo,
        LotNo AS [Lot no],
        [QtyCheck],
        [QtyCheck] AS [Q'Ty Check],
        [QtyOK],
        [QtyOK] AS [Q'ty OK],
        
        -- Plate Errors (Keep both internal name for framework and alias for Excel/UX)
        Burr,               Burr AS [Burr],
        Dent,               Dent AS [MẻDent],
        Deform,             Deform AS [MópDeform],
        Scratch,            Scratch AS [XướcScratch],
        NGPlating,          NGPlating AS [Bong mạNG Plating],
        RoughFace,          RoughFace AS [SầnRough face],
        Dirty,              Dirty AS [BẩnDirty],
        DentBottom,         DentBottom AS [Lõm đáyDent Bottom],
        Discolor,           Discolor AS [Biến sắcDiscolor],
        OtherError,         OtherError AS [Lỗi khácOther],
        
        [Total],
        [Status] = ''
    FROM STB_VVT_SortingErrorData_Plate
    WHERE (@pFrom_Date IS NULL OR [Date] >= @pFrom_Date)
      AND (@pToDate_ IS NULL OR [Date] <= @pToDate_)
      AND (@pMaterial_Code IS NULL OR MaterialCode LIKE '%' + @pMaterial_Code + '%')
    ORDER BY [Date] DESC, ID DESC;
END;
GO
