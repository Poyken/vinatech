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

-- [프로시저 실행문]   EXEC usp_DoAddCommInspMeasureHistForBarcode_TEST    'kilee','Korean','20200104000051','20200104001441','',     '1.11','2.22','3.33','4.44','5.55','6.66','7.77','8.88','9.99','10.10'           , '' , '0705201'  , ''                                  
-- [프로시저 실행문]   EXEC usp_DoAddCommInspMeasureHistForBarcode_TEST    'kilee','Korean','20200104000051','20200104001440','',     '1','1','1','1','1','0','0','0','0','0'           , '' , '0705201'  , ''                                  		
-- ===================================================================================================================================================
CREATE PROCEDURE [dbo].[usp_DoAddCommInspMeasureHistForBarcode_Vietnam]
						@pProcessUserID VARCHAR(20),
						@pProcessLanguage VARCHAR(20),
						@pCommInspDocNo VARCHAR(20),
						@pCommInspDocItemNo VARCHAR(20),
						@pTextMeasure VARCHAR(50),

						@pFirstMeasureValue varchar(20) = Null,                        -- 2020.01.14 추가부분
						@pSecondMeasureValue varchar(20)= Null,
						@pThirdMeasureValue varchar(20)= Null,
						@pFourthMeasureValue varchar(20)= Null,
						@pFifthMeasureValue varchar(20)= Null,
						@pSixthMeasureValue varchar(20)= Null,
						@pSeventhMeasureValue varchar(20)= Null,
						@pEightMeasureValue varchar(20)= Null,
						@pNineMeasureValue varchar(20)= Null,
						@pLastMeasureValue varchar(20)= Null,

						--@pNumericMeasure varchar(20),
						@pCheckDisplay BIT,
						@pNG_flag BIT,
						@pInspWorkerCode   VARCHAR(20) =NULL,
						@pCIDHExtText02      VARCHAR(200) = NULL,     --  추가
						@pCommInspRemark VARCHAR(20) = NULL,       --  추가
						@pElectrodeDivision   VARCHAR(1) = NULL,        --  추가 (2020.09.22)
						
						@pValue11 varchar(20)= Null,
						@pValue12 varchar(20)= Null,
						@pValue13 varchar(20)= Null,
						@pValue14 varchar(20)= Null,
						@pValue15 varchar(20)= Null,
						@pValue16 varchar(20)= Null,
						@pValue17 varchar(20)= Null,
						@pValue18 varchar(20)= Null,
						@pValue19 varchar(20)= Null,
						@pValue20 varchar(20)= Null
AS

