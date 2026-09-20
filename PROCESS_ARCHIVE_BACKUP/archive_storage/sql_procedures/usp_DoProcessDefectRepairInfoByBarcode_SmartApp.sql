-- ========================================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-23
-- Browsable : true
-- Group : 품질관리  / 생산관리 > 실적등록 > 제품 생산실적입력 - 생산실적입력
-- Description:  바코드의 불량정보를 등록합니다
-- Modified:
-- ========================================================
-- usp_DoProcessDefectRepairInfoByBarcode_SmartApp 'DinhManh', 'vi', '', 'VP04', 'VVES260221-001', 'VP04_003', '0', '', '', '', ''

CREATE PROCEDURE [dbo].[usp_DoProcessDefectRepairInfoByBarcode_SmartApp]		
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pLineCode VARCHAR(20),
					@pRouteCode VARCHAR(20),
					@pBarcode VARCHAR(50),
					@pDefectCode VARCHAR(20),
					@pDefectQty NUMERIC(20,5),
					@pMachineID VARCHAR(20) = NULL,
					@pDRIExtText02 NVARCHAR(400) = NULL,
					@pMarKingCode NVARCHAR(20) = NULL,
					--@pDefectCause NVARCHAR(100) =null
					@pDefectCauseID VARCHAR(100)=null
AS
BEGIN
	SET NOCOUNT ON;
	
	/*if(@pBarcode='VE250326-002' and @pRouteCode='VE01')
	begin
		exec usp_RaiseLocalizedError @pProcessLanguage, @pBarcode
			RETURN
	end*/
	DECLARE @LineCode VARCHAR(20) = @pLineCode
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @Barcode VARCHAR(20) = @pBarcode
	DECLARE @MarKingCode VARCHAR(20) =ISNULL(@pMarKingCode, '') 
	DECLARE @DefectCauseID VARCHAR(100) = ISNULL(@pDefectCauseID,'')
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @DefectCode VARCHAR(20) = @pDefectCode
	DECLARE @DefectQty NUMERIC(20,5) = @pDefectQty
	DECLARE @MachineID VARCHAR(20) = ISNULL(@pMachineID,'')
	DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @Data NVARCHAR(MAX)
	DECLARE @DPPExtText01 NVARCHAR(100)
	DECLARE @ProdQTY VARCHAR(20)
	-- 불량비고 추가 , 2020-08-25 By Jackaroe (조현준 셀장님 요청)
	DECLARE @DRIExtText02 NVARCHAR(400) = ISNULL(@pDRIExtText02, '')
	DECLARE @WorkCenterCheck VARCHAR(10) = NULL

	Select @WorkCenterCheck = WorkCenterCode  
		from STB_DayProdPlan
		where DayPlanNo = (Select DayPlanNo FROM STB_SetInfo where Barcode = @Barcode)

	
			--RAISERROR(@Barcode ,16, 1)     
			--RETURN

	select @CompanyCode=companyCode from stb_userinfo where userid=@pProcessUserID
	-- Thêm điều kiện check cho BG2 2026-02-23
	IF @WorkCenterCheck NOT IN ('VVT_F4', 'VVT_F3')
    BEGIN
      IF (
        (@DefectQty < 1 AND @CompanyCode = 'VVT') 
        OR @pProcessUserID IS NULL
       )
       AND (@Barcode NOT LIKE 'VE%' AND @Barcode NOT LIKE 'VVES%')
      BEGIN
        EXEC usp_RaiseLocalizedError @pProcessLanguage, '불량수량은 0보다 커야합니다'
        RETURN
      END
    END
--end

	SELECT
			@DPPExtText01 = DPP.DPPExtText01,
			@ProdQTY = ProdQty
	FROM
			                STB_SetInfo       SI   WITH(NOLOCK)
			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				ON DPP.DayPlanNo = SI.DayPlanNo
	WHERE
			SI.Barcode = @Barcode


    -- in Vietnam Factory, worker input error QTY < 0, this for prevent wrong
   -- IF (@RouteCode like 'V%' and @DefectQty <= 0 and @RouteCode not like 'V-28%')
	  --BEGIN
	  --		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Khong the nhap so luong Loi nho hon 0'
			--RETURN
	  --END
   -- IF (@RouteCode like 'V%' and @DefectQty > @ProdQTY)
	  --BEGIN
	  --		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'Khong the nhap so luong Loi cao hon so luong Lot'
			--RETURN
	  --END
   -- -- in Vietnam Factory, worker input error QTY > LotQTY, this for prevent wrong


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
					 LEFT(@RouteCode + REPLICATE(' ',20),20) +  dbo.fnConvertDateTimeToVarchar('yyyyMMddHHmissfff',@ProcessDateTime) +
					 LEFT(@Barcode + REPLICATE(' ',50),50) +
					 LEFT(@DefectCode + REPLICATE(' ',20),20) +
					 LEFT(CONVERT(VARCHAR,@DefectQty) + REPLICATE(' ',10),10) +
					 LEFT(@DRIExtText02 + REPLICATE(' ',400),400)+
					 LEFT(@MarKingCode + REPLICATE(' ',20),20)
					 +LEFT(@DefectCauseID + REPLICATE(' ',100),100)
					

	
	EXEC usp_DoProcessTerminalData	@pProcessUserID = @pProcessUserID,
												@pProcessLanguage = @pProcessLanguage,
												@pIPAddress = @MachineID,
												@pData = @Data
	
	
---- START  : 2020.04.13 (채민수대리 요청사항 - 같은 불량코드로 중복불량되지 않도록 개선)  --> TEST : VJKM102R710613
--DECLARE @CN            INT                                                                    -- 2020.04.28 변수추가
	
----: 불량코드 갯수가 2개이상인 경우의 데이터가 있을때 체크
					
--			SELECT  @CN =  COUNT(K.CN) 
--			FROM 
--			(
--					SELECT Count(DefectCode) AS CN							
--					FROM                       STB_DefectRepairInfo SD
--							LEFT OUTER JOIN STB_SETINFO SS            ON SS.ControlNo = SD.ControlNo
--					Where  1=1 								
--						AND FindRouteCode = @RouteCode
--						AND FindLineCode = @LineCode
--						AND SS.BARCODE = @Barcode			   
--					Group by DefectCode		
--					Having Count(DefectCode) >= 2
--                ) 	K
             
--		IF  @CN > 0
--	BEGIN
--			RAISERROR(' 이미 같은 불량코드로 등록되었습니다. 중복등록이 불가합니다.' ,16, 1)     
--			RETURN
--	END			   
-- ---- END -----------------------------------------------------------------------------------------------------------------------------------------------------
		
END