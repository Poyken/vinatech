-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리 > 코팅롤 일일생산계획 > 제조번호정보 저장시(Lot복사부분)  
-- 호출전 프로시저 "usp_SetInfo_iud_VNT"에서 호출됨 (Check Logic부분)

-- Description: 생산 코팅롤(Lot)을 생성합니다
-- 2020-10-30 CompanyCode 추가
-- 2021-12-20 Kangs추가 (소재생산부문)    ※ 비슷한 프로시저 : usp_DoCreateSetInfoForProdQty_VNT

-- Modified:  [usp_DoCreateSetInfoForCoatingRoll_VNT] '', '', '211202000010', '2021120800046', 5, 'VNT'
-- =============================================
Create PROCEDURE [dbo].[usp_DoCreateSetInfoForCoatingRoll_VNT_20211220]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pPONo VARCHAR(20),
					@pDayPlanNo VARCHAR(20) = NULL,
					@pProdQty NUMERIC(20,5) = NULL,
					@pThickness NUMERIC(20,5) = NULL,
					@pMixBatchNo INT = NULL,
					@pEDLC VARCHAR(1) = NULL,
					@pCompanyCode VARCHAR(20) = NULL   --추가
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @Thickness NUMERIC(20,5) = @pThickness
	DECLARE @MixBatchNo INT = @pMixBatchNo
	DECLARE @EDLC VARCHAR(1) = @pEDLC

	DECLARE @Barcode VARCHAR(50)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @Header VARCHAR(20)
	DECLARE @Year INT = DATEPART(YEAR,GETDATE())
	DECLARE @Month INT = DATEPART(MONTH,GETDATE())
	DECLARE @YearCode VARCHAR(1)
	DECLARE @MonthCode VARCHAR(1) = CHAR(@Month + 73)	-- 1월이 J부터 시작
	DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE())),2)
	DECLARE @SerialNo INT
	DECLARE @StrThickness VARCHAR(3) = CONVERT(VARCHAR(3),CONVERT(INT,@Thickness))
	DECLARE @ErrorMessage NVARCHAR(500)

	DECLARE @CompanyCode VARCHAR(20) = @pCompanyCode 
	DECLARE @FirstString CHAR(2) = CASE WHEN @CompanyCode = 'VNT' THEN 'VJ' ELSE 'VV' END         -- 추가

	--계획일자 기준의 Lot번호 생성을 위해 추가 , 김전식 셀장 요청 by Jackaroe #210520
	Declare @PlanDate DATE 

	SELECT @PlanDate = PlanDate
	  FROM STB_DayProdPlan
	 WHERE DayPlanNo = @pDayPlanNo

	-- 년, 월, 일을 새로 세팅함. #210520
	SET @Year = DATEPART(YEAR,@PlanDate)
	SET @Month = DATEPART(MONTH,@PlanDate)
	SET @MonthCode = CHAR(@Month + 73)
	SET @DayCode = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)


	IF LEN(@StrThickness) <> 3
	 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage,
																'^두께를 확인하세요^',
																@ErrorMessage OUTPUT
			SET @ErrorMessage = @ErrorMessage + ' [%s]'
			RAISERROR(@ErrorMessage,16,1,@StrThickness)
			RETURN
	END

	SELECT
			@MaterialCode = POI.MaterialCode
	FROM
			STB_ProductionOrderInfo POI WITH(NOLOCK)
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)				ON MM.MaterialCode = POI.MaterialCode
	WHERE
			POI.PONo = @PONo

	SELECT
			@YearCode = YI.YearCode
	FROM
			STB_YearInfo YI WITH(NOLOCK)
	WHERE
			YI.Year = @Year

	--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode + CONVERT(VARCHAR(3),@Thickness) + RIGHT('00' + CONVERT(VARCHAR,@MixBatchNo),2) + @EDLC
	--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode
	SET @Header = @FirstString  + @YearCode + @MonthCode + @DayCode         -- 2020.10.30 추가

	EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
														@pMaterialCode = '',
														@pHeader = @Header,
														@pSerialNo = @SerialNo OUTPUT
	
	--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode + @StrThickness + RIGHT('00' + CONVERT(VARCHAR,@MixBatchNo),2) + @EDLC
	SET @Header = @FirstString + @YearCode + @MonthCode + @DayCode + @StrThickness + RIGHT('00' + CONVERT(VARCHAR,@MixBatchNo),2) + @EDLC 
	SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)),2)
			
	DECLARE @ControlNo VARCHAR(20)	
	
	EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,
								@pProcessLanguage = @pProcessLanguage,
								@pPONo = @pPONo,
								@pDayPlanNo = @pDayPlanNo,
								@pProdQty = @pProdQty,
								@pBarcode = @Barcode,
								@pSIExtText01 = '',
								@pControlNo = @ControlNo OUTPUT

	UPDATE	STB_SetInfo
	SET
			SIExtReal03 = @Thickness
	WHERE
			ControlNo = @ControlNo

END
