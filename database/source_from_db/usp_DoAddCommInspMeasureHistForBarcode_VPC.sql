-- ===================================================================================================================================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-03
-- Browsable : true
-- Group : 품질관리 > 공정검사(바코드) > 공정검사Grid  업데이트문(iud)
--            품질관리 > [C460] 전극공정검사(바코드) > 공정검사Grid 저장 또는 합격처리 Button의 업데이트문(iud)

-- Description:	공용 검사이력을 추가 합니다.
-- Modified: 바코드 입력시
--				2020.01.13  비고정보 업데이트 되도록 수정 (kilee)
--				2020.01.13  
--				2020.09.22 전극구분 업데이트문 추가
--              2021.10.19 공정단계 추가 (박진호)                    		
-- ===================================================================================================================================================
CREATE PROCEDURE usp_DoAddCommInspMeasureHistForBarcode_VPC
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspDocNo VARCHAR(20),
						@pCommInspDocItemNo VARCHAR(20),
						@pTextMeasure VARCHAR(50),

						@pFirstMeasureValue NUMERIC(20,5) = Null,                        -- 2020.01.14 추가부분
						@pSecondMeasureValue NUMERIC(20,5)= Null,
						@pThirdMeasureValue NUMERIC(20,5)= Null,
						@pFourthMeasureValue NUMERIC(20,5)= Null,
						@pFifthMeasureValue NUMERIC(20,5)= Null,
						@pSixthMeasureValue NUMERIC(20,5)= Null,
						@pSeventhMeasureValue NUMERIC(20,5)= Null,
						@pEightMeasureValue NUMERIC(20,5)= Null,
						@pNineMeasureValue NUMERIC(20,5)= Null,
						@pLastMeasureValue NUMERIC(20,5)= Null,

						--@pNumericMeasure NUMERIC(20,5),
						@pCheckDisplay BIT,
						@pInspWorkerCode   VARCHAR(20) =NULL,
						@pCIDHExtText02      VARCHAR(200) = NULL,     --  추가
						@pCommInspRemark VARCHAR(20) = NULL,       --  추가 (검사자코드 추가)
						@pElectrodeDivision   VARCHAR(1) = NULL,        --  추가 (2020.09.22)
						@pProcessSteps        VARCHAR(30) = NULL,           -- 추가 (2021.10.19)

						-- 설비코드, Tray번호 추가
						@pVPCMachineCode VARCHAR(20) = NULL,
						@pTrayNo VARCHAR(20) = NULL
AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID           VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage       VARCHAR(20) = @pProcessLanguage,
				@CommInspDocNo       VARCHAR(20) = @pCommInspDocNo,
				@CommInspDocItemNo  VARCHAR(20) = @pCommInspDocItemNo,
				@TextMeasure             VARCHAR(50) = @pTextMeasure,
			
				@MeasureValue01  NUMERIC(20,5) = @pFirstMeasureValue,                    -- 2020.01.14 추가부분
				@MeasureValue02  NUMERIC(20,5) = @pSecondMeasureValue,
				@MeasureValue03  NUMERIC(20,5) = @pThirdMeasureValue,
				@MeasureValue04  NUMERIC(20,5) = @pFourthMeasureValue,
				@MeasureValue05  NUMERIC(20,5) = @pFifthMeasureValue,
				@MeasureValue06  NUMERIC(20,5) = @pSixthMeasureValue,
				@MeasureValue07  NUMERIC(20,5) = @pSeventhMeasureValue,
				@MeasureValue08  NUMERIC(20,5) = @pEightMeasureValue,
				@MeasureValue09  NUMERIC(20,5) = @pNineMeasureValue,
				@MeasureValue10  NUMERIC(20,5) = @pLastMeasureValue,

			--@NumericMeasure        NUMERIC(20,5) = @pNumericMeasure,

				@CheckDisplay           BIT = @pCheckDisplay,
				@InspWorkerCode       VARCHAR(20) = @pInspWorkerCode,
				@CIDHExtText02          VARCHAR(200) = @pCIDHExtText02,                  -- 2020.01.13 추가   
				@CommInspRemark     VARCHAR(20) = @pCommInspRemark,               -- 2020.02.02 추가
				@ElectrodeDivision       VARCHAR(1) = @pElectrodeDivision ,                   -- 2020.09.22 추가
				@ProcessSteps              VARCHAR(30) = @pProcessSteps,                    -- 2021.10.19 추가
				@VPCMachineCode VARCHAR(20) = @pVPCMachineCode,
				@TrayNo VARCHAR(20) = @pTrayNo
				


	DECLARE @Barcode                   VARCHAR(50)
	DECLARE @CommInspMeasureNo VARCHAR(20)
	DECLARE @IsAutoFinish              BIT
	DECLARE @IsFinished                 BIT
	DECLARE @ErrorMessage			  NVARCHAR(500)

	-- ItemCode 별 상하한 -- #2021.11.03
	Declare @ItemLSL VARCHAR(100)
	       ,@ItemUSL VARCHAR(100)
		   ,@MaterialCode VARCHAR(20)
		   ,@OverSpecCnt INT
		   ,@CommInspItemCode VARCHAR(50)

	DECLARE @MeasureValueList TABLE (
		MeasureIndex INT
	   ,MeasureValue NUMERIC(20,10)
	);

	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (1, @MeasureValue01)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (2, @MeasureValue02)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (3, @MeasureValue03)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (4, @MeasureValue04)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (5, @MeasureValue05)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (6, @MeasureValue06)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (7, @MeasureValue07)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (8, @MeasureValue08)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (9, @MeasureValue09)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (10, @MeasureValue10)


	SELECT
			@IsFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode,
			@MaterialCode = SI.MaterialCode -- #2021.11.03
	FROM
			                        STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_SetInfo                       SI		ON SI.ControlNo = CIDH.ProdNo
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo


		
			--		SELECT
			--		 CIDH.IsFinished
			--		, SI.Barcode
			--FROM
			--							   STB_CommInspDocHistory CIDH
			--		LEFT OUTER JOIN STB_SetInfo                       SI		ON SI.ControlNo = CIDH.ProdNo
			--WHERE
			--		CIDH.CommInspDocNo = '20200921000087'



	IF @IsFinished = 1    -- 저장버튼을 누르면  

						
	--  IF @ElectrodeDivision IS NOT NULL  

	

			BEGIN
			      
					EXEC SmartFramework.dbo.usp_GetAddonStringResource	@ProcessLanguage, '^이미 완료처리 되었습니다^',	@ErrorMessage OUTPUT
					SET @ErrorMessage = @ErrorMessage + ' [%s]'
					RAISERROR(@ErrorMessage,16,1,@Barcode)
					RETURN

			END
	
			--EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_CommInspMeasureHist', @CommInspMeasureNo OUTPUT

		--declare @tmpfinished varchar(20) = convert(varchar(20),@IsFinished)
		--		raiserror (@tmpfinished,16,1  )

	DECLARE @cnt int    
    DECLARE @i    int
	
	  SET @i = 0

	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@CommInspDocItemNo', @CommInspDocItemNo)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@1', @MeasureValue01)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@2', @MeasureValue02)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@3', @MeasureValue03)

	  --- 검사시료수 확인하여 그수만큼 반복
	 SELECT @cnt = ItemTargetQty 
	       ,@ItemLSL = CommInspLower
		   ,@ItemUSL = CommInspUpper
		   ,@CommInspItemCode = CommInspItemCode
	 FROM STB_CommInspDocItem        
	 WHERE 1=1
	 --AND CommInspDocItemNo   = ('20191203000051')  
	   AND CommInspDocItemNo = @CommInspDocItemNo

	   	-- 먼저 DELETE문
			DELETE FROM STB_CommInspMeasureHist
			WHERE 1=1
			  AND CommInspDocItemNo = @CommInspDocItemNo		
			--AND CommInspDocItemNo = '20200104001441'     

			      		    
	--INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@@ROWCOUNT', @@ROWCOUNT)


	 -- 2020.01.13 비고정보 추가 (kilee)  /  전체에 대한 정보 업데이트  -->   Select CIDHExtText02,  * from STB_CommInspDocHistory where CommInspDocNo = '20200921000087'
		IF @CIDHExtText02 IS NOT NULL  OR @CIDHExtText02 <> '' 
	
		BEGIN
				UPDATE STB_CommInspDocHistory
					 SET CIDHExtText02 = @CIDHExtText02
				 WHERE CommInspDocNo = @CommInspDocNo
		END
	

	--  select ElectrodeDivision, * from STB_CommInspDocHistory   where ElectrodeDivision is null Order by JobDate DESC
	 BEGIN
					Update STB_CommInspDocHistory
	             		Set  ElectrodeDivision = @ElectrodeDivision                    
					WHERE CommInspDocNo = @CommInspDocNo
			                                                               		--  SELECT * FROM STB_CommInspDocHistory WHERE CommInspDocNo = '20200921000123'
         END


		 --- 2021.10.25 add
		 	UPDATE STB_CommInspDocItem
					 SET CommInspRemark = @CommInspRemark
					     , ProcessSteps  = @ProcessSteps                 -- 추가부분

				WHERE CommInspDocItemNo = @CommInspDocItemNo


    -- 2020.01.31 검사결과 추가 (kilee) / 한 줄에 대한 정보 업데이트   
		--IF @CIDHExtText03 = null or @CIDHExtText03 = '' or @CIDHExtText03 is null
	    IF @CommInspRemark IS NOT NULL   OR @CommInspRemark <> '' 

		BEGIN

				UPDATE STB_CommInspDocItem
					 SET CommInspRemark = @CommInspRemark
					     , ProcessSteps  = @ProcessSteps                 -- 추가부분

				WHERE CommInspDocItemNo = @CommInspDocItemNo
		END
	-----------------------------------------------------------------------------------------


    WHILE(@i < @cnt)   
	BEGIN
	

      SET @i = @i + 1
				
				   	
	BEGIN
			IF @MaterialCode = 'LIVT38-018' AND @CommInspItemCode LIKE 'VPC%' AND @pProcessUserID = 'yjyu' BEGIN --# 2021.11.03
				SELECT @OverSpecCnt = COUNT(*)
				  FROM @MeasureValueList
				 WHERE MeasureValue < CONVERT(NUMERIC(20, 10), @ItemLSL) OR MeasureValue > CONVERT(NUMERIC(20, 10), @ItemUSL)
				   AND ISNULL(MeasureValue,0.0) <> 0.0 -- 검사대상 수 보다 작게 입력했을 경우 입력한 값에 대해서만 스펙 오버 체크를 한다. 2021.11.04 by Jackaroe
				   AND ISNULL(CONVERT(NUMERIC(20, 10), @ItemLSL), 0.0) > 0.0

				IF @OverSpecCnt > 0 BEGIN
					EXEC usp_RaiseLocalizedError @pProcessLanguage, '입력한 값 중에 스펙에 맞지 않는 값이 있습니다.'
					-- SMS발송
					EXEC usp_DoSendSMS @pProcessUserID, pProcessLanguage, '010-5617-0713,010-6637-7780,010-3222-6697,010-4557-7870,010-9088-1368,010-9547-0308', 'VPC(0825) Lot 자주검사 중 스펙오버 수치가 입력되었습니다.({#1})', @Barcode
					RETURN
				END
			END
		
		
		   -- Insert 문 
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

			SELECT @CommInspMeasureNo
			        , @CommInspDocItemNo
					, MeasureIndex
					, @TextMeasure
					 --, MeasureValue
					, ISNULL(MeasureValue, 0)
			        , CASE  WHEN @CheckDisplay = 1 THEN 1			ELSE 0 	END,  GETDATE(), @ProcessUserID, @InspWorkerCode					
		      FROM @MeasureValueList
			 WHERE MeasureIndex = @i
		END	
	END

	-- 여기가 원래 자리였음!


	SELECT
			@IsAutoFinish = CITI.IsAutoFinish
	FROM
			                        STB_CommInspDocHistory CIDH
			LEFT OUTER JOIN STB_CommInspTypeInfo    CITI				ON CITI.CommInspTypeCode = CIDH.CommInspTypeCode
	WHERE
			CIDH.CommInspDocNo = @CommInspDocNo


	 UPDATE STB_CommInspDocItem
	       SET ItemQty = (SELECT COUNT(*) FROM STB_CommInspMeasureHist WHERE CommInspDocItemNo = @CommInspDocItemNo)
		      ,  ProcessSteps  = @ProcessSteps                                                                                         -- 추가부분
	 WHERE CommInspDocItemNo = @CommInspDocItemNo

	 --검사자, 설비코드, 트래이번호 업데이트 #211207 
	 UPDATE STB_CommInspDocHistory
	    SET InspWorkerCode = @InspWorkerCode
		   ,VPCMachineCode = @VPCMachineCode
		   ,TrayNo = @TrayNo
      WHERE CommInspDocNo = @CommInspDocNo

						
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
									     ,  ElectrodeDivision = @ElectrodeDivision        --추가부분 (2020-09-22)
								WHERE
										CommInspDocNo = @CommInspDocNo
					END

---
					BEGIN

				UPDATE STB_CommInspDocItem
					 SET CommInspRemark = @CommInspRemark
					     , ProcessSteps  = @ProcessSteps                 -- 추가부분

				WHERE CommInspDocItemNo = @CommInspDocItemNo
		END
---


	   END

END