-- ===================================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리
-- Description:	공용 검사이력을 추가 합니다.
-- Modified: 바코드 입력시
-- 2020.01.13  비고정보 업데이트 되도록 수정 (kilee)
-- 2020.01.13  

-- [프로시저 실행문]   EXEC usp_DoAddCommInspMeasureHistForBarcode_TEST    'kilee','Korean','20200104000051','20200104001441','',     '1.11','2.22','3.33','4.44','5.55','6.66','7.77','8.88','9.99','10.10'           , '' , '0705201'  , ''                                  

-- [데이터확인]               -- 테스트용 정보 : 바코드 :  VJJU032R750605 /  검사문서번호 : 20200104000051 /  공용검사항목이력번호 :  20200104001441
--SELECT MeasureSeq, *
--FROM STB_CommInspMeasureHist
--WHERE 1=1
--AND CommInspDocItemNo = @CommInspDocItemNo
--AND CommInspDocItemNo in ( '20200104001441')    --, '20191203001073')
-- ======================================================

Create PROCEDURE [dbo].[usp_DoAddCommInspMeasureHistForBarcode_TEST_20200121]
						@pProcessUserID         VARCHAR(20),
						@pProcessLanguage      VARCHAR(20),
						@pCommInspDocNo      VARCHAR(20) ,
						@pCommInspDocItemNo VARCHAR(20) ,
						@pTextMeasure            VARCHAR(50) ,

						@pMeasureValue01 NUMERIC(20,5) = Null,                        -- 2020.01.14 추가부분
						@pMeasureValue02 NUMERIC(20,5)= Null,
						@pMeasureValue03 NUMERIC(20,5)= Null,
						@pMeasureValue04 NUMERIC(20,5)= Null,
						@pMeasureValue05 NUMERIC(20,5)= Null,
						@pMeasureValue06 NUMERIC(20,5)= Null,
						@pMeasureValue07 NUMERIC(20,5)= Null,
						@pMeasureValue08 NUMERIC(20,5)= Null,
						@pMeasureValue09 NUMERIC(20,5)= Null,
						@pMeasureValue10 NUMERIC(20,5)= Null,

						--@pNumericMeasure NUMERIC(20,5),
						@pCheckDisplay BIT ,
						@pInspWorkerCode VARCHAR(20) =NULL,
						@pCIDHExtText02 VARCHAR(200) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID           VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage       VARCHAR(20) = @pProcessLanguage,
				@CommInspDocNo       VARCHAR(20) = @pCommInspDocNo,
				@CommInspDocItemNo  VARCHAR(20) = @pCommInspDocItemNo,
				@TextMeasure             VARCHAR(50) = @pTextMeasure,
			
				@MeasureValue01  NUMERIC(20,5) = @pMeasureValue01,                    -- 2020.01.14 추가부분
				@MeasureValue02  NUMERIC(20,5) = @pMeasureValue02,
				@MeasureValue03  NUMERIC(20,5) = @pMeasureValue03,
				@MeasureValue04  NUMERIC(20,5) = @pMeasureValue04,
				@MeasureValue05  NUMERIC(20,5) = @pMeasureValue05,
				@MeasureValue06  NUMERIC(20,5) = @pMeasureValue06,
				@MeasureValue07  NUMERIC(20,5) = @pMeasureValue07,
				@MeasureValue08  NUMERIC(20,5) = @pMeasureValue08,
				@MeasureValue09	 NUMERIC(20,5) = @pMeasureValue09,
				@MeasureValue10  NUMERIC(20,5) = @pMeasureValue10,

			--@NumericMeasure        NUMERIC(20,5) = @pNumericMeasure,

				@CheckDisplay             BIT = @pCheckDisplay,
				@InspWorkerCode         VARCHAR(20) = @pInspWorkerCode,
				@CIDHExtText02            VARCHAR(200) = @pCIDHExtText02

	DECLARE @Barcode                  VARCHAR(50)
	DECLARE @CommInspMeasureNo VARCHAR(20)
	DECLARE @IsAutoFinish              BIT
	DECLARE @IsFinished                 BIT
	DECLARE @ErrorMessage			  NVARCHAR(500)


	SELECT
			@IsFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode
	FROM
			                       STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_SetInfo                       SI		ON SI.ControlNo = CIDH.ProdNo
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo

	IF @IsFinished = 1    -- 저장버튼을 누르면


			BEGIN
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage,
																		'^이미 완료처리 되었습니다^',
																		@ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]'
					RAISERROR(@ErrorMessage,16,1,@Barcode)
					RETURN
			END
	
			--EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

	
	--DECLARE @cnt int   -- 2020.01.14 추가
 --   DECLARE @i    int

	-- 현재 버전확인
	--SELECT @i = MeasureSeq
	--FROM STB_CommInspMeasureHist
	--WHERE 1=1
	--  AND CommInspDocItemNo = @CommInspDocItemNo
	--  --AND CommInspDocItemNo = '20191203001073'
	--  AND MeasureSeq = '6'

	  ----가장높은 버전확인
	--  SELECT @cnt = Max(MeasureSeq)
	--FROM STB_CommInspMeasureHist
	--WHERE 1=1
	--  AND CommInspDocItemNo = @CommInspDocItemNo
	  --AND CommInspDocItemNo = '20200104001441'
	 -- AND MeasureSeq = '5'


	--   SELECT Max(MeasureSeq)
	--FROM STB_CommInspMeasureHist
	--WHERE 1=1
	--  --AND CommInspDocItemNo = @CommInspDocItemNo
	--  AND CommInspDocItemNo = '20200104001441'



	--  SELECT @cnt = COUNT(*)
	--FROM STB_CommInspMeasureHist
	--WHERE 1=1
	--  AND CommInspDocItemNo = @CommInspDocItemNo
	--  --AND CommInspDocItemNo = '20191203001073'


	 -- 바코드 : VJJU032R750604, 첫번째 행은 5번째 측정하고 6번째 측정할 차례
	 -- 	SELECT MeasureSeq, *
		--FROM STB_CommInspMeasureHist
		--WHERE 1=1
	 -- --AND CommInspDocItemNo = @CommInspDocItemNo
		--AND CommInspDocItemNo = '20191203001073'
		--AND MeasureSeq = '2'

	  --SET @i = 0

   -- WHILE(@i < @cnt)

   --BEGIN

   --SET @i = @i + 1

