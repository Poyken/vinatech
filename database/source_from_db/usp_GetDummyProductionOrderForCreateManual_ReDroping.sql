-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 생산관리
-- Browsable : true
-- Create date : 2018-07-30
-- Description : 수동 PO 생성 대화상자를 위한 Dummy 테이블 조회
-- Modified :
-- =============================================

--  exec [usp_GetDummyProductionOrderForCreateManual_ReDroping] '1123123'

CREATE PROCEDURE [dbo].[usp_GetDummyProductionOrderForCreateManual_ReDroping]
	@pProcessUserID VARCHAR(20) =null,
	@pProcessLanguage VARCHAR(20) =null,
	@pMaterialCode VARCHAR(50)=null,
	@pMaterialName VARCHAR(50)=null,
	@pLotNo VARCHAR(50) =null,
	@pQty NUMERIC(20)=null,
	@pDefectSummaryNo VARCHAR(20)=null


AS
BEGIN
	SET NOCOUNT ON;

    DECLARE 
	@ProcessUserID VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage VARCHAR(20) = @pProcessLanguage,			
				@PlanStartDate DATE,	
				@PlanEndDate DATE,
				@MaterialCode VARCHAR(50) =@pMaterialCode,
				@MaterialName VARCHAR(50) =@pMaterialName,
				@LotNo VARCHAR(50) =@pLotNo,
				@Qty NUMERIC(20) = @pQty,
				@DefectSummaryNo VARCHAR(50) =@pDefectSummaryNo
				--@CompanyCode  VARCHAR(20)     --2020.10.06 추가



	SELECT
			GETDATE() AS PlanYearMonth,
			@PlanStartDate AS PlanStartDate,
			@PlanEndDate AS PlanEndDate,
			@MaterialCode AS MaterialCode,
			@MaterialName AS MaterialName,
			'' AS BomVersion,
			 @Qty AS POQty,
			@LotNo AS LotNo,
			@DefectSummaryNo as DefectSummaryNo
			
			
		--	@CompanyCode As CompanyCode       -- 2020.10.01 추가

END
