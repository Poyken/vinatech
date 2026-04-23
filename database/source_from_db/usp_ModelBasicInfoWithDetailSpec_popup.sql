-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 모델정보 팝업 (상세스펙 포함)
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelBasicInfoWithDetailSpec_popup]
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
			MBI.MaterialTypeCode,
			MBI.MBIExtText03,
			MBI.MBIExtText04,
			MBI.MBIExtText05,
			RIGHT('0'+CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeW)), 2) 
		             + CONVERT(VARCHAR(10), CONVERT(INT, MBI.MBISizeH)) 
					 + CASE WHEN CHARINDEX('-L', MBI.ModelName, 10) > 0 THEN 'L' 
							WHEN CHARINDEX('-B', MBI.ModelName, 10) > 0 THEN 'B' 
							WHEN CHARINDEX('-C', MBI.ModelName, 10) > 0 THEN 'C' 
							ELSE '' END AS ProdSize
	FROM VW_ModelBasicInfo MBI WITH(NOLOCK)
	WHERE
			MBI.ProductGroupCode IS NULL OR MBI.ProductGroupCode LIKE @ProductGroupCode
END