--END


	-- 2020.01.14  추가 (kilee) Start   -----------------------------------------
		--IF @MeasureValue_05  IS NOT NULL                                                 -- 5번측정값이 Null이 아니면
	 
		--	-- UpDate문
		--	BEGIN

		--	    UPDATE  STB_CommInspMeasureHist
		--			 SET NumericMeasure	 = @MeasureValue_01
		--			     , MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '1'

		--	   UPDATE  STB_CommInspMeasureHist
		--			 SET NumericMeasure	 = @MeasureValue_02
		--			     , MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '2'


		--	    UPDATE  STB_CommInspMeasureHist
		--			 SET NumericMeasure	 = @MeasureValue_03
		--			     , MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '3'

		--	   UPDATE  STB_CommInspMeasureHist
		--			 SET NumericMeasure	 = @MeasureValue_04
		--			     , MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '4'

		--		UPDATE  STB_CommInspMeasureHist
		--			 SET NumericMeasure	 = @MeasureValue_05
		--			     , MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo
		--		  --AND CommInspDocItemNo   = '20191203001073'
		--		  AND MeasureSeq = '5'

		--		  UPDATE  STB_CommInspMeasureHist
		--			 SET NumericMeasure	 = @MeasureValue_06
		--			     , MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '6'

		--		  UPDATE  STB_CommInspMeasureHist
		--			 SET  NumericMeasure	 = @MeasureValue_07
		--			     , MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '7'

		--		  UPDATE  STB_CommInspMeasureHist
		--			 SET  NumericMeasure	 = @MeasureValue_08
		--			     ,  MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '8'

		--		  UPDATE  STB_CommInspMeasureHist
		--			 SET  NumericMeasure	 = @MeasureValue_09
		--			     ,  MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '9'

		--		  UPDATE  STB_CommInspMeasureHist
		--			 SET  NumericMeasure	 = @MeasureValue_10
		--			     ,  MeasureDateTime = Getdate
		--				 , MeasureUserID = @ProcessUserID
		--		         , InspWorkerCode = @InspWorkerCode
		--		WHERE 1=1
		--		  AND CommInspDocItemNo = @CommInspDocItemNo				  
		--		  AND MeasureSeq = '10'

		--	END

		--END
	-- 2020.01.14  추가 (kilee) End

         
    --IF @cnt = 0 or @cnt IS NULL
	
	  
			BEGIN 

			-- 먼저 DELETE문
			DELETE FROM STB_CommInspMeasureHist
			WHERE 1=1
			AND CommInspDocItemNo = @CommInspDocItemNo		
			--AND CommInspDocItemNo = '20200104001441'           
		   END 


		   -- Insert문

		   -- 1.
		   BEGIN
		   			 
		   EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,
				--@NumericMeasure,
				@MeasureValue01,				
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			

			--2.
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			   VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue02,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			--

			--3. 
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue03,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			---

			--4. 
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue04,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			---

			--5. 
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue05,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			---

			--6. 
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue06,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			---

			--7. 
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue07,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			---

			--8. 
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue08,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			---

			--9. 
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue09,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			---

			--10. 
			BEGIN			

			EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

			INSERT INTO STB_CommInspMeasureHist
			(
				CommInspMeasureNo,
				CommInspDocItemNo,
				MeasureSeq,
				TextMeasure,
				NumericMeasure,
				MeasureResult,
				MeasureDateTime,
				MeasureUserID,
				InspWorkerCode
			)
			VALUES
			(
				@CommInspMeasureNo,
				@CommInspDocItemNo,
				(
					SELECT ISNULL(MAX(MeasureSeq), 0) + 1 FROM STB_CommInspMeasureHist CIMH WHERE CIMH.CommInspDocItemNo = @CommInspDocItemNo
				),
				@TextMeasure,				
				@MeasureValue10,
				CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,
				--CASE  WHEN @CheckDisplay = 1 THEN 'OK'			ELSE 'NG' 	END,
				GETDATE(),
				@ProcessUserID,
				@InspWorkerCode
			)
			END
			---
	END



	-- 2020.01.13 비고정보 추가 (kilee) Start   -->   Select CIDHExtText02,  * from STB_CommInspDocHistory where CommInspDocNo = '20191203000049'
		IF @CIDHExtText02 IS NOT NULL  OR @CIDHExtText02 = ''
	
		BEGIN

			UPDATE  STB_CommInspDocHistory
				SET  CIDHExtText02 = @CIDHExtText02
			WHERE CommInspDocNo = @CommInspDocNo

		END
	-- 2020.01.13 비고정보 추가 (kilee) End

	SELECT
			@IsAutoFinish = CITI.IsAutoFinish
	FROM
			STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_CommInspTypeInfo CITI				ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo

	UPDATE STB_CommInspDocItem
	     SET ItemQty = (SELECT COUNT(*) FROM STB_CommInspMeasureHist WHERE CommInspDocItemNo = @CommInspDocItemNo)
	 WHERE CommInspDocItemNo = @CommInspDocItemNo
						
	IF @IsAutoFinish = 1 
	
	BEGIN
		IF NOT EXISTS (
						SELECT	1
						FROM
								(
									SELECT
											CIDI.CommInspDocItemNo,
											CIDI.ItemTargetQty,
											CASE 	WHEN CIDI.ItemTargetQty < COUNT(CIMH.MeasureResult) THEN CIDI.ItemTargetQty	ELSE COUNT(CIMH.MeasureResult)	END  AS GoodCount
									FROM 
														    STB_CommInspMeasureHist CIMH
											INNER JOIN STB_CommInspDocItem       CIDI		ON CIDI.CommInspDocItemNo = CIMH.CommInspDocItemNo
									WHERE 1=1
										AND CIDI.CommInspDocNo = @CommInspDocNo 
										AND	CIMH.MeasureResult = 'OK'
									GROUP BY
											CIDI.CommInspDocItemNo,
											CIDI.ItemTargetQty
								) CII

						WHERE
								CII.ItemTargetQty > CII.GoodCount

					) BEGIN
								UPDATE	STB_CommInspDocHistory
								SET	IsFinished = 1
									,	ChangeDateTime = GETDATE()
									,	ChangeUserID = @ProcessUserID
								WHERE
										CommInspDocNo = @CommInspDocNo
					END

	END
--END