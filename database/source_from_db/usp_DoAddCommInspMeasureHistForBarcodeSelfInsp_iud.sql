-- =============================================
-- Author:		kilee
-- Create date: 2020-03-16
-- Browsable : true
-- Group : 생산관리 > 실적등록 > 자주검사/원자재투입
-- Description : 자주검사 일괄등록 할 수 있도록 요청 (조현준, 김전식)
-- Modified: 

-- [프로시저 실행문]   EXEC usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_iud    'kilee','Korean','20200104000051','20200104001441','',     '1.11','2.22','3.33','4.44','5.55','6.66','7.77','8.88','9.99','10.10'           , '' , '0705201'  , ''                                  
-- [프로시저 실행문]   EXEC usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_iud    'kilee','Korean','20200316000030','20200316001186','',     '3.35','4.45','5.45','3.33','4.44','0','0','0','0','0'           , '' , '0705201'  , 'etc'                                  

-- [테스트]  바코드 :  VJKL163R010612 /  검사문서번호 : 20200316000030 /  공용검사항목이력번호 (여러항목중의 하나) :  20200316001186	

--- [Table구조]
-- SELECT *                    FROM STB_SetInfo                     WHERE Barcode                  IN ( 'VJKL163R010612')                 -- ControlNo = '20200316000030'    * ControlNo 확인
-- SELECT ItemTargetQty, * FROM STB_CommInspDocItem       WHERE CommInspDocNo      = '20200316000030'                      -- CommInspDocItemNo     27개존재
-- SELECT * FROM STB_CommInspMeasureHist                     WHERE CommInspDocItemNo IN ('20200316001187')                   -- ControlNo = '20200316000030' / CommInspDocItemNo = '20200316001186'
-- (한줄로표기)   SELECT * FROM STB_CommInspDocHistory     WHERE CommInspDocNo       IN ('20200316000030') 

-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddCommInspMeasureHistForBarcodeSelfInsp_iud]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspDocNo VARCHAR(20),
						@pCommInspDocItemNo VARCHAR(20),
						@pTextMeasure VARCHAR(50) =null,
						@pFirstMeasureValue NUMERIC(20,5) = Null,                        
						@pSecondMeasureValue NUMERIC(20,5)= Null,
						@pThirdMeasureValue NUMERIC(20,5)= Null,
						@pFourthMeasureValue NUMERIC(20,5)= Null,
						@pFifthMeasureValue NUMERIC(20,5)= Null,
						@pSixthMeasureValue NUMERIC(20,5)= Null,
						@pSeventhMeasureValue NUMERIC(20,5)= Null,
						@pEightMeasureValue NUMERIC(20,5)= Null,
						@pNineMeasureValue NUMERIC(20,5)= Null,
						@pLastMeasureValue NUMERIC(20,5)= Null,
						@pCheckDisplay BIT,
						@pInspWorkerCode VARCHAR(20) =NULL,
						@pCIDHExtText02 VARCHAR(200) = NULL,          
						@pCommInspRemark VARCHAR(20) = NULL,
						@pNumericMeasure NUMERIC(20,5)=null



AS

BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID           VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage       VARCHAR(20) = @pProcessLanguage,
				@CommInspDocNo       VARCHAR(20) = @pCommInspDocNo,
				@CommInspDocItemNo  VARCHAR(20) = @pCommInspDocItemNo,
				@TextMeasure             VARCHAR(50) = @pTextMeasure,			
				@MeasureValue01		   NUMERIC(20,5) = @pFirstMeasureValue,                    -- 2020.01.14 추가부분
				@MeasureValue02		   NUMERIC(20,5) = @pSecondMeasureValue,
				@MeasureValue03        NUMERIC(20,5) = @pThirdMeasureValue,
				@MeasureValue04        NUMERIC(20,5) = @pFourthMeasureValue,
				@MeasureValue05        NUMERIC(20,5) = @pFifthMeasureValue,
				@MeasureValue06        NUMERIC(20,5) = @pSixthMeasureValue,
				@MeasureValue07        NUMERIC(20,5) = @pSeventhMeasureValue,
				@MeasureValue08        NUMERIC(20,5) = @pEightMeasureValue,
				@MeasureValue09	       NUMERIC(20,5) = @pNineMeasureValue,
				@MeasureValue10        NUMERIC(20,5) = @pLastMeasureValue,
			 -- @NumericMeasure        NUMERIC(20,5) = @pNumericMeasure,
				@CheckDisplay             BIT = @pCheckDisplay,
				@InspWorkerCode         VARCHAR(20) = @pInspWorkerCode,
				@CIDHExtText02            VARCHAR(200) = @pCIDHExtText02,                  -- 2020.01.13 추가   
				@CommInspRemark       VARCHAR(20) = @pCommInspRemark               -- 2020.02.02 추가
	
	declare @company varchar(10)='';
	select @company = CompanyCode from STB_UserInfo
	where UserID=@pProcessUserID
	--Mr.Tung modified on 2023-02-15
	if(@company='VVT' and @pNumericMeasure>0)begin

		 exec usp_DoAddCommInspMeasureHistForBarcode 
						@pProcessUserID = @pProcessUserID,
						@pProcessLanguage =@pProcessLanguage,
						@pCommInspDocNo =@pCommInspDocNo,
						@pCommInspDocItemNo =@pCommInspDocItemNo,
						@pTextMeasure =@pTextMeasure,
						@pNumericMeasure =@pNumericMeasure,
						@pCheckDisplay =@pCheckDisplay,
						@pInspWorkerCode =@pInspWorkerCode,
						@pCIDHExtText02 =@pCIDHExtText02
			if ( @pFirstMeasureValue is null and @pSecondMeasureValue is null and @pThirdMeasureValue is null) 
			return;
	end

	DECLARE @Barcode                  VARCHAR(50)
	DECLARE @CommInspMeasureNo VARCHAR(20)
	DECLARE @IsAutoFinish              BIT
	DECLARE @IsFinished                 BIT
	DECLARE @ErrorMessage			  NVARCHAR(500)

	DECLARE @MeasureValueList TABLE (
		MeasureIndex INT
	   ,MeasureValue NUMERIC(20,5)
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

		
	
	DECLARE @cnt int    
    DECLARE @i    int
	

	  SET @i = 0

	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@CommInspDocItemNo', @CommInspDocItemNo)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@1', @MeasureValue01)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@2', @MeasureValue02)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@3', @MeasureValue03)

	  --- 검사시료수 확인하여 그수만큼 반복
	 SELECT @cnt = ItemTargetQty 
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


	 ---- 2020.01.13 비고정보 추가 (kilee)  /  전체에 대한 정보 업데이트  -->   Select CIDHExtText02,  * from STB_CommInspDocHistory where CommInspDocNo = '20191203000049'
		--IF @CIDHExtText02 IS NOT NULL  OR @CIDHExtText02 <> '' 
	
		--BEGIN
		--		UPDATE STB_CommInspDocHistory
		--			 SET CIDHExtText02 = @CIDHExtText02
		--		 WHERE CommInspDocNo = @CommInspDocNo
		--END
	

    -- 2020.01.31 검사결과 추가 (kilee) / 한 줄에 대한 정보 업데이트   
		--IF @CIDHExtText03 = null or @CIDHExtText03 = '' or @CIDHExtText03 is null
	    IF @CommInspRemark IS NOT NULL   OR @CommInspRemark <> '' 

		BEGIN
				UPDATE STB_CommInspDocItem
					 SET CommInspRemark = @CommInspRemark
				WHERE CommInspDocItemNo = @CommInspDocItemNo
		END
	-----------------------------------------------------------------------------------------


    WHILE(@i < @cnt)   
	BEGIN
	

      SET @i = @i + 1
				
				   	
	BEGIN
		
		
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
					, case when @company='VVT' then MeasureValue else  ISNULL(MeasureValue, 0) end --Mr.Tung modified on 2023-02-15
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

END
