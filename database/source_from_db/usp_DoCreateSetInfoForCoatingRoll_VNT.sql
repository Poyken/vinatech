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
CREATE PROCEDURE [dbo].[usp_DoCreateSetInfoForCoatingRoll_VNT]
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pPONo VARCHAR(20),
					@pDayPlanNo VARCHAR(20) = NULL,
					@pProdQty NUMERIC(20,5) = NULL,
					@pThickness NUMERIC(20,5) = NULL,
					@pMixBatchNo INT = NULL,
					@pEDLC VARCHAR(10) = NULL,
					@pCompanyCode VARCHAR(20) = NULL   --추가
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @PONo VARCHAR(20) = @pPONo
	DECLARE @Thickness NUMERIC(20,5) = @pThickness
	DECLARE @MixBatchNo INT = @pMixBatchNo
	DECLARE @EDLC VARCHAR(10) = @pEDLC

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

	-- ED-VJPMTR000000018
	Declare @UserWorkCenterCode VARCHAR(20)

	DECLARE @PlanDate  DATE   -- 계획일자 기준의 Lot번호 생성을 위해 추가 , 김전식 셀장 요청 by Jackaroe #210520

 -- [소재생산부분때문에 추가된 부분] (2021-12-20)
	DECLARE @WorkCenterCode  VARCHAR(20)    --  2021-12-20 추가 (소재생산)	
	DECLARE @Y  VARCHAR(4)					--  2021-12-20 추가 (소재생산)	
	DECLARE @M VARCHAR(2)                  --  2021-12-20 추가 (소재생산)	
	DECLARE @D  VARCHAR(2)                  --  2021-12-20 추가 (소재생산)	
	DECLARE @MonthCode2 VARCHAR(1)     -- 2021.12.20 추가 (소재생산)		
	DECLARE @ProductGroupCode VARCHAR(20)
	-- [소재생산부분때문에 추가된 부분] (2021-12-20)



	SELECT @PlanDate = DPP.PlanDate
	      ,@WorkCenterCode = DPP.WorkCenterCode		--  2021-12-20 추가 (소재생산)
		  ,@MaterialCode = DPP.MaterialCode			--  2021-12-20 추가 (소재생산)
		  ,@ProductGroupCode = MM.ProductGroupCode	--  2022-08-12
	  FROM STB_DayProdPlan DPP WITH(NOLOCK)
	  LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
		ON DPP.MaterialCode = MM.MaterialCode
	 WHERE DayPlanNo = @pDayPlanNo

	 -- ED-VJPMTR000000018
	 SELECT @UserWorkCenterCode = WorkCenterCode
	   FROM STB_UserInfo
	  WHERE UserID = @pProcessUserID



	 --- 2021.12.20 추가  (MEA소재)
		IF  @WorkCenterCode = 'VNT_F2'  

		BEGIN
			SET @FirstString = 'MEA'
		END 


	-- 년, 월, 일을 새로 세팅함. #210520
	SET @Year = DATEPART(YEAR,@PlanDate)
	SET @Month = DATEPART(MONTH,@PlanDate)
	SET @MonthCode = CHAR(@Month + 73)
	SET @DayCode = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)



	IF @WorkCenterCode = 'VNT_F1' AND LEN(@StrThickness) < 1    -- 두께가 세자리수인듯 --2022.08. 10  조건에 Workcenter 추가

	 BEGIN
			EXEC SmartFramework.dbo.usp_GetAddonStringResource	@pProcessLanguage, '^두께를 확인하세요^',	@ErrorMessage OUTPUT
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


--- // 2021.12.20 추가  (MEA소재생산부문) Start  // -----------------------------------------------------------------------------------
-- 1. 코팅롤 양극일경우
			    -- Lot 번호의 년, 월 생성 기준도 현재일에서 계획일로 변경 2021.12.03 By Kangs   (윗부분이랑 헷갈리지 말것!!)
					--SET @Y = DATEPART(YEAR,@PlanDate)         -- Select DATEPART(YEAR,Getdate())        
					--SET @M = DATEPART(MONTH,@PlanDate)    -- Select DATEPART(MONTH,Getdate())        
					--SET @D = DATEPART(DAY,@PlanDate)          -- Select DATEPART(Day,Getdate())        
					--SET @MonthCode2 = CHAR(@Month + 64)	  -- 1월 A부터 시작
					SET @Y = RIGHT(DATEPART(YEAR,@PlanDate), 2)         -- Select DATEPART(YEAR,Getdate())        
					SET @M = RIGHT('00' + CONVERT(VARCHAR,DATEPART(MONTH,@PlanDate)),2)
					SET @D = RIGHT('00' + CONVERT(VARCHAR,DATEPART(DAY,@PlanDate)),2)

				
					--Print @MonthCode2       -- 주석 처리해도 됨

			  IF  @WorkCenterCode = 'VNT_F2'  AND @ProductGroupCode = 'ELECTRODE_CATHODE'     --  Cathode 전극

					BEGIN

					   --SET @Header = @Y + @M + @D + '-' + Right(@Y, 2) + @MonthCode2 + @D 
					   --SET @Header = Right(@Y, 2) + @M + @D + '-' + Right(@Y, 2) + @MonthCode2 + @D    -- 2021.12.28 수정
					   IF @MaterialCode IN ('MAVTPF-010-5', 'A-MAVTPF-010-5') BEGIN
							SET @Header = @Y + @M + @D + '-IC'    -- 이노셀 2024.07.12 by Jackaroe
					   END ELSE BEGIN
							SET @Header = @Y + @M + @D + '-C'    -- 2022.08.10 수정
						END
					
					   --Print @Header       -- 주석 처리해도 됨

					   EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
															@pMaterialCode = '',
															@pHeader = @Header,
															@pSerialNo = @SerialNo OUTPUT
	
					   --SET @Header = Right(@Y, 2) + @M + @D + '-C' + Right(@Y, 2) + @MonthCode2 + @D    -- 2021.12.28 수정
					   IF @MaterialCode IN ('MAVTPF-010-5', 'A-MAVTPF-010-5') BEGIN
							SET @Header = @Y + @M + @D + '-IC'    -- 이노셀 2024.07.12 by Jackaroe
					   END ELSE BEGIN
							SET @Header = @Y + @M + @D + '-C'    -- 2022.08.10 수정
						END

                		--SET @Barcode = @Header        --- Ex)  202111-1  -- 1. 양극코팅날짜 (21-연도, 11-월)   2. 순서    //  LU0201 2035-01
						SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR, ISNULL(@SerialNo,0)),2)    -- 두자리 시퀀스번호 설정  ---ex)220805-C01 > 22(year) + 08(월) + 05(일) - C(Cathode) + 01(serial)

						
						Print @Header  
                   End

