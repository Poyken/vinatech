-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-08-01
-- Browsable : true
-- Group : 생산관리 > 조립일일생산계획 > Lot생성버튼
-- Description: 생산 제품(Lot)을 생성합니다
-- Modified: Add Module Logic #210216
-- 2021.12.10 kilee추가

-- 프로시저 실행 :  usp_DoCreateSetInfoForProdQty_VNT '', '', '211202000010', '2021120800046', 5, 'VNT'

-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateSetInfoForProdQty_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pPONo VARCHAR(20),                                          -- 생산지시번호
	@pDayPlanNo VARCHAR(20) = NULL,                          -- 일일생산계획번호
	@pLotCount NUMERIC(20,5) = NULL,
	@pCompanyCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @DayPlanNo VARCHAR(20) = @pDayPlanNo
	DECLARE @LotCount NUMERIC(20,5) = @pLotCount
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN @pCompanyCode IS NULL THEN 'VNT' ELSE @pCompanyCode END
	
	DECLARE @FirstString        VARCHAR(10) = CASE WHEN @CompanyCode = 'VNT' THEN 'VJ' ELSE 'VV' END                             -- 본사, 법인 구분

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


	DECLARE @Y  VARCHAR(4)   -- 2021.12.08 추가
	DECLARE @M VARCHAR(2)   -- 2021.12.08 추가
	DECLARE @D  VARCHAR(2)   -- 2021.12.08 추가


	DECLARE @YearCode VARCHAR(1)
	DECLARE @MonthCode VARCHAR(1)
	DECLARE @MonthCode2 VARCHAR(1)  -- 2021.12.08 추가

	--DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE())),2)             --- SELECT  RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,GETDATE()+1)),2) 
	--DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)
	--DECLARE @SerialNo INT
	DECLARE @SerialNo VARCHAR(20)
	DECLARE @ErrorMsg NVARCHAR(MAX)

	DECLARE @PlanDate DATE

	-- #210216
	DECLARE @MaterialTypeCode VARCHAR(20)
	DECLARE @WorkCenter        VARCHAR(20)

	-- Week, BE Part Number
	Declare @Week CHAR(2)
	Declare @BloomEnergyPartNumber VARCHAR(10)

	-- Bloom Energy BOM Revision
	Declare @BloomEnergyBOMRevision VARCHAR(10)

	SELECT
			@MaterialCode = DPP.MaterialCode,
			@PlanQty = DPP.PlanQty,
			@ProdCount = DPP.PlanQty / @LotCount,
			@RemainQty = DPP.PlanQty % @LotCount,
			@Volt = MBI.MBIExtText01,
			@Capacity = MBI.MBIExtText02,
			@PlanDate = DPP.PlanDate,
			@WorkCenter = Dpp.WorkCenterCode
	FROM
			STB_DayProdPlan DPP                                                                                                              -- SELECT * FROM STB_DayProdPlan WHERE 
			LEFT OUTER JOIN STB_ModelBasicInfo MBI				ON MBI.ModelCode = DPP.MaterialCode
	WHERE
			DPP.DayPlanNo = @DayPlanNo

	-- @BloomEnergyPartNumber
	SELECT @BloomEnergyPartNumber = MaterialName
	  FROM STB_MaterialMaster
	 WHERE MaterialCode = @MaterialCode

	-- BloomEnergy BOM Revision
	IF @MaterialCode IN ('EDVTSY-001') BEGIN
		SELECT TOP 1 @BloomEnergyBOMRevision = LEFT(CustomerRevision + '0', 2)
		  FROM STB_BomRevision_Map
		 WHERE MaterialCode = @MaterialCode
		 ORDER BY CreateDateTime DESC
	END ELSE BEGIN
		SELECT TOP 1 @BloomEnergyBOMRevision = LEFT(Revision + '0', 2)
		  FROM STB_MaterialRevision
		 WHERE MaterialCode = @MaterialCode
		 ORDER BY CreateDateTime DESC
	END

	 -- 2026-04-08 Mr.Manh update for Nordex product (following Mr.Nhiem's request)
	 IF @MaterialCode IN ('EDVTMD-246', 'EDVTMD-246-001', 'EDVTMD-246-002', 'EDVTMD-246-003')
		 BEGIN
			SET @BloomEnergyPartNumber = '35335'
		END

	-- @Week
	SELECT @Week = RIGHT('0' + CONVERT(VARCHAR(10), DATEPART(ISO_WEEK, @PlanDate)), 2)

/*

SELECT
			 DPP.MaterialCode,
			 DPP.PlanQty,
			-- DPP.PlanQty / @LotCount,
			--DPP.PlanQty % @LotCount,
			MBI.MBIExtText01,
			 MBI.MBIExtText02,
			 DPP.PlanDate,                            --> 계획일자
			 Dpp.WorkCenterCode
	FROM
			STB_DayProdPlan DPP                                                                                                              -- SELECT * FROM STB_DayProdPlan WHERE 
			LEFT OUTER JOIN STB_ModelBasicInfo MBI				ON MBI.ModelCode = DPP.MaterialCode
	WHERE
			DPP.DayPlanNo = '2021120800046'   -- 일일생산계획번호임

*/


    /* 주석부분
	
	SELECT
			DPP.MaterialCode,                  -- @MaterialCode
			DPP.PlanQty,                         -- @PlanQty = 
			--DPP.PlanQty / @LotCount,        -- @ProdCount =
			--DPP.PlanQty % @LotCount,       -- @RemainQty =
			MBI.MBIExtText01,                  -- @Volt = 
			MBI.MBIExtText02,                  -- @Capacity =
			DPP.PlanDate ,                       -- @PlanDate = 
			 Dpp.WorkCenterCode     -- @WorkCenter =
	FROM
			STB_DayProdPlan DPP                                                                                                              -- SELECT * FROM STB_DayProdPlan where materialCode =  'MAVTPF-001'
			LEFT OUTER JOIN STB_ModelBasicInfo MBI				ON MBI.ModelCode = DPP.MaterialCode
	WHERE
			DPP.DayPlanNo = '2021120200054'

	*/



	-- #210216
	SELECT @MaterialTypeCode = MaterialTypeCode
	  FROM STB_MaterialMaster
	 WHERE MaterialCode = @MaterialCode

	--#210216 제품유형이 모듈인 경우 Lot번호에 M을 추가함. Material Type = 'MDL' -> Add Module Char 'M'
	IF @MaterialTypeCode = 'MDL' 
	
	BEGIN
	   SET @FirstString = 'M' + @FirstString
	END 


	--- 2021.12.07 추가  (MEA소재)
	IF  @WorkCenter = 'VNT_F2'  --And @MaterialCode = 'MAVTPF-001' 

	BEGIN
	    SET @FirstString = 'MEA'
	END 


	--- 2021.08.20 추가 -- 
	-- It is no longer produced in VJ 2023.08.25
	/*
	IF  @FirstString = 'VV' And @MaterialCode = 'ECVT27-369'    -- 헬라바코드 예외처리

	BEGIN
	    SET @FirstString = 'VJ'
	END 
	*/

	-- Lot 번호의 날짜 생성 기준을 현재일에서 계획일로 변경
	DECLARE @DayCode VARCHAR(2) = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)         

	-- select RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,getdate())),2)

	-- Lot 번호의 년, 월 생성 기준도 현재일에서 계획일로 변경 2020.03.03 By Jackaroe
	SET @Year    = DATEPART(YEAR,@PlanDate)                      -- Select DATEPART(YEAR,Getdate())        
	SET @Month = DATEPART(MONTH,@PlanDate)                   -- Select DATEPART(MONTH,Getdate())          
	SET @MonthCode = CHAR(@Month + 73)	-- 1월이 J부터 시작    -- select CHAR('1'+ 64)

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
			SET @ErrorMsg = '이미 Lot를 생성하였습니다 [' + @DayPlanNo + ']' -- 2020.04.07 ^추가하고 String 리소스관리에 추가 (kilee) DayPlanNo가 메시지에 포함되어 리소스 관리 불가함.
			EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
		RETURN

	END


	IF ISNULL(@Volt,'') = '' And @WorkCenter NOT IN ('VNT_F2', 'VVT_F3','VNT_F5', 'VVT_F4')  
		BEGIN
				SET @ErrorMsg = '전압 기준정보가 입력되지 않았습니다'             -- 2020.04.07 ^추가하고 String 리소스관리에 추가 (kilee) -- usp_RaiseLocalizedError 내에서 ^를 추가하고 있음.
				EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
				RETURN
		END

	IF ISNULL(@Capacity,'') = '' And @WorkCenter NOT IN ('VNT_F2', 'VVT_F3','VNT_F5', 'VVT_F4')  
		BEGIN
				SET @ErrorMsg = '용량 기준정보가 입력되지 않았습니다'   -- 2020.04.07 ^추가하고 String 리소스관리에 추가 (kilee) -- usp_RaiseLocalizedError 내에서 ^를 추가하고 있음.
				EXEC usp_RaiseLocalizedError @pProcessLanguage, @ErrorMsg
				RETURN
		END


	SELECT @YearCode = YI.YearCode
	        
	FROM STB_YearInfo YI WITH(NOLOCK)
	WHERE 1=1
		AND YI.Year = @Year

    /*
		SELECT   YI.YearCode, *
			FROM STB_YearInfo YI WITH(NOLOCK)
			WHERE 1=1
		AND YI.Year = 2021
	*/

	IF @RemainQty > 0 
	
	BEGIN
			SET @ProdCount = @ProdCount + 1
	END

	WHILE @ProdCount >= @Row 
	
	BEGIN

			IF @ProdCount = @Row AND @RemainQty > 0 
			
			BEGIN
					SET @LotCount = @RemainQty
			END


