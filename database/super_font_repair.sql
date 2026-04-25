USE [SmartFactoryV2]
GO

-- =========================================================================================
-- SUPER REPAIR V16: DATA TYPE HARDENING (FIX INT32 FORMAT ERROR)
-- Mục tiêu: 
--   1. Khắc phục lỗi "Input string was not in a correct format" khi import dòng có khoảng trắng.
--   2. Ép kiểu toàn bộ cột số về VARCHAR trong SP Get để Grid không bị lỗi ép kiểu khi Import.
--   3. Xử lý triệt để dấu cách trong cột Scratch và các cột lỗi khác.
-- =========================================================================================

-------------------------------------------------------------------------------------------
-- 1. usp_VVT_SortingErrorData_ALCase_get
-------------------------------------------------------------------------------------------
IF OBJECT_ID('usp_VVT_SortingErrorData_ALCase_get', 'P') IS NOT NULL DROP PROC usp_VVT_SortingErrorData_ALCase_get;
GO

CREATE PROCEDURE [dbo].[usp_VVT_SortingErrorData_ALCase_get]
    @pFrom_Date          NVARCHAR(10) = NULL,
    @pToDate_            NVARCHAR(10) = NULL,
    @pMaterial_Code      NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT 
        ID, [Date], [Shift], [Person], [Vendor], [Factory], 
        MaterialCode, MaterialCode AS [Material Code], MaterialCode AS [Marterial],
        LotNo, LotNo AS [Lot no],
        -- Ép kiểu VARCHAR để Grid linh hoạt khi Import dữ liệu từ Excel (tránh lỗi Int32)
        CAST([QtyCheck] AS VARCHAR(10)) AS [QtyCheck], CAST([QtyCheck] AS VARCHAR(10)) AS [Q'Ty Check],
        CAST([QtyOK] AS VARCHAR(10)) AS [QtyOK], CAST([QtyOK] AS VARCHAR(10)) AS [Q'ty OK],
        CAST([BurrAl] AS VARCHAR(10)) AS [BurrAl], CAST([BurrAl] AS VARCHAR(10)) AS [Burr nhômBurr Al],
        CAST([BurrPlastic] AS VARCHAR(10)) AS [BurrPlastic], CAST([BurrPlastic] AS VARCHAR(10)) AS [Burr NhựaBurr Plastic],
        CAST([BurrRubber] AS VARCHAR(10)) AS [BurrRubber], CAST([BurrRubber] AS VARCHAR(10)) AS [Burr caosu],
        CAST([PlasticPeeling] AS VARCHAR(10)) AS [PlasticPeeling], CAST([PlasticPeeling] AS VARCHAR(10)) AS [Bong tấm nhựa],
        CAST([Scratch] AS VARCHAR(10)) AS [Scratch], CAST([Scratch] AS VARCHAR(10)) AS [Xước Scratch],
        CAST([Deform] AS VARCHAR(10)) AS [Deform], CAST([Deform] AS VARCHAR(10)) AS [Biến dạngDeform],
        CAST([ExposedCopper] AS VARCHAR(10)) AS [ExposedCopper], CAST([ExposedCopper] AS VARCHAR(10)) AS [Hở đồngExposed copper],
        CAST([RubberDeform] AS VARCHAR(10)) AS [RubberDeform], CAST([RubberDeform] AS VARCHAR(10)) AS [Biến dạng cao suDeform caosu],
        CAST([CrackWood] AS VARCHAR(10)) AS [CrackWood], CAST([CrackWood] AS VARCHAR(10)) AS [Nứt gỗCrack Wood],
        CAST([Discoloration] AS VARCHAR(10)) AS [Discoloration], CAST([Discoloration] AS VARCHAR(10)) AS [Biến sắcDiscoloration],
        CAST([OtherError] AS VARCHAR(10)) AS [OtherError], CAST([OtherError] AS VARCHAR(10)) AS [Other],
        CAST([Total] AS VARCHAR(10)) AS [Total], [Status] = ''
    FROM STB_VVT_SortingErrorData_ALCase
    WHERE (@pFrom_Date IS NULL OR [Date] >= @pFrom_Date)
      AND (@pToDate_ IS NULL OR [Date] <= @pToDate_)
      AND (@pMaterial_Code IS NULL OR MaterialCode LIKE '%' + @pMaterial_Code + '%')
    ORDER BY [Date] DESC, ID DESC;
END;
GO

-------------------------------------------------------------------------------------------
-- 2. usp_VVT_SortingErrorData_Plate_get
-------------------------------------------------------------------------------------------
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
        ID, [Date], [Shift], [Person], [Vendor], [Factory], 
        MaterialCode, MaterialCode AS [Material Code], MaterialCode AS [Marterial],
        LotNo, LotNo AS [Lot no],
        CAST([QtyCheck] AS VARCHAR(10)) AS [QtyCheck], CAST([QtyCheck] AS VARCHAR(10)) AS [Q'Ty Check],
        CAST([QtyOK] AS VARCHAR(10)) AS [QtyOK], CAST([QtyOK] AS VARCHAR(10)) AS [Q'ty OK],
        CAST([Burr] AS VARCHAR(10)) AS [Burr],
        CAST([Dent] AS VARCHAR(10)) AS [Dent], CAST([Dent] AS VARCHAR(10)) AS [MẻDent],
        CAST([Deform] AS VARCHAR(10)) AS [Deform], CAST([Deform] AS VARCHAR(10)) AS [MópDeform],
        CAST([Scratch] AS VARCHAR(10)) AS [Scratch], CAST([Scratch] AS VARCHAR(10)) AS [XướcScratch],
        CAST([NGPlating] AS VARCHAR(10)) AS [NGPlating], CAST([NGPlating] AS VARCHAR(10)) AS [Bong mạNG Plating],
        CAST([RoughFace] AS VARCHAR(10)) AS [RoughFace], CAST([RoughFace] AS VARCHAR(10)) AS [SầnRough face],
        CAST([Dirty] AS VARCHAR(10)) AS [Dirty], CAST([Dirty] AS VARCHAR(10)) AS [BẩnDirty],
        CAST([DentBottom] AS VARCHAR(10)) AS [DentBottom], CAST([DentBottom] AS VARCHAR(10)) AS [Lõm đáyDent Bottom],
        CAST([Discolor] AS VARCHAR(10)) AS [Discolor], CAST([Discolor] AS VARCHAR(10)) AS [Biến sắcDiscolor],
        CAST([OtherError] AS VARCHAR(10)) AS [OtherError], CAST([OtherError] AS VARCHAR(10)) AS [Lỗi khácOther],
        CAST([Total] AS VARCHAR(10)) AS [Total], [Status] = ''
    FROM STB_VVT_SortingErrorData_Plate
    WHERE (@pFrom_Date IS NULL OR [Date] >= @pFrom_Date)
      AND (@pToDate_ IS NULL OR [Date] <= @pToDate_)
      AND (@pMaterial_Code IS NULL OR MaterialCode LIKE '%' + @pMaterial_Code + '%')
    ORDER BY [Date] DESC, ID DESC;
END;
GO