--2. 코팅롤 음극일 경우

			  IF  @WorkCenterCode = 'VNT_F2'  AND @ProductGroupCode = 'ELECTRODE_ANODE'     -- Anode 전극

					BEGIN

					   IF @MaterialCode IN ('MAVTPF-010-4', 'A-MAVTPF-010-4') BEGIN
							SET @Header = @Y + @M + @D + '-IA'    -- 이노셀 2024.07.12 by Jackaroe
					   END ELSE BEGIN
							SET @Header = @Y + @M + @D + '-A'    -- 2022.08.10 수정
					   END
					
					   Print @Header       -- 주석 처리해도 됨

					   EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
																		@pMaterialCode = '',
																		@pHeader = @Header,
																		@pSerialNo = @SerialNo OUTPUT
	
			            IF @MaterialCode IN ('MAVTPF-010-4', 'A-MAVTPF-010-4') BEGIN
							SET @Header = @Y + @M + @D + '-IA'    -- 이노셀 2024.07.12 by Jackaroe
					   END ELSE BEGIN
							SET @Header = @Y + @M + @D + '-A'    -- 2022.08.10 수정
					   END

                		--SET @Barcode = @Header + RIGHT('0' + CONVERT(VARCHAR, ISNULL(@SerialNo,0)),1)    -- 한자리 시퀀스번호 설정
						SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR, ISNULL(@SerialNo,0)),2)    -- 두자리 시퀀스번호 설정
						
						Print @Header  
                   End

-----// 소재생산 추가된부분 End // --------------------------------------------------------------------------------------------------------------------------------------------------------------------

  
-- 원래있던부분!!
      IF  @WorkCenterCode <> 'VNT_F2'    -- 소재생산이 아닌경우  (기존부분)

	   Begin    -- 2021.12.20 추가

			--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode + CONVERT(VARCHAR(3),@Thickness) + RIGHT('00' + CONVERT(VARCHAR,@MixBatchNo),2) + @EDLC
			--SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode

			-- ED-VJPMTR000000018
			IF @UserWorkCenterCode = 'VNT_F4' BEGIN
				SET @FirstString = 'VW'
			END

			SET @Header = @FirstString  + @YearCode + @MonthCode + @DayCode         -- 2020.12.20 추가     ex) 20211220-21L20-01

			EXEC usp_GetNewSerialNoForBarcode	@pProcessUserID = @pProcessUserID,
																@pMaterialCode = '',
																@pHeader = @Header,
																@pSerialNo = @SerialNo OUTPUT
				
			SET @Header = @FirstString + @YearCode + @MonthCode + @DayCode + RIGHT('0' + @StrThickness, 3) + RIGHT('00' + CONVERT(VARCHAR,@MixBatchNo),2) + RTRIM(@EDLC)
			SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR, ISNULL(@SerialNo,0)),2)    -- 두자리 시퀀스번호 설정

		 -- SET @Header = 'VJ' + @YearCode + @MonthCode + @DayCode + @StrThickness + RIGHT('00' + CONVERT(VARCHAR,@MixBatchNo),2) + @EDLC     -- 원본백업
		 -- SET @Barcode = @Header + RIGHT('00' + CONVERT(VARCHAR, ISNULL(@SerialNo,0)),2)                                                                               -- 원본백업

	    End  		   -- 2021.12.20 추가

			
			DECLARE @ControlNo VARCHAR(20)	
	
		
		    EXEC usp_DoCreateSetInfo	@pProcessUserID = @pProcessUserID,                        -- Lot생성 프로시저 호출부분
												@pProcessLanguage = @pProcessLanguage,
												@pPONo = @pPONo,
												@pDayPlanNo = @pDayPlanNo,
												@pProdQty = @pProdQty,
												@pBarcode = @Barcode,
												@pSIExtText01 = '',
												@pControlNo = @ControlNo OUTPUT

		UPDATE	STB_SetInfo
			 SET  SIExtReal03 = @Thickness
		 WHERE ControlNo = @ControlNo

END