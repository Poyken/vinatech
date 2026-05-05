-- Procedure: sp_SearchRnDRawMaterial_Export_HN_get
-- ================================================
-- Template generated from Template Explorer using:
-- Create Procedure (New Menu).SQL
--
-- Use the Specify Values for Template Parameters 
-- command (Ctrl-Shift-M) to fill in the parameter 
-- values below.
--
-- This block of comments will not be included in
-- the definition of the procedure.
-- ================================================
CREATE PROCEDURE [dbo].[sp_SearchRnDRawMaterial_Export_HN_get]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pMaterialCode NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaterialCode NVARCHAR(50) = ISNULL(@pMaterialCode, '')

    IF (ISNULL(@pMaterialCode, '') = '')
    BEGIN
         RAISERROR('Vui lòng nhập mã code nguyên vật liệu', 16, 1, @MaterialCode);
        RETURN;
    END

    IF(@MaterialCode NOT IN (
    SELECT MaterialCode FROM Stb_RnDRawMaterial_HN
    ))
      BEGIN
         RAISERROR('Mã này chưa được nhập kho', 16, 1, @MaterialCode);
        RETURN;
    END

    BEGIN
        SELECT 
            RM.MaterialCode,
            RM.Class,
            RM.GroupCode,
            RM.Description,
            RM.Unit as Unit,
             VW.MBISizeH,
            VW.MBISizeW,
            0.0 AS Qty
        FROM Stb_RnDRawMaterial_HN RM
        LEFT JOIN VW_ModelBasicInfo VW ON RM.MaterialCode = VW.ModelCode
        WHERE (@pMaterialCode IS NULL OR RM.MaterialCode = @pMaterialCode)
    END
END

GO

