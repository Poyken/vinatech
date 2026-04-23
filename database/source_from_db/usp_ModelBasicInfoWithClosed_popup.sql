-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 모델정보 팝업
--  2020.10.22 구형규요청
  
-- Modified : 스펙 (전압, 용량, 사이즈) 컬럼 추가 , By Jackaroe , 2020.05.15
-- usp_ModelBasicInfo_popup '','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelBasicInfoWithClosed_popup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL,
						@pIsClosed BIT = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			    @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			    @ProductGroupCode  VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '%' ELSE @pProductGroupCode END,
				@IsClosed BIT = @pIsClosed


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
           , MBI.ProductGroupCode
	FROM VW_ModelBasicInfo MBI WITH(NOLOCK)
    LEFT OUTER JOIN STB_MaterialMaster MM  ON MBI.MBIExtText06 = MM.MaterialCode
	LEFT OUTER JOIN STB_MaterialMaster MM2  ON MBI.ModelCode = MM2.MaterialCode
	WHERE
			MBI.ProductGroupCode IS NULL OR MBI.ProductGroupCode LIKE @ProductGroupCode
		AND (@IsClosed IS NULL OR MM2.IsClosed = @IsClosed)
END
