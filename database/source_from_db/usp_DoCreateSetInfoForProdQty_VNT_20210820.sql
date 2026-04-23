-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리 > 조립일일생산계획 > Lot생성버튼
-- Description: 생산 제품(Lot)을 생성합니다
-- Modified: Add Module Logic #210216


-- =============================================
Create PROCEDURE [dbo].[usp_DoCreateSetInfoForProdQty_VNT_20210820]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pPONo VARCHAR(20),
	@pDayPlanNo VARCHAR(20) = NULL,
	@pLotCount INT = NULL,
	@pCompanyCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo
	DECLARE @LotCount INT = @pLotCount
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN @pCompanyCode IS NULL THEN 'VNT' ELSE @pCompanyCode END
	DECLARE @FirstString        VARCHAR(10) = CASE WHEN @CompanyCode = 'VNT' THEN 'VJ' ELSE 'VV' END

	DECLARE @PlanQty NUMERIC(20,5)
	DECLARE @ProdCount INT
	DECLARE @RemainQty NUMERIC(20,5)
	DECLARE @Row INT = 1

	DECLARE @Barcode VARCHAR(50)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @Volt VARCHAR(20)
	DECLARE @Capacity VARCHAR(20)
	DECLARE @Header VARCHAR(20)
	DECLARE @Year INT
	DECLARE @Month INT
	DECLARE @YearCode VARCHAR(1)
	DECLARE @MonthCode VARCHAR(1)
	--DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE())),2)             --- SELECT  RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE()+1)),2) 

	--DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)
	DECLARE @SerialNo INT
	DECLARE @ErrorMsg NVARCHAR(MAX)

	DECLARE @PlanDate DATE

	-- #210216
	DECLARE @MaterialTypeCode VARCHAR(20)


	SELECT
			@MaterialCode = DPP.MaterialCode,
			@PlanQty = DPP.PlanQty,
			@ProdCount = DPP.PlanQty / @LotCount,
			@RemainQty = DPP.PlanQty % @LotCount,
			@Volt = MBI.MBIExtText01,
			@Capacity = MBI.MBIExtText02,
			@PlanDate = DPP.PlanDate
	FROM
			STB_DayProdPlan DPP                                                                                                              -- SELECT * FROM STB_DayProdPlan WHERE 
			LEFT OUTER JOIN STB_ModelBasicInfo MBI				ON MBI.ModelCode = DPP.MaterialCode
	WHERE
			DPP.DayPlanNo = @DayPlanNo

	-- #210216
	SELECT @MaterialTypeCode = MaterialTypeCode
	  FROM STB_MaterialMaster
	 WHERE MaterialCode = @MaterialCode

	--#210216 제품유형이 모듈인 경우 Lot번호에 M을 추가함. Material Type = 'MDL' -> Add Module Char 'M'
	IF @MaterialTypeCode = 'MDL' BEGIN
		SET @FirstString = 'M' + @FirstString
	END 

	-- Lot 번호의 날짜 생성 기준을 현재일에서 계획일로 변경
	DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)

	-- Lot 번호의 년, 월 생성 기준도 현재일에서 계획일로 변경 2020.03.03 By Jackaroe
	SET @Year = DATEPART(YEAR,@PlanDate)
	SET @Month = DATEPART(MONTH,@PlanDate)
	SET @MonthCode = CHAR(@Month + 73)	-- 1월이 J부터 시작

	IF EXISTS (
					SELECT	1
					FROM
							STB_SetInfo SI
					WHERE
							SI.DayPlanNo = @DayPlanNo
			     ) 

		 --   BEGIN
			--SET @ErrorMsg = '^이미 Lot를 생성하였습니다^ [' + @DayPlanNo + ']'                           -- 원본백업
			--EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
			--RETURN

		BEGIN
			SET @ErrorMsg = '^이미 Lot를 생성하였습니다^ [' + @DayPlanNo + ']'                           -- 2020.04.07 ^추가하고 String 리소스관리에 추가 (kilee)
			EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
		RETURN

	END


	-- 원본백업 (2020.04.07) 주석처리

	--IF ISNULL(@Volt,'') = '' BEGIN
	--		SET @ErrorMsg = '^전압 기준정보가 입력되지 않았습니다^ [' + @MaterialCode + ']'             
	--		EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
	--		RETURN
	--END

	--IF ISNULL(@Capacity,'') = '' BEGIN
	--		SET @ErrorMsg = '^용량 기준정보가 입력되지 않았습니다^ [' + @MaterialCode + ']'              
	--		EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
	--		RETURN
	--END

	IF ISNULL(@Volt,'') = '' 
		BEGIN
				SET @ErrorMsg = '^전압 기준정보가 입력되지 않았습니다^'             -- 2020.04.07 ^추가하고 String 리소스관리에 추가 (kilee)
				EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
				RETURN
		END

	IF ISNULL(@Capacity,'') = '' 
		BEGIN
				SET @ErrorMsg = '^용량 기준정보가 입력되지 않았습니다^'              -- 2020.04.07 ^추가하고 String 리소스관리에 추가 (kilee)
				EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
				RETURN
		END

	SELECT
			@YearCode = YI.YearCode
	FROM
			STB_YearInfo YI WITH(NOLOCK)
	WHERE
			YI.Year = @Year

	IF @RemainQty > 0 BEGIN
			SET @ProdCount = @ProdCount + 1
	END

	WHILE @ProdCount >= @Row BEGIN
			IF @ProdCount = @Row AND @RemainQty > 0 
			
			BEGIN
					SET @LotCount = @RemainQty
			END

			--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode + CONVERT(VARCHAR(3),@Thickness) + RIGHT('00' + CONVERT(VARCHAR,@MixBatchNo),2) + @EDLC
			--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode       -- 09.01 주석처리
			-- 전주본사와 베트남법인의 조립Lot을 구분하기 위해 추가함. 2019.09.26 by Jackaroe
			SET @Header = @FirstString + @YearCode + @MonthCode + @DayCode + @Volt + @Capacity       -- 밑에서 이동

			EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
															@pMaterialCode = '',
															@pHeader = @Header,
															@pSerialNo = @SerialNo OUTPUT

			--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode + @Volt + @Capacity
			SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2)          -- SELECT RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2)

			EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,
												@pProcessLanguage = @pProcessLanguage,
												@pPONo = @PONo,
												@pDayPlanNo = @DayPlanNo,
												@pProdQty = @LotCount,
												@pBarcode = @Barcode

			SET @Row = @Row + 1
	END	
END
