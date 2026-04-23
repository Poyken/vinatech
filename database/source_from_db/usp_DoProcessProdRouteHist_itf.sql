-- 작업실적 인터페이스 프로시저
-- =============================================
-- Author: jackaroe(yjyu@vina.co.kr)
-- Create date: 2021-04-17
-- Browsable : true
-- Group : 인터페이스
-- Source Table: NEOE.NEOE.PR_WORK_MES
-- Target Table: SmartFactoryV2.DBO.STB_ProdRouteHist
-- Description:	작업실적 인터페이스
-- Modified:
-- =============================================
CREATE PROC usp_DoProcessProdRouteHist_itf
	@pProcessUserID VARCHAR(20) 
   ,@pProcessLanguage VARCHAR(20)
   ,@pIUCompanyCode VARCHAR(20)
   ,@pProudRouteHistNo VARCHAR(20)
   ,@pFGStatus CHAR(1)
   ,@pIsRework CHAR(1) = 'N'
AS
BEGIN
	Declare @IUCompanyCode VARCHAR(20) = @pIUCompanyCode
	       ,@ProudRouteHistNo VARCHAR(20) = @pProudRouteHistNo
		   ,@FGStatus CHAR(1) = @pFGStatus
		   ,@IsRework CHAR(1) = @pIsRework

	-- 원자재 소모량
	exec usp_ProdRouteRawMaterialHist_itf @pProcessUserID, @pProcessLanguage, @IUCompanyCode, @ProudRouteHistNo, 'C', @IsRework

	IF @FGStatus = 'T' BEGIN
		-- 제품 생산실적
		exec usp_ProdRouteHist_itf @pProcessUserID, @pProcessLanguage, @IUCompanyCode, @ProudRouteHistNo, 'T', @IsRework
	END
END