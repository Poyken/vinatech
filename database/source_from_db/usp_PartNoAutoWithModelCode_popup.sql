-- =============================================
-- Author : 
-- Group : 
-- Browsable :
-- Create date : 
-- Description : 
  
-- =============================================
CREATE PROCEDURE [dbo].[usp_PartNoAutoWithModelCode_popup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL,
						@pIsClosed CHAR(1) = '0'
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			    @ProductGroupCode  VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
				@IsClosed CHAR(1) = CASE WHEN ISNULL(@pIsClosed, '') = '' THEN '*' ELSE @pIsClosed END,
				@PartNo VARCHAR(200) = ''


   IF @IsClosed = '*' BEGIN
	   SELECT
				MBI.ModelCode,
				MBI.ModelName, 
				MBI.MaterialTypeCode,
				MBI.MBIExtInt01,
				MBI.MBIExtText06,
				MM.MaterialName AS SingleCellMaterialName,
				MBI.MBIExtText04 + 'V-' + MBI.MBIExtText05 
											+ 'F(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) 
											+ CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')' AS MaterialSpec
			   , MBI.ProductGroupCode,
			   case when substring(MM.MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
						when substring(MM.MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
						when substring(MM.MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12))))
						else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end  as PartNo
		FROM VW_ModelBasicInfo MBI WITH(NOLOCK)
				 LEFT OUTER JOIN STB_MaterialMaster MM  ON MBI.ModelCode = MM.MaterialCode
		WHERE
				MBI.ProductGroupCode IS NULL OR MBI.ProductGroupCode LIKE @ProductGroupCode
	END ELSE BEGIN
		SELECT
				MBI.ModelCode,
				MBI.ModelName, 
				MBI.MaterialTypeCode,
				MBI.MBIExtInt01,
				MBI.MBIExtText06,
				MM.MaterialName AS SingleCellMaterialName,
				MBI.MBIExtText04 + 'V-' + MBI.MBIExtText05 
											+ 'F(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) 
											+ CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')' AS MaterialSpec
			   , MBI.ProductGroupCode,
			      case when substring(MaterialName,1,3) in ('VEC','WEC') then RTRIM(LTRIM(substring(MM.MaterialName,1,11))) 
						when substring(MaterialName,1,3) in ('VEL') then RTRIM(LTRIM(substring(MM.MaterialName,1,14))) 
						when substring(MaterialName,8,20) in ('WEM12R0126QG') then (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName)+1, 12)))) --Duy thêm tạm 
						else (RTRIM(LTRIM(SUBSTRING(MM.MaterialName, CHARINDEX(' ', MM.MaterialName), 12)))) end  as PartNo
		FROM VW_ModelBasicInfo MBI WITH(NOLOCK)
				 LEFT OUTER JOIN STB_MaterialMaster MM  ON MBI.ModelCode = MM.MaterialCode
		WHERE
				MBI.ProductGroupCode IS NULL OR MBI.ProductGroupCode LIKE @ProductGroupCode
			AND MBI.IsClosed = CONVERT(BIT, @IsClosed)
	END
END