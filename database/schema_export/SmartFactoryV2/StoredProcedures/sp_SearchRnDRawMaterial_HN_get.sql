-- Procedure: sp_SearchRnDRawMaterial_HN_get
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[sp_SearchRnDRawMaterial_HN_get]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pMaterialCode NVARCHAR(50) = NULL,
    @pGroupCode NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @MaterialCode NVARCHAR(50) = ISNULL(@pMaterialCode, '')

    IF (ISNULL(@pMaterialCode, '') = '')
    BEGIN
         RAISERROR('Vui lòng nhập mã code nguyên vật liệu', 16, 1, @MaterialCode);
        RETURN;
    END

    BEGIN
        SELECT 
            RM.MaterialCode,
            'R&D' as Class,
            RM.ProductGroupCode as GroupCode,
            RM.MaterialName as [Description],
            RM.MaterialUnit as Unit,
            0.0 AS Qty,
            VW.MBISizeH,
            VW.MBISizeW,
            GETDATE() as CREATEDATE
        FROM STB_MaterialMaster RM
        LEFT JOIN VW_ModelBasicInfo VW ON RM.MaterialCode = VW.ModelCode
        WHERE (@pMaterialCode IS NULL OR RM.MaterialCode = @pMaterialCode)
    END
END


GO

