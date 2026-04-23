
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-18
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사 합격을 처리합니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateMaterialFOQcInfo_Success]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pProdInspWorkerCode VARCHAR(20)= null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName
	DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)

	-- Declare Columns Variable
	DECLARE @OldMaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcNo VARCHAR(20)

	DECLARE @CharFOQC VARCHAR(1)='F';

	DECLARE @GRProcessQty NUMERIC(20,5)
	DECLARE @RemainQty NUMERIC(20,5)
	DECLARE @TotalCount INT
	DECLARE @LoopCount INT
	DECLARE @MaterialDocDetailNo VARCHAR(20)
	DECLARE @PickingAssingQty NUMERIC(20,5)
	DECLARE @BefQcStatus VARCHAR(10) -- 이것도 1로 해놨네 신발...
	DECLARE @ProdInspWorkerCode VARCHAR(20) = @pProdInspWorkerCode

	DECLARE @SampleCreateCount INT
	DECLARE @SampleInputCount INT

	DECLARE @SampleCheckCount INT    -- 2020.08.24 추가
	
	DECLARE @iDoc INT
	
	DECLARE @MaterialDocDetail TABLE
		(
			IDX INT,
			MaterialDocDetailNo VARCHAR(20),
			PickingAssignQty NUMERIC(20,5)
		)

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
			
    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
    BEGIN TRY
	    DECLARE SourceData CURSOR FOR

				SELECT
						CASE WHEN XMLData.OldMaterialQcNo IS NULL THEN XMLData.MaterialQcNo ELSE XMLData.OldMaterialQcNo END AS OldMaterialIqcNo
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 OldMaterialQcNo VARCHAR(20),
								 MaterialQcNo VARCHAR(20)
								) XMLData
        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			-- 샘플이 생성되어 있는 경우 샘플 수와 입력된 데이터 수가 다르면 처리 불가. 품질부문 요청 2019.10.28 By Jackaroe
			-- 샘플 종류별로 카운트 하지 않고, 전체 샘플 수량으로 비교한다. 이후 요청이 있을 경우 세분화 시켜야 할 수도 있음.
			
			-- [1] 전체 검사수
			SELECT @SampleCreateCount = COUNT(*)
			  FROM STB_MaterialQcSampleResult
			 WHERE MaterialQcNo = @CharFOQC + @OldMaterialQcNo
			                   
							    -- [1]번 검증
								 --SELECT  SampleCreateCount, * 
								 -- FROM STB_MaterialQcSampleResult
								 --WHERE MaterialQcNo = 'VJKQ182R710609'


			 -- [2] 검사입력수
			 SELECT @SampleInputCount = COUNT(*)
			  FROM STB_MaterialQcSampleResult
			 WHERE MaterialQcNo = @CharFOQC + @OldMaterialQcNo
			   AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), TestValue), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), TestResult), '')) <> '')
			                         
									 -- [2]번검증
							         -- SELECT  *
									 -- FROM STB_MaterialQcSampleResult
									 --WHERE MaterialQcNo = 'VJKQ182R710609'
									 --  AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), TestValue), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), TestResult), '')) <> '')

			IF @SampleCreateCount <> @SampleInputCount     -- 전체검사항목에 입력했는지 체크 / [1]번과 [2]번 비교
			
			BEGIN
				Declare @InputValueCheck NVARCHAR(MAX)

				EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																	@pName = '^샘플 개수와 입력 값의 개수가 일치하지 않습니다.^',
																	@pValue = @InputValueCheck OUTPUT	
				RAISERROR(@InputValueCheck, 16, 1)
				RETURN
			END
				
	--------- 2020.08.24 체크사항 추가 Start ----------------------------------------------------------------------

			-- [3] 항목당 샘플수량(10,10,3)과 비교  (SampleCheckCount)
			 SELECT @SampleCheckCount = SUM(SampleQty)                                    
			  FROM STB_MaterialQcDetail
			 WHERE 1=1
			   AND  MaterialQcNo = @CharFOQC + @OldMaterialQcNo			   
			   AND (RTRIM(IsNull(Convert(VARCHAR(10), SampleQty), '')) <> '' Or  RTRIM(IsNull(Convert(VARCHAR(10), SampleQty), '')) <> '')

			                         -- [3]수량 검증쿼리
							         --SELECT  SUM(SampleQty) AS SampleQty                                  -- 23개
									 -- FROM STB_MaterialQcDetail
									 --WHERE 1=1									 
									 --  AND  MaterialQcNo = 'VJKQ182R710609'
									 --  AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), SampleQty), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), SampleQty), '')) <> '')
									 --  And QcInspectionItemCode in ('IQC_GPD_18','IQC_GPD_19','IQC_GPD_20')       --SD, ESR, 용량
                                     -- Group by MaterialQcDetailNo 

			IF @SampleInputCount <> @SampleCheckCount     --[2]번과 [3]번 체크
			
			BEGIN
				Declare @SampleValueCheck NVARCHAR(Max)

				EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																	@pName = '^샘플 개수와 입력 값의 개수가 일치하지 않습니다.^',
																	@pValue = @SampleValueCheck OUTPUT	
				RAISERROR(@SampleValueCheck, 16, 1)
				RETURN
			END
	--------- 2020.08.24 체크사항 추가 End ----------------------------------------------------------------------
	
			DECLARE @DecisionResult VARCHAR(10)    -- 2020.07.16 추가
			DECLARE @DescText        VARCHAR(20)     -- 2020.07.16 추가

			SELECT
					@BefQcStatus = MQI.DecisionResult,
					@GRProcessQty = MQI.ProcessQty,
					@DecisionResult = MQI.DecisionResult,        -- 2020.07.16 추가
					@DescText = MQI.DescText                       -- 2020.07.16 추가
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @CharFOQC + @OldMaterialQcNo	            


			IF ISNULL(@BefQcStatus,'') IN ('Pass') BEGIN
					DECLARE @AlreadyFinish NVARCHAR(MAX)
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																		@pName = '^이미 완료처리된 문서입니다.^',
																		@pValue = @AlreadyFinish OUTPUT	
					RAISERROR(@AlreadyFinish, 16, 1)
					RETURN
			END

            UPDATE STB_MaterialQcInfo
				SET
				    DecisionResult = 'Pass',
					MIIExtText01 = @ProdInspWorkerCode,
				    DecisionDateTime = GETDATE(),
				    DecisionUserID = @pProcessUserID,
				    ChangeDateTime = GETDATE(),
				    ChangeUserID = @pProcessUserID
				WHERE
				    MaterialQcNo = @CharFOQC + @OldMaterialQcNo

			UPDATE	STB_SetInfo
			SET
					LotDecisionResult = 'Pass'
			WHERE
					LotNumber = @CharFOQC + @OldMaterialQcNo

			UPDATE STB_MaterialQcDetail
			SET
					DecisionResult = 'Pass'
			WHERE
					MaterialQcNo = @CharFOQC + @OldMaterialQcNo AND
					ISNULL(DecisionResult, '') = '' 


			DELETE FROM @MaterialDocDetail
			
			INSERT INTO @MaterialDocDetail		(IDX, MaterialDocDetailNo, PickingAssignQty)
			SELECT
					ROW_NUMBER() OVER (ORDER BY MDD.MaterialDocDetailNo)
				,	MDD.MaterialDocDetailNo
				,	MDD.PickingAssignQty
			FROM
					STB_MaterialDocDetail MDD		LEFT OUTER JOIN STB_MaterialDocInfo MDI ON (MDI.MaterialDocNo = MDD.MaterialDocNo)
			WHERE 
					MDD.MaterialIqcNo = @CharFOQC + @OldMaterialQcNo AND
					ISNULL(MDI.IsCancel,0) = 0

			SELECT
					@TotalCount = COUNT(*)
			FROM
					@MaterialDocDetail

			SET @RemainQty = @GRProcessQty
			SET @LoopCount = 1

			WHILE @LoopCount <= @TotalCount
			BEGIN
					SELECT
							@MaterialDocDetailNo = MaterialDocDetailNo,
							@PickingAssingQty = PickingAssignQty
					FROM
							@MaterialDocDetail
					WHERE
							IDX = @LoopCount


					IF @PickingAssingQty >= @RemainQty 
					BEGIN
							UPDATE STB_MaterialDocDetail
							SET
									PickingQty = @RemainQty
							WHERE
									MaterialDocDetailNo = @MaterialDocDetailNo

							SET @RemainQty = 0
					END ELSE BEGIN
							UPDATE STB_MaterialDocDetail
							SET
									PickingQty = @PickingAssingQty
							WHERE
									MaterialDocDetailNo = @MaterialDocDetailNo

							SET @RemainQty = @RemainQty - @PickingAssingQty
					END

					SET @LoopCount = @LoopCount + 1
			END
        END
    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
		
	CLOSE SourceData;
	DEALLOCATE SourceData;
		
	EXEC sp_xml_removedocument @idoc	
END