BEGIN
	SET NOCOUNT ON;
	
    DECLARE @ProcessUserID           VARCHAR(20) = @pProcessUserID,
				@ProcessLanguage       VARCHAR(20) = @pProcessLanguage,
				@CommInspDocNo       VARCHAR(20) = @pCommInspDocNo,
				@CommInspDocItemNo  VARCHAR(20) = @pCommInspDocItemNo,
				@TextMeasure             VARCHAR(50) = @pTextMeasure,
			
				@MeasureValue01  numeric(20,5) = case when isnull(@pFirstMeasureValue,'')='' then NULL when @pFirstMeasureValue='NG' then 0  when @pFirstMeasureValue='OK' then 1 ELSE convert(numeric(20,5),@pFirstMeasureValue) end ,                    -- 2020.01.14 추가부분
				@MeasureValue02  numeric(20,5) = case when isnull(@pSecondMeasureValue,'')='' then NULL when @pSecondMeasureValue='NG' then 0 when @pSecondMeasureValue='OK' then 1 ELSE  convert(numeric(20,5),@pSecondMeasureValue) end ,
				@MeasureValue03  numeric(20,5) = case when isnull(@pThirdMeasureValue,'')='' then NULL when @pThirdMeasureValue='NG' then 0 when @pThirdMeasureValue='OK' then  1 ELSE convert(numeric(20,5),@pThirdMeasureValue)  end ,
				@MeasureValue04  numeric(20,5) = case when isnull(@pFourthMeasureValue,'')='' then NULL when @pFourthMeasureValue='NG' then 0 when @pFourthMeasureValue='OK' then  1 ELSE convert(numeric(20,5),@pFourthMeasureValue) end ,
				@MeasureValue05  numeric(20,5) = case when isnull(@pFifthMeasureValue,'')='' then NULL when @pFifthMeasureValue='NG' then 0 when @pFifthMeasureValue='OK' then 1 ELSE convert(numeric(20,5),@pFifthMeasureValue) end ,
				@MeasureValue06  numeric(20,5) = case when isnull(@pSixthMeasureValue,'')='' then NULL when @pSixthMeasureValue='NG' then 0 when @pSixthMeasureValue='OK' then 1 ELSE convert(numeric(20,5),@pSixthMeasureValue) end ,
				@MeasureValue07  numeric(20,5) = case when isnull(@pSeventhMeasureValue,'')='' then NULL when @pSeventhMeasureValue='NG' then 0 when @pSeventhMeasureValue='OK' then 1 ELSE convert(numeric(20,5),@pSeventhMeasureValue)  end ,
				@MeasureValue08  numeric(20,5) = case when isnull(@pEightMeasureValue,'')='' then NULL when @pEightMeasureValue='NG' then 0 when @pEightMeasureValue='OK' then  1 ELSE convert(numeric(20,5),@pEightMeasureValue) end ,
				@MeasureValue09  numeric(20,5) = case when isnull(@pNineMeasureValue,'')='' then NULL when @pNineMeasureValue='NG' then 0 when @pNineMeasureValue='OK' then 1 ELSE convert(numeric(20,5),@pNineMeasureValue) end ,
				
				@MeasureValue10  numeric(20,5) = case when isnull(@pLastMeasureValue,'')='' then NULL when @pLastMeasureValue='NG' then 0 when @pLastMeasureValue='OK' then 1 ELSE convert(numeric(20,5),@pLastMeasureValue) end ,
				@MeasureValue11  numeric(20,5) = case when isnull(@pValue11,'')='' then NULL when @pValue11='NG' then 0 when @pValue11='OK' then 1 ELSE convert(numeric(20,5),@pValue11) end ,                    -- 2020.01.14 추가부분
				@MeasureValue12  numeric(20,5) = case when isnull(@pValue12,'')='' then NULL when @pValue12='NG' then 0 when @pValue12='OK' then 1 ELSE  convert(numeric(20,5),@pValue12) end ,
				@MeasureValue13  numeric(20,5) = case when isnull(@pValue13,'')='' then NULL when @pValue13='NG' then 0 when @pValue13='OK' then  1 ELSE convert(numeric(20,5),@pValue13)  end ,
				@MeasureValue14  numeric(20,5) = case when isnull(@pValue14,'')='' then NULL when @pValue14='NG' then 0 when @pValue14='OK' then  1 ELSE convert(numeric(20,5),@pValue14) end ,
				@MeasureValue15  numeric(20,5) = case when isnull(@pValue15,'')='' then NULL when @pValue15='NG' then 0 when @pValue15='OK' then 1 ELSE convert(numeric(20,5),@pValue15) end ,
				@MeasureValue16  numeric(20,5) = case when isnull(@pValue16,'')='' then NULL when @pValue16='NG' then 0 when @pValue16='OK' then 1 ELSE convert(numeric(20,5),@pValue16) end ,
				@MeasureValue17  numeric(20,5) = case when isnull(@pValue17,'')='' then NULL when @pValue17='NG' then 0 when @pValue17='OK' then 1 ELSE convert(numeric(20,5),@pValue17)  end ,
				@MeasureValue18  numeric(20,5) = case when isnull(@pValue18,'')='' then NULL when @pValue18='NG' then 0 when @pValue18='OK' then  1 ELSE convert(numeric(20,5),@pValue18) end ,
				@MeasureValue19  numeric(20,5) = case when isnull(@pValue19,'')='' then NULL when @pValue19='NG' then 0 when @pValue19='OK' then 1 ELSE convert(numeric(20,5),@pValue19) end ,
				@MeasureValue20  numeric(20,5) = case when isnull(@pValue20,'')='' then NULL when @pValue20='NG' then 0 when @pValue20='OK' then 1 ELSE convert(numeric(20,5),@pValue20) end ,
		
		--@NumericMeasure        varchar(20) = @pNumericMeasure,

				@CheckDisplay       BIT = @pCheckDisplay,
				@NG_flag			bit	=	@pNG_flag,
				@valInspItemType    bit,
				@InspWorkerCode     VARCHAR(20) = @pInspWorkerCode,
				@CIDHExtText02      VARCHAR(200) = @pCIDHExtText02,                  -- 2020.01.13 추가   
				@CommInspRemark     VARCHAR(20) = @pCommInspRemark,               -- 2020.02.02 추가
				@ElectrodeDivision   VARCHAR(1) = @pElectrodeDivision                    -- 2020.09.22 추가


	DECLARE @Barcode                   VARCHAR(50)
	DECLARE @CommInspMeasureNo VARCHAR(20)
	DECLARE @IsAutoFinish              BIT
	DECLARE @IsFinished                 BIT
	DECLARE @ErrorMessage			  NVARCHAR(500)

	DECLARE @MeasureValueList TABLE (
		MeasureIndex INT
	   ,MeasureValue numeric(20,5)
	);

	--declare @errrr varchar(100)=  convert(varchar(100),@NG_flag);

	--	raiserror (@errrr,16,1);
	--return;

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

	  -- Mr.Tung thêm đoạn insert  này để hiển thị được 20,30,40 cột có chữ OK cho các Mục Kiểm tra ngoại quan vào ngày 25 tháng 10 2023
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (11, @MeasureValue11)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (12, @MeasureValue12)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (13, @MeasureValue13)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (14, @MeasureValue14)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (15, @MeasureValue15)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (16, @MeasureValue16)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (17, @MeasureValue17)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (18, @MeasureValue18)
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (19, @MeasureValue19)
																		  
	INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (20, @MeasureValue20)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (21, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (22, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (23, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (24, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (25, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (26, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (27, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (28, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (29, null)
																		  
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (30, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (31, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (32, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (33, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (34, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (35, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (36, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (37, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (38, null)
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (39, null)
																		  
	--INSERT INTO @MeasureValueList (MeasureIndex,MeasureValue) VALUES (40, null)



		   -- chuc nang cho phep NG tu dong.
		if @NG_flag<>1 
		begin
		  ;with tmpdata as(
			select 
				 CIDI.CommInspItemSpec
				, CIDI.CommInspUpper
				, CIDI.CommInspLower
				,case when 
				isnull(mvl.MeasureValue,0) >= isnull(TRY_PARSE(isnull(replace(replace(replace(replace(replace(replace(replace(replace(replace(CIDI.CommInspLower,'<',''),'>',''),'=',''),' ',''),'~',''),'≥',''),'(',''),')',''),'+',''),'1') AS NUMERIC(20,10) USING 'en-US'  ),0) 
				and 
				isnull(mvl.MeasureValue,1) <= isnull(TRY_PARSE(isnull(replace(replace(replace(replace(replace(replace(replace(replace(replace(CIDI.CommInspUpper,'<',''),'>',''),'=',''),' ',''),'~',''),'≥',''),'(',''),')',''),'+',''),'0') AS NUMERIC(20,10) USING 'en-US'  ),0) 
				 then 0 else 1 end as NG_dat
				 --,cimh.*	
			FROM			
				STB_CommInspMeasureHist cimh  WITH(NOLOCK)
				LEFT OUTER JOIN  STB_CommInspDocItem CIDI   WITH(NOLOCK) ON cimh.CommInspDocItemNo = CIDI.CommInspDocItemNo 
				join @MeasureValueList mvl on cimh.MeasureSeq=mvl.MeasureIndex
				--LEFT OUTER JOIN STB_CommInspItem CII WITH(NOLOCK)	      ON CII.CommInspItemCode = CIDI.CommInspItemCode
				--LEFT OUTER JOIN STB_CommInspDocHistory SCH WITH(NOLOCK)			ON SCH.CommInspDocNo = CIDI.CommInspDocNo
			where 
				--CII.CommInspTypeCode='ROUTE_QUALITY2' 
				--and 
				cimh.CommInspDocItemNo=@CommInspDocItemNo
				and cimh.NumericMeasure<>mvl.MeasureValue
			)
			select @NG_flag = sum(NG_dat) from tmpdata
		end
		
		if(@NG_flag>1) 
		begin
			select @NG_flag=1;
		end
		
				
		if(@ProcessUserID='nguyentung') 
		begin
			declare @tung varchar(10)=convert(varchar(10),@pNG_flag);
			--raiserror(@tung,16,1);
			--return;
		end


	SELECT
			@IsFinished = CIDH.IsFinished,
			@Barcode = SI.Barcode
	FROM
			STB_CommInspDocHistory     CIDH
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
				
	
	DECLARE @cnt int    
    DECLARE @i    int
	declare @InputType varchar(10)

	  SET @i = 0

	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@CommInspDocItemNo', @CommInspDocItemNo)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@1', @MeasureValue01)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@2', @MeasureValue02)
	  --INSERT INTO STB_ProcedureLog (ProcedureName, VariableName, VariableValue) VALUES ('usp_DoAddCommInspMeasureHistForBarcode_TEST', '@3', @MeasureValue03)

	  --- 검사시료수 확인하여 그수만큼 반복
	 SELECT @cnt = ItemTargetQty  , @InputType=CommInspInputType
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
	

	-- 
	 BEGIN
					Update STB_CommInspDocHistory
	             		Set  ElectrodeDivision = @ElectrodeDivision
					WHERE CommInspDocNo = @CommInspDocNo
			                                                               		--  SELECT * FROM STB_CommInspDocHistory WHERE CommInspDocNo = '20200921000123'
         END



    -- 2020.01.31 검사결과 추가 (kilee) / 한 줄에 대한 정보 업데이트   
		--IF @CIDHExtText03 = null or @CIDHExtText03 = '' or @CIDHExtText03 is null
	    IF @CommInspRemark IS NOT NULL   OR @CommInspRemark <> '' 

		BEGIN
				UPDATE STB_CommInspDocItem
					 SET CommInspRemark = @CommInspRemark
				WHERE CommInspDocItemNo = @CommInspDocItemNo
		END
	-----------------------------------------------------------------------------------------

			select @valInspItemType = (case when CommInspInputType=2 or CommInspInputType='2' then 1 else 0 end )
			from	STB_CommInspDocItem
			where CommInspDocItemNo=@CommInspDocItemNo
		


	if(@InputType=1 or @InputType='1')begin
	declare @err Nvarchar(500)='';
				if(
					@cnt>9 and (@MeasureValue01 is null 
								or @MeasureValue02 is null 
								or @MeasureValue03 is null 
								or @MeasureValue04 is null 
								or @MeasureValue05 is null 
								or @MeasureValue06 is null 
								or @MeasureValue07 is null 
								or @MeasureValue08 is null 
								or @MeasureValue09 is null 
								or @MeasureValue10 is null )

				or	@cnt>8 and (@MeasureValue01 is null 
								or @MeasureValue02 is null 
								or @MeasureValue03 is null 
								or @MeasureValue04 is null 
								or @MeasureValue05 is null 
								or @MeasureValue06 is null 
								or @MeasureValue07 is null 
								or @MeasureValue08 is null 
								or @MeasureValue09 is null)

				or	@cnt>7 and (@MeasureValue01 is null 
								or @MeasureValue02 is null 
								or @MeasureValue03 is null 
								or @MeasureValue04 is null 
								or @MeasureValue05 is null 
								or @MeasureValue06 is null 
								or @MeasureValue07 is null 
								or @MeasureValue08 is null)

				or	@cnt>6 and (@MeasureValue01 is null 
								or @MeasureValue02 is null 
								or @MeasureValue03 is null 
								or @MeasureValue04 is null 
								or @MeasureValue05 is null 
								or @MeasureValue06 is null 
								or @MeasureValue07 is null)

				or	@cnt>5 and (@MeasureValue01 is null 
								or @MeasureValue02 is null 
								or @MeasureValue03 is null 
								or @MeasureValue04 is null 
								or @MeasureValue05 is null 
								or @MeasureValue06 is null)

				or	@cnt>4 and (@MeasureValue01 is null 
								or @MeasureValue02 is null 
								or @MeasureValue03 is null 
								or @MeasureValue04 is null 
								or @MeasureValue05 is null )

				or	@cnt>3 and (@MeasureValue01 is null 
								or @MeasureValue02 is null 
								or @MeasureValue03 is null 
								or @MeasureValue04 is null )

				or	@cnt>2 and (@MeasureValue01 is null 
								or @MeasureValue02 is null 
								or @MeasureValue03 is null )

				or	@cnt>1 and (@MeasureValue01 is null 
								or @MeasureValue02 is null )

				)		
				set @err = N'Nhập thiếu giá trị vào theo Spec 3 - 10'	;
				

				if(@err<>'') raiserror(@err,16,1);
				if(@err<>'') return;
	end




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
					,  case when @InputType = '2' then null else MeasureValue end --ISNULL(MeasureValue, 0)   
			        , CASE WHEN  @NG_flag = 1 then 'NG' --or (/*@CheckDisplay = 0 and*/ MeasureValue=0) 
							when MeasureValue=0 and @valInspItemType=1 and @CheckDisplay = 0 then 'NG'  	
							when MeasureValue=0 and @valInspItemType<>1 then null
							ELSE  'OK' 	
							END
					, GETDATE()
					, @ProcessUserID
					, @InspWorkerCode					
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
									     ,  ElectrodeDivision = @ElectrodeDivision        --추가부분 (2020-09-22)
								WHERE
										CommInspDocNo = @CommInspDocNo
					END

	   END

	   /*
		( ToDecimal([Comm Insp Lower1]) <> 0 || ToDecimal([Comm Insp Upper1]) <> 0) && ToDecimal([Giá trị đo lần 1]) <> 0 && ToDecimal([Giá trị đo lần 1]) <> 1 && ToDecimal([Giá trị đo lần 1]) <> ToDecimal([Giá trị đo lần 2]) && ToDecimal([Giá trị đo lần 1]) <> ToDecimal([Giá trị đo lần 3]) && ToDecimal([Giá trị đo lần 1]) <> ToDecimal([Giá trị đo lần 4]) && ToDecimal([Giá trị đo lần 1]) <> ToDecimal([Giá trị đo lần 5]) && ToDecimal([Giá trị đo lần 1]) <> ToDecimal([Giá trị đo lần 6]) && ToDecimal([Giá trị đo lần 1]) <> ToDecimal([Giá trị đo lần 7]) && ToDecimal([Giá trị đo lần 1]) <> ToDecimal([Giá trị đo lần 8]) && ToDecimal([Giá trị đo lần 1]) <> ToDecimal([Giá trị đo lần 9]) && ([Giá trị đo lần 1] <> NULL && ToDecimal([Giá trị đo lần 1]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 2] <> NULL && ToDecimal([Giá trị đo lần 2]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 3] <> NULL && ToDecimal([Giá trị đo lần 3]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 4] <> NULL && ToDecimal([Giá trị đo lần 4]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 5] <> NULL && ToDecimal([Giá trị đo lần 5]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 6] <> NULL && ToDecimal([Giá trị đo lần 6]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 7] <> NULL && ToDecimal([Giá trị đo lần 7]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 8] <> NULL && ToDecimal([Giá trị đo lần 8]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 9] <> NULL && ToDecimal([Giá trị đo lần 9]) < ToDecimal([Comm Insp Lower1]) || [Giá trị đo lần 1] <> NULL && ToDecimal([Giá trị đo lần 1]) > ToDecimal([Comm Insp Upper1]) || [Giá trị đo lần 2] <> NULL && ToDecimal([Giá trị đo lần 2]) > ToDecimal([Comm Insp Upper1]) || [Giá trị đo lần 3] <> NULL && ToDecimal([Giá trị đo lần 3]) > ToDecimal([Comm Insp Upper1]) || [Giá trị đo lần 4] <> NULL && ToDecimal([Giá trị đo lần 4]) > ToDecimal([Comm Insp Upper1]) || [Giá trị đo lần 5] <> NULL && ToDecimal([Giá trị đo lần 5]) > ToDecimal([Comm Insp Upper1]) || [Giá trị đo lần 6] <> NULL && ToDecimal([Giá trị đo lần 6]) > ToDecimal([Comm Insp Upper1]) || [Giá trị đo lần 7] <> NULL && ToDecimal([Giá trị đo lần 7]) > ToDecimal([Comm Insp Upper1]) || [Giá trị đo lần 8] <> NULL && ToDecimal([Giá trị đo lần 8]) > ToDecimal([Comm Insp Upper1]) || [Giá trị đo lần 9] <> NULL && ToDecimal([Giá trị đo lần 9]) > ToDecimal([Comm Insp Upper1]))
		*/

END
