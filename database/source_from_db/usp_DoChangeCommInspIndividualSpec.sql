-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-07
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoChangeCommInspIndividualSpec]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pMaterialCode VARCHAR(20)
AS
BEGIN
	Declare @CompanyCode VARCHAR(20) = @pCompanyCode
	       ,@WorkCenterCode VARCHAR(20) = @pWorkCenterCode 
		   ,@MaterialCode VARCHAR(20) = @pMaterialCode

	IF LEFT(@MaterialCode, 4) = 'LIVT' BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'VPC 스펙은 자동반영이 되지 않습니다.(적용중)'
		RETURN
	END

	--IF @CompanyCode = 'VNT'   -- 베트남도 공용검사스펙 같이 적용되도록 주석처리 (2020-02-28, kilee)
	
	--BEGIN
	    --Exec usp_DoAddCommonInspectionSpec @pCompanyCode @pWorkCenterCode, @MaterialCode, 'ROUTE_QUALITY'                  -- 원본백업
		--Exec usp_DoAddCommonInspectionSpec @pCompanyCode @pWorkCenterCode,  @MaterialCode, 'ROUTE_TEST'                      -- 원본백업

		Exec usp_DoAddCommonInspectionSpec 'VNT', 'VNT_F1', @MaterialCode, 'ROUTE_QUALITY'   
		Exec usp_DoAddCommonInspectionSpec  'VNT', 'VNT_F1', @MaterialCode, 'ROUTE_TEST'
	--END ELSE 	

	-- 베트남 적용추가 (2020-02-28, kilee)
	    --Exec usp_DoAddCommonInspectionSpec @pCompanyCode @pWorkCenterCode, @MaterialCode, 'ROUTE_QUALITY'                  -- 원본백업
		--Exec usp_DoAddCommonInspectionSpec @pCompanyCode @pWorkCenterCode, @MaterialCode, 'ROUTE_TEST'                      -- 원본백업

	--BEGIN
		Exec usp_DoAddCommonInspectionSpec  'VVT', 'VVT_F1', @MaterialCode, 'ROUTE_QUALITY2'       -- 사업장코드 하드코딩 (2020-03-12, kilee)
		Exec usp_DoAddCommonInspectionSpec  'VVT', 'VVT_F1', @MaterialCode, 'ROUTE_TEST2'            -- 사업장코드 하드코딩 (2020-03-12, kilee)
	--END





END