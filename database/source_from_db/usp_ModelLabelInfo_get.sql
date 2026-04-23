


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 모델라벨정보
-- Description:	모델라벨정보
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelLabelInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLabelType NVARCHAR(30) = NULL,
	@pFormatName NVARCHAR(30) = NULL,
	@pMaterialTypeCode VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @LabelType NVARCHAR(30) = ISNULL(@pLabelType,'')
	DECLARE @FormatName NVARCHAR(30) = CASE WHEN ISNULL(@pFormatName,'') = '' THEN '*' ELSE @pFormatName END
	DECLARE @MaterialTypeCode NVARCHAR(20) = CASE WHEN ISNULL(@pMaterialTypeCode,'') = '' THEN '*' ELSE @pMaterialTypeCode END

	SELECT
			@LabelType AS OldLabelType,
			MM.MaterialCode AS OldModelCode,
			@LabelType AS LabelType,
			MM.MaterialCode AS ModelCode,
			MM.MaterialName AS ModelName,
			MM.MaterialSpec AS ModelSpec,
			MM.MaterialTypeCode,
			MT.MaterialTypeName,
            PG.ProductGroupName,
			@FormatName AS FormatName,
			CASE
				WHEN ISNULL(MLI.FormatName,'') = '' THEN CONVERT(BIT, 0)
				ELSE CONVERT(BIT, 1)
			END AS IsUsed,
			CASE 
				WHEN ISNULL(MLI.FormatName,'') = '' THEN MLI_OLD.FormatName
				ELSE MLI.FormatName
			END AS CurrentFormatName,
			CONVERT(BIT,CASE
				WHEN ISNULL(MLI_OLD.FormatName,'') = '' THEN 0
				ELSE CASE WHEN ISNULL(MLI.FormatName,'') = '' THEN 1 ELSE 0 END
			END) AS IsReadOnly
	FROM
			STB_MaterialMaster MM
			LEFT OUTER JOIN STB_MaterialType MT WITH(NOLOCK)
				ON (MM.MaterialTypeCode = MT.MaterialTypeCode)
            LEFT OUTER JOIN STB_ProductGroup PG WITH (NOLOCK)
            	ON (PG.ProductGroupCode = MM.ProductGroupCode)
			LEFT OUTER JOIN STB_ModelLabelInfo MLI WITH (NOLOCK)
				ON (MLI.ModelCode = MM.MaterialCode AND MLI.LabelType = @LabelType AND MLI.FormatName = @FormatName)
			LEFT OUTER JOIN STB_ModelLabelInfo MLI_OLD WITH (NOLOCK)
				ON (MLI_OLD.ModelCode = MM.MaterialCode AND MLI_OLD.LabelType = @LabelType)

	WHERE
			(@LabelType <> '') AND
			MT.IsUsed = 1 AND
			((@MaterialTypeCode = '*') OR (MM.MaterialTypeCode IN (SELECT Item FROM dbo.fnSplitToTable(',',@MaterialTypeCode))))
END