--- // 2021.12.07 추가  (MEA소재생산부문) Start  // -----------------------------------------------------------------------------------

			    -- Lot 번호의 년, 월 생성 기준도 현재일에서 계획일로 변경 2021.12.03 By Kangs   (윗부분이랑 헷갈리지 말것!!)
					--SET @Y = DATEPART(YEAR,@PlanDate)         -- Select DATEPART(YEAR,Getdate())        
					--SET @M = DATEPART(MONTH,@PlanDate)    -- Select DATEPART(MONTH,Getdate())        
					--SET @D = DATEPART(DAY,@PlanDate)          -- Select DATEPART(Day,Getdate())        
					--SET @MonthCode2 = CHAR(@Month + 64)	  -- 1월 A부터 시작
					SET @Y = RIGHT(DATEPART(YEAR,@PlanDate), 2)         -- Select DATEPART(YEAR,Getdate())        
					SET @M = RIGHT('00' + CONVERT(VARCHAR,DATEPART(MONTH,@PlanDate)),2)
					SET @D = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)
				

					Print @MonthCode2       -- 주석 처리해도 됨

			  IF  @WorkCenter IN ('VNT_F2', 'VNT_F5')  -- 소재생산의 경우 LotNo 체제

					BEGIN

					   --SET @Header = Right(@Y, 2) + @M + @D + '-' + Right(@Y, 2) + @MonthCode2 + @D   --2021.12.28 Y년도부분 두자리로 변경
					   SET @Header = @Y + @M + @D + '-'  --2022.08.10
					
					Print @Header       -- 주석 처리해도 됨

							-- 뒷번호 조립
							EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
																			@pMaterialCode = '',
																			@pHeader = @Header,
																			@pSerialNo = @SerialNo OUTPUT


							--SET @Barcode = @Header + '-' + RIGHT('0' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 1)         -- Ex)  202111-1    -- 1. 코팅 날짜 (2021-연도, 11-월)  2. 시퀀스번호  (원본백업)
							--SET @Barcode = @Header                                                                                            -- 2021.12.28
							SET @Barcode = @Header + RIGHT('0000' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 4)										--2022.08.10
							

							EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,
														@pProcessLanguage = @pProcessLanguage,
														@pPONo = @PONo,
														@pDayPlanNo = @DayPlanNo,
														@pProdQty = @LotCount,
														@pBarcode = @Barcode

						SET @Row = @Row + 1

				END 
 ---  소재생산 추가된부분 End // --------------------------------------------------------------------------------------------------------------------------------------------------------------------

				-- P/S부문 추가
			IF  @WorkCenter = 'VNT_F3' OR (@WorkCenter = 'VVT_F4' AND @MaterialCode IN ('EDVTMD-246', 'EDVTMD-246-001', 'EDVTMD-246-002', 'EDVTMD-246-003')) BEGIN
				IF @MaterialCode <> 'EDVTMD-246' BEGIN
					SET @Header = @YearCode + @MonthCode + @DayCode
				END ELSE BEGIN
					SET @Header = CONVERT(CHAR(8), @PlanDate, 112)
				END

				-- 뒷번호 조립
				EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
																		@pMaterialCode = '',
																		@pHeader = @Header,
																		@pSerialNo = @SerialNo OUTPUT

				SET @Barcode = @Header + RIGHT('000' + @SerialNo, 3)

				EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,
											@pProcessLanguage = @pProcessLanguage,
											@pPONo = @PONo,
											@pDayPlanNo = @DayPlanNo,
											@pProdQty = @LotCount,
											@pBarcode = @Barcode

				SET @Row = @Row + 1
			END 






			IF  @WorkCenter = 'VVT_F3' BEGIN -- 베트남 하남공장 추가
			       -- Mr. Trieu changed the lot naming rules for the Ha Nam factory.
				    DECLARE @IsREwork NVARCHAR(100)
					DECLARE @Prefix NVARCHAR(10)
				    SET @Y = RIGHT(DATEPART(YEAR,@PlanDate), 2)
				    select @IsREwork=BomVersion from  STB_DayProdPlan where DayPlanNo=@DayPlanNo
					SET @Prefix = CASE @IsREwork
                      WHEN 'RW' THEN 'RW'    -- Trường hợp Rework
                      WHEN 'SP' THEN 'SP'    -- Trường hợp là hàng mẫu bên R&D với bên a Nam
                      ELSE 'VE'              -- Trường hợp mặc định 
                    END
					SET @Header = @Prefix + @Y + @M + @D + '-'
					/*
					if(@IsREwork='RW')
					BEGIN
					   SET @Header = 'RW' + @Y + @M + @D + '-'  --2025.12.23
					END
					ELSE
					BEGIN
					   SET @Header = 'VE' + @Y + @M + @D + '-'  --2022.08.10
					END
					*/
					-- 뒷번호 조립
					EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
														@pMaterialCode = '',
														@pHeader = @Header,
														@pSerialNo = @SerialNo OUTPUT


					SET @Barcode = @Header + RIGHT('000' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 3)										--2022.08.10
					
					EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,
												@pProcessLanguage = @pProcessLanguage,
												@pPONo = @PONo,
												@pDayPlanNo = @DayPlanNo,
												@pProdQty = @LotCount,
												@pBarcode = @Barcode

						SET @Row = @Row + 1

			END 

			-- Mr.Manh Test for Bac Giang 2
			IF  @WorkCenter = 'VVT_F4' AND  @MaterialCode NOT IN ('EDVTMD-246', 'EDVTMD-246-001', 'EDVTMD-246-002', 'EDVTMD-246-003') BEGIN -- 베트남 하남공장 추가
				    PRINT '1'
					
					SET @Y = RIGHT(DATEPART(YEAR,@PlanDate), 2)


					-- 2026-04-08 Mr.Manh update for Nordex product (following Mr.Nhiem's request)
					IF @MaterialCode IN ('EDVTSY-001')
						BEGIN
							SET @Header = 'VH-' + @BloomEnergyPartNumber
						END
					ELSE
						BEGIN
							SET @Header = 'K' + @BloomEnergyPartNumber  --2026.02.21  -- Just test, can change in the future, 2026.03.26 change by Jackaroe
						END

					PRINT '@Header ::: ' + @Header

					
					-- 뒷번호 조립
					EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
														@pMaterialCode = '',
														@pHeader = @Header,
														@pSerialNo = @SerialNo OUTPUT

					PRINT '@SerialNo ::::: ' + @SerialNo


					IF @MaterialCode NOT IN ('EDVTSY-001') BEGIN -- PCBA, SCM
						SET @Barcode = @Header + @BloomEnergyBOMRevision + @Y + @Week + RIGHT('00000' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 5)	

						PRINT 'K% ::::: ' + @Barcode
					END ELSE BEGIN -- SL7
						SET @Barcode = @Header + '-' + RIGHT('00000' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 6) + '-' + @Week + @Y + '-' + LEFT(@BloomEnergyBOMRevision, 1)
						PRINT 'VH% ::::: ' + @Barcode
					END
					
					EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,
												@pProcessLanguage = @pProcessLanguage,
												@pPONo = @PONo,
												@pDayPlanNo = @DayPlanNo,
												@pProdQty = @LotCount,
												@pBarcode = @Barcode

						SET @Row = @Row + 1

			END

			IF  @WorkCenter NOT IN ('VNT_F2', 'VNT_F3', 'VVT_F3', 'VNT_F5', 'VVT_F4')    -- 소재생산, P/S부문이 아닌경우  (기존부분) 2023.07.17 P/S부문 추가 By Jackaroe 2024.07.25 하남공장 추가
			 Begin    -- 2021.12.08 추가
			 
			SET @Header = @FirstString + @YearCode + @MonthCode + @DayCode + @Volt + @Capacity       -- 밑에서 이동

			PRINT '@Header ::::: ' + @Header

			--raiserror(@Capacity,16,1)
			--return
			-- 뒷번호 조립
			--EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
			--												@pMaterialCode = '',
			--												@pHeader = @Header,
			--												@pSerialNo = @SerialNo OUTPUT

			-- New Create Number Logic 2024.04.12 By Jackaroe
			EXEC usp_GetNewSerialNoForBarcodeUsingString	@pProcessUserID = @pProcessUserID,
															@pMaterialCode = '',
															@pHeader = @Header,
															@pSerialNo = @SerialNo OUTPUT
			
			--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode + @Volt + @Capacity
			SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2)          -- SELECT RIGHT('00' + CONVERT(VARCHAR,ISNULL(@SerialNo,0)), 2)

			PRINT '@Barcode ::::: ' + @Barcode


			--raiserror(@Volt,16,1)
			--return
			EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,
												@pProcessLanguage = @pProcessLanguage,
												@pPONo = @PONo,
												@pDayPlanNo = @DayPlanNo,
												@pProdQty = @LotCount,
												@pBarcode = @Barcode

			SET @Row = @Row + 1

		End -- 2021.12.08 추가

	END	
	
END


