-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2020-11-04
-- Description : 모델정보 팝업
  
-- Modified : 스펙 (전압, 용량, 사이즈) 컬럼 추가 , By Jackaroe , 2020.05.15
-- usp_ModelBasicInfo_popup '','',''
-- =============================================
CREATE PROCEDURE usp_ModelBasicInfoVoltFarad_popup
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProductGroupCode  VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END

   SELECT
			MBI.ModelCode,
			MBI.ModelName, 
			MBI.MaterialTypeCode,
			MBI.MBIExtText04,
			MBI.MBIExtText05,
            MBI.ProductGroupCode
	FROM VW_ModelBasicInfo MBI WITH(NOLOCK)
   WHERE (@ProductGroupCode = '*' OR MBI.ProductGroupCode = @ProductGroupCode)
END