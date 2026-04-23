-- =============================================
-- Author : Kangs(kilee@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2020-10-22
-- Description : 모든 모델정보 팝업
--  2020.10.22 구형규요청
  
-- Modified : 스펙 (전압, 용량, 사이즈) 컬럼 추가 , By Jackaroe , 2020.05.15
--            단종 제품 제외 조건 추가 By Jackaroe , 2021.03.27 #210327
-- usp_ModelBasicInfoTotal_popup '','','','','DefectDivisionCode'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelBasicInfoTotal_popup]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pProductGroupCode VARCHAR(20) = NULL,
						@pMaterialTypeGroupCode VARCHAR(20) = NULL,
						@pDefectGroupCode VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;
	--raiserror('va',16,1)
    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProductGroupCode  VARCHAR(MAX) = CASE WHEN ISNULL(@pProductGroupCode,'') = '' THEN '*' ELSE @pProductGroupCode END
    DECLARE @DefectGroupCode VARCHAR(50) = CASE WHEN ISNULL(@pDefectGroupCode,'') = '' THEN '*' ELSE @pDefectGroupCode END

	IF @DefectGroupCode <> '*' BEGIN
		IF @DefectGroupCode = '08' BEGIN
			SET @ProductGroupCode = 'COATING-ROLL'
		END ELSE BEGIN
			-- 2025-08-06 Mr Manh update more Groupcode for Ha Nam Factory 
			SET @ProductGroupCode = 'HC-EDLC,HC-VPC,FERT,RadialBulk,RadialTaping,SMD,RadialBendingLeft,ANODE-FOIL,CATHODE-FOIL,CON-PAPER,AL-CASE,LEAD-WIRE,RUBBER' -- 그룹을 이렇게 고정시키면 어쩌냐..  #210327
		END
	END

   SELECT
			MBI.ModelCode ,
			MBI.ModelName ,
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
	LEFT OUTER JOIN STB_MaterialMaster MM2 ON MBI.ModelCode = MM2.MaterialCode
	WHERE 1=1
	  AND (@ProductGroupCode = '*' OR MBI.ProductGroupCode IN (SELECT Item FROM dbo.fnSplitToTable(',', @ProductGroupCode) )) -- #210327
	  AND ((MM2.IsClosed = CONVERT(BIT, 0)) -- #210327 
			OR MM2.CreateUserID IN ('yjyu', 'hoangxuan', 'doannam')) -- Mr.Manh update 2025-08-06 for Ha Nam Factory
END
