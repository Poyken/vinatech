-- ========================================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 품질관리  / 생산관리 > 실적등록 > 제품 생산실적입력 - 생산실적입력
-- Description:  바코드의 불량정보를 등록합니다
-- Modified:
-- ========================================================
Create PROCEDURE [dbo].[usp_DoProcessDefectRepairInfoByBarcode_SmartApp_20200428]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pLineCode VARCHAR(20),
					@pRouteCode VARCHAR(20),
					@pBarcode VARCHAR(50),
					@pDefectCode VARCHAR(20),
					@pDefectQty NUMERIC(20,5),
					@pMachineID VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @Barcode VARCHAR(20) = @pBarcode
	DECLARE @DefectCode VARCHAR(20) = @pDefectCode
	DECLARE @DefectQty NUMERIC(20,5) = @pDefectQty
	DECLARE @MachineID VARCHAR(20) = ISNULL(@pMachineID,'')
	DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @Data NVARCHAR(MAX)
	DECLARE @DPPExtText01 NVARCHAR(100)

	--DECLARE @CN            INT                                                                    -- 2020.04.28 변수추가


	-- START  : 2020.04.13 (채민수대리 요청사항 - 같은 불량코드로 중복불량되지 않도록 개선)  --> TEST : VJKM102R710613
			--Select  @CN = SUM(AA.CN) 
   --          from (
			--			Select Distinct (DefectCode)
			--					, SD.DefectQty								
			--					, Count(DefectCode)         AS CN
			--			From STB_DefectRepairInfo SD
			--		       LEFT OUTER JOIN STB_SETINFO SS ON SS.ControlNo = SD.ControlNo
			--               AND SS.BARCODE = @Barcode
			--			   AND FindRouteCode = @RouteCode
			--			   AND  FindLineCode = @LineCode
			--		    Group by DefectCode, SD.DefectQty
			--	   )  AA
   --            Having SUM(AA.CN) > 1
			
			--IF  @CN > 1
			--BEGIN
			--	 RAISERROR(' 이미 같은 불량코드로 등록되었습니다. 중복등록이 불가합니다.' ,16, 1)     
			--	 RETURN
			--END



		--IF  (				
		--			Select top 1 count(*)
		--			From STB_DefectRepairInfo SD
		--					LEFT OUTER JOIN STB_SETINFO SS ON SS.ControlNo = SD.ControlNo
		--			Where  1=1 
		--				--And ControlNo = '20200410000098'
		--				And FindRouteCode = 'E-22'
		--				And  FindLineCode = 'ASSYLINE-12'
		--				AND SS.BARCODE = 'VJKM102R710613'
			
		--			Group by   SD.defectcode
								
           
  --             ) > 1

		--	   BEGIN
		--		 RAISERROR(' 이미 같은 불량코드로 등록되었습니다. 중복등록이 불가합니다.' ,16, 1)     
		--		 RETURN
		--	END

			 ---- END -----------------------------------------------------------------------------------------------------------------------------------------------------







	SELECT
			@DPPExtText01 = DPP.DPPExtText01
	FROM
			                STB_SetInfo       SI   WITH(NOLOCK)
			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				ON DPP.DayPlanNo = SI.DayPlanNo
	WHERE
			SI.Barcode = @Barcode

	IF ISNULL(@DPPExtText01,'') = '1' 
	
	  BEGIN
			EXEC usp_RaiseLocalizedError @pProcessLanguage, '마감처리된 Lot입니다'
			RETURN
	  END


	IF ISNULL(@LineCode,'') = '' 
	
	BEGIN		-- 투입실적처리전에 불량을 입력할경우 라인정보를 계획에서 가져온다
			SELECT
					@LineCode = DPP.LineCode
			FROM
					STB_SetInfo SI WITH(NOLOCK)
					INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)						ON DPP.DayPlanNo = SI.DayPlanNo
			WHERE
					SI.Barcode = @Barcode
	END

	SET @Data = LEFT('PRODDEFECT' + REPLICATE(' ',20),20) +
					 LEFT(@LineCode + REPLICATE(' ',20),20) +
					 LEFT(@RouteCode + REPLICATE(' ',20),20) +
					dbo.fnConvertDateTimeToVarchar('yyyyMMddHHmissfff',@ProcessDateTime) +
					 LEFT(@Barcode + REPLICATE(' ',50),50) +
					 LEFT(@DefectCode + REPLICATE(' ',20),20) +
					 LEFT(CONVERT(VARCHAR,@DefectQty) + REPLICATE(' ',10),10)
	
	EXEC usp_DoProcessTerminalData	@pProcessUserID = @pProcessUserID,
												@pProcessLanguage = @pProcessLanguage,
												@pIPAddress = @MachineID,
												@pData = @Data
		
END
