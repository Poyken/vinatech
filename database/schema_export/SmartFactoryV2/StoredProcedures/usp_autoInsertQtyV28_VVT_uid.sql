-- Procedure: usp_autoInsertQtyV28_VVT_uid

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-17 -> 2019-05-03
-- Browsable : true
-- Group : 생산관리 >  [B520]제품박스실적입력 > Grid1 제품Lot정보 조회
-- Description: 패킹공정 실적 입력을 위한 바코드 정보를 가져옵니다
-- Modified: 베트남의 경우 제품검사를 거치지 않고 패킹하므로 쿼리를 수정함. 
-- 결과값이 존재해도 제품검사합격여부 판단 후 에러처리를 하기 때문에 문제 없을 것으로 판단함. 2020.01.06 By Jackaroe #200106J

-- 프로시저 실행 :  EXEC [usp_GetProdPackingForBarcode_VNT] '','','VVKS093R025601', '', ''

-- EXEC [usp_GetProdPackingForBarcode_VNT] '','','', '', ''
-- ================================================================================================================
CREATE PROCEDURE [dbo].[usp_autoInsertQtyV28_VVT_uid]
						@pProcessUserID VARCHAR(20),
						@pBarcode VARCHAR(50) = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @Barcode VARCHAR(50) = @pBarcode	
	DECLARE @CompanyCode  varchar(20)
	DECLARE @cCount NUMERIC(20,5)

	DECLARE @LineCode VARCHAR(20) 
	DECLARE @RouteCode VARCHAR(20) = 'V-28'
	DECLARE @DefectCode VARCHAR(20) = 'V-28_PA'
	DECLARE @DefectQty NUMERIC(20,5)  
	DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @ProcessLanguage  VARCHAR(20) = 'Vietnamese'
	
	DECLARE @WorkCenterCode VARCHAR(20) = 'VVT_F1'
	DECLARE @PONo VARCHAR(20)
	DECLARE @DayPlanNo VARCHAR(20)
	DECLARE @ControlNo VARCHAR(20)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @BomVersion VARCHAR(20) = ''
	DECLARE @DefectSummaryNo VARCHAR(30)
	DECLARE @NewBarcode VARCHAR(50)


	SELECT  @CompanyCode = CompanyCode   
	FROM  STB_UserInfo 
	where UserID=@ProcessUserID ;

	if(@CompanyCode='VVT' and @ProcessUserID='nguyen tung') begin

			SELECT @NewBarcode = NewBarcode 
			  FROM STB_LotChangeMaterialHistory 
			 WHERE OldBarcode = @Barcode
	
			select @cCount = count(*) 
			from STB_ProdRouteHist 
			where RouteCode='V-27'

			if(@cCount>0) begin

					select 
					@ControlNo = ControlNo,
					@DayPlanNo = DayPlanNo,
					@PONo = PONo,
					@MaterialCode = MaterialCode,
					@LineCode = InputLineCode 
					from STB_SetInfo 
					where Barcode=@Barcode or Barcode=@NewBarcode
								
					select @cCount = count(*) 
					from STB_ProdRouteHist 
					where RouteCode=@RouteCode  and ControlNo=@ControlNo

					if(@cCount=0) begin 

							select @DefectQty=-sum(DefectQty-RepairQty)
							from STB_DefectRepairInfo
							where ControlNo = @ControlNo

							if (@DefectQty<0) begin 
														
								EXEC usp_DoProcessDefectRepairInfo	
											@pProcessUserID = @ProcessUserID,
											@pProcessLanguage = @ProcessLanguage,
											@pCompanyCode = @CompanyCode,
											@pWorkCenterCode = @WorkCenterCode,
											@pPONo = @PONo,
											@pDayPlanNo = @DayPlanNo,
											@pMaterialCode = @MaterialCode,
											@pBomVersion = @BomVersion,
											@pLineCode = @LineCode,
											@pRouteCode = @RouteCode,
											@pControlNo = @ControlNo,
											@pDefectCode = @DefectCode,
											@pDefectQty = @DefectQty,
											@pProcessDateTime = @ProcessDateTime,
											@pDefectSummaryNo = @DefectSummaryNo OUTPUT
							end																			
					end
			end
	end


END

GO

