
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

