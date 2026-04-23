-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 모델정보 팝업
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelBasicInfoERPSpec_popup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			    @ProductGroupCode  VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END

   SELECT
			MBI.ModelCode,
			MBI.ModelName, 
			CASE WHEN ISNULL(MM.MaterialSpec, '') = '' THEN 
				MBI.MBIExtText04 + 'V-' + MBI.MBIExtText05 
										+ 'F(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) 
										+ CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')' 
				 ELSE MM.MaterialSpec END AS MaterialSpec,
		   CASE WHEN MM.MaterialTypeCode = 'MDL' THEN 'MODULE'
				ELSE RIGHT('0' + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeW)), 2) 
							   + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeH)) END AS ProductSize,
		   MM.MaterialUnit,
           MBI.ProductGroupCode
	FROM VW_ModelBasicInfo MBI WITH(NOLOCK)
    LEFT OUTER JOIN STB_MaterialMaster MM  ON MBI.ModelCode = MM.MaterialCode
	WHERE
			MBI.ProductGroupCode IS NULL OR MBI.ProductGroupCode LIKE @ProductGroupCode
END