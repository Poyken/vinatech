-- =============================================
-- Author : Kangs(kilee@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2021-02-02 
-- Description : 모든 모델정보 팝업
--  2020.10.22 구형규요청
-- Modified : 
-- usp_ModelBasicInfoCOATINGTotal_popup  '','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelBasicInfoCOATINGTotal_popup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL,
						@pMaterialTypeGroupCode VARCHAR(20) = NULL,
						@pDefectGroupCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProductGroupCode  VARCHAR(20) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END
    DECLARE @DefectGroupCode VARCHAR(50) = CASE WHEN ISNULL(@pDefectGroupCode,'') = '' THEN '*' ELSE @pDefectGroupCode END

	IF @DefectGroupCode <> '*' BEGIN
		IF @DefectGroupCode = '08' BEGIN
			SET @ProductGroupCode = 'COATING-ROLL'
		END ELSE BEGIN
			SET @ProductGroupCode = 'HC-EDLC'
		END
	END

   SELECT
			MBI.ModelCode as MaterialCode ,
			MBI.ModelName as MaterialName ,
			MBI.MaterialTypeCode,
			MBI.MBIExtInt01,
			MBI.MBIExtText06,
			MM.MaterialName AS SingleCellMaterialName,
			MBI.MBIExtText04 + 'V-' + MBI.MBIExtText05 
			                        + 'F(' + RIGHT('0'+CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeW)), 2) 
							        + CONVERT(VARCHAR, CONVERT(INT, MBI.MBISizeH)) + ')' AS MaterialSpec
           , MBI.ProductGroupCode		 
	FROM VW_ModelBasicInfoTotal MBI WITH(NOLOCK)
             LEFT OUTER JOIN STB_MaterialMaster MM  ON MBI.MBIExtText06 = MM.MaterialCode
	WHERE 1=1
	  AND (@ProductGroupCode = '*' OR MBI.ProductGroupCode = @ProductGroupCode)
END
