
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-18
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사 합격을 처리합니다
-- Modified:
-- 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateMaterialQcInfo_Success]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20)=null,
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

	DECLARE @PassedSampleQty INT    -- 2020.08.24 추가
	DECLARE @SampleTotalQty INT

	Declare @CompanyCode VARCHAR(20) -- 2022.03.21  추가 By Jackaroe
	Declare @WorkerCompanyCode VARCHAR(20) -- 2022.09.26 추가 By Jackaroe
	
	DECLARE @iDoc INT
	
	DECLARE @MaterialDocDetail TABLE
		(
			IDX INT,
			MaterialDocDetailNo VARCHAR(20),
			PickingAssignQty NUMERIC(20,5)
		)

	SELECT @WorkerCompanyCode = CompanyCode
	  FROM STB_UserInfo
	 WHERE UserID = @pProcessUserID

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
						CASE WHEN XMLData.OldMaterialQcNo IS NULL THEN XMLData.MaterialQcNo ELSE XMLData.OldMaterialQcNo END AS OldMaterialIqcNo,
						XMLData.CompanyCode AS CompanyCode
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 OldMaterialQcNo VARCHAR(20),
								 MaterialQcNo VARCHAR(20),
								 CompanyCode VARCHAR(20)
								) XMLData
        OPEN SourceData

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo, @CompanyCode

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			-- 샘플이 생성되어 있는 경우 샘플 수와 입력된 데이터 수가 다르면 처리 불가. 품질부문 요청 2019.10.28 By Jackaroe
			-- 샘플 종류별로 카운트 하지 않고, 전체 샘플 수량으로 비교한다. 이후 요청이 있을 경우 세분화 시켜야 할 수도 있음.
			
			-- [1] 전체 검사수
			SELECT @SampleCreateCount = COUNT(*)
			  FROM STB_MaterialQcSampleResult with(nolock) 
			 WHERE MaterialQcNo = @OldMaterialQcNo
			                   
							    -- [1]번 검증
								 --SELECT  SampleCreateCount, * 
								 -- FROM STB_MaterialQcSampleResult
								 --WHERE MaterialQcNo = 'VJKQ182R710609'


			 -- [2] 검사입력수
			 SELECT @SampleInputCount = COUNT(*)
			  FROM STB_MaterialQcSampleResult with(nolock) 
			 WHERE MaterialQcNo = @OldMaterialQcNo
			   AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), TestValue), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), TestResult), '')) <> '')
			                         
									 -- [2]번검증
							         -- SELECT  *
									 -- FROM STB_MaterialQcSampleResult
									 --WHERE MaterialQcNo = 'VJKQ182R710609'
									 --  AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), TestValue), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), TestResult), '')) <> '')

            -- 검사수량 비교처리 미적용 이미정프로 요청 #220311 By Jackaroe
			-- 본사에서 베트남 제품검사를 진행하는 경우가 있으므로 작업자의 CompanyCode를 조건에 추가함.
			IF @CompanyCode='VVT' and @SampleCreateCount <> @SampleInputCount AND @WorkerCompanyCode = 'VVT'     -- 전체검사항목에 입력했는지 체크 / [1]번과 [2]번 비교
			
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
			-- 외관 검사의 경우 측정값을 입력하지 않으므로 입력된 값의 개수와 샘플수량이 아닌 샘플수량과 합격수량을 비교하도록 로직 수정 2021.10.27 by Jackaroe
			 SELECT @PassedSampleQty = SUM(PassedSampleQty)
			       ,@SampleTotalQty = SUM(SampleQty)
			  FROM STB_MaterialQcDetail with(nolock) 
			 WHERE 1=1
			   AND  MaterialQcNo = @OldMaterialQcNo			   
			   AND (RTRIM(IsNull(Convert(VARCHAR(10), SampleQty), '')) <> '' Or  RTRIM(IsNull(Convert(VARCHAR(10), SampleQty), '')) <> '')
			   and QcInspectionItemCode !='IQC_GPD_21'

			                         -- [3]수량 검증쿼리
							         --SELECT  SUM(SampleQty) AS SampleQty                                  -- 23개
									 -- FROM STB_MaterialQcDetail
									 --WHERE 1=1									 
									 --  AND  MaterialQcNo = 'VJKQ182R710609'
									 --  AND ( RTRIM(ISNULL(CONVERT(VARCHAR(10), SampleQty), '')) <> '' Or  RTRIM(ISNULL(CONVERT(VARCHAR(10), SampleQty), '')) <> '')
									 --  And QcInspectionItemCode in ('IQC_GPD_18','IQC_GPD_19','IQC_GPD_20')       --SD, ESR, 용량
                                     -- Group by MaterialQcDetailNo 

			-- 검사수량 비교처리 미적용 이미정프로 요청 #220311 By Jackaroe


			--RAISERROR(@SampleTotalQty, 16, 1)
			IF @CompanyCode='VVT' and (@SampleTotalQty <> @PassedSampleQty AND @SampleTotalQty <> @SampleInputCount) AND @WorkerCompanyCode = 'VVT'     --2021.10.27 by Jackaroe
			
			BEGIN
				Declare @SampleValueCheck NVARCHAR(Max)

				EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																	@pName = '^샘플 개수와 합격수량이 일치하지 않습니다.^',
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
					STB_MaterialQcInfo MQI with(nolock) 
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	            


			IF ISNULL(@BefQcStatus,'') IN ('Pass') BEGIN
					DECLARE @AlreadyFinish NVARCHAR(MAX)
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
																		@pName = '^이미 완료처리된 문서입니다.^',
																		@pValue = @AlreadyFinish OUTPUT	
					RAISERROR(@AlreadyFinish, 16, 1)
					RETURN
			END

			PRINT 'Start Update 1 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

            UPDATE STB_MaterialQcInfo
				SET
				    DecisionResult = 'Pass',
					MIIExtText01 = @ProdInspWorkerCode,
				    DecisionDateTime = GETDATE(),
				    DecisionUserID = @pProcessUserID,
				    ChangeDateTime = GETDATE(),
				    ChangeUserID = @pProcessUserID
				WHERE
				    MaterialQcNo = @OldMaterialQcNo

			PRINT 'Start Update 2 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

			UPDATE	STB_SetInfo
			SET
					LotDecisionResult = 'Pass'
			WHERE
					LotNumber = @OldMaterialQcNo

			PRINT 'Start Update 3 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

			UPDATE STB_MaterialQcDetail
			SET
					DecisionResult = 'Pass'
			WHERE
					MaterialQcNo = @OldMaterialQcNo AND
					ISNULL(DecisionResult, '') = '' 

			PRINT 'Start Update 4 : ' + CONVERT(VARCHAR(20), GETDATE(), 121)


			DELETE FROM @MaterialDocDetail
			
			INSERT INTO @MaterialDocDetail		(IDX, MaterialDocDetailNo, PickingAssignQty)
			SELECT
					ROW_NUMBER() OVER (ORDER BY MDD.MaterialDocDetailNo)
				,	MDD.MaterialDocDetailNo
				,	MDD.PickingAssignQty
			FROM
					STB_MaterialDocDetail MDD with(nolock) 		
			LEFT OUTER JOIN STB_MaterialDocInfo MDI with(nolock)  ON (MDI.MaterialDocNo = MDD.MaterialDocNo)
			WHERE 
					MDD.MaterialIqcNo = @OldMaterialQcNo AND
					ISNULL(MDI.IsCancel,0) = 0

			SELECT
					@TotalCount = COUNT(*)
			FROM
					@MaterialDocDetail

			SET @RemainQty = @GRProcessQty
			SET @LoopCount = 1

			PRINT 'Start While : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

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

		PRINT 'End While : ' + CONVERT(VARCHAR(20), GETDATE(), 121)

    END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
	END CATCH
		
	CLOSE SourceData;
	DEALLOCATE SourceData;
		
	EXEC sp_xml_removedocument @idoc	
END

