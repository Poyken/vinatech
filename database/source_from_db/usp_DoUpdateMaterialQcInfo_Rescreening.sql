
-- =============================================
-- Author: kilee
-- Create date: 2019-08-19
-- Browsable : true
-- Group : 제품검사 > 재선별
-- Description:	재선별하여 특채사유 입력후에 합격처리합니다.
-- Modified:

-- Test:  Exec usp_DoUpdateMaterialQcInfo_Rescreening '','','','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateMaterialQcInfo_Rescreening]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pProdInspWorkerCode VARCHAR(20)
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
	DECLARE @BefQcStatus VARCHAR(10)
	DECLARE @SpecialAcceptDesc VARCHAR(10)                                       -- 추가부분
	 
	DECLARE @ProdInspWorkerCode VARCHAR(20) = @pProdInspWorkerCode
	
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
	    DECLARE SourceData CURSOR
		
		FOR
				SELECT
						CASE 
							WHEN XMLData.OldMaterialQcNo IS NULL THEN XMLData.MaterialQcNo
							ELSE XMLData.OldMaterialQcNo
						END AS OldMaterialIqcNo
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 OldMaterialQcNo VARCHAR(20),
								 MaterialQcNo VARCHAR(20)
								) XMLData
        OPEN SourceData

        WHILE 1 = 1 
		
		BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo

            IF @@FETCH_STATUS <> 0 
			
			BEGIN
				BREAK
			END

			---- 추가 Start
			--IF @@SpecialAcceptDesc IS NULL 
			
			--BEGIN
			--	BREAK
			--END
			---- 추가 End



			SELECT
					@BefQcStatus = MQI.DecisionResult,
					@GRProcessQty = MQI.ProcessQty,
					@SpecialAcceptDesc =  MQI.SpecialAcceptDesc                                    -- 추가부분
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	

			IF ISNULL(@BefQcStatus,'') IN ('Pass') 
			
			BEGIN
					DECLARE @AlreadyFinish NVARCHAR(MAX)
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
													   									  @pName = '^이미 합격 처리된 제품입니다.^',
																						  @pValue = @AlreadyFinish OUTPUT	
					RAISERROR(@AlreadyFinish, 16, 1)
					RETURN
			END


			-- 추가 2  (kilee)
			IF @SpecialAcceptDesc = NULL
			
			BEGIN
					DECLARE @AlreadyFinish2 NVARCHAR(MAX)
					EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
													   									  @pName = '^특채사유를 입력하고 저장하신 후에 재선별 처리를 다시 진행바랍니다.^',
																						  @pValue = @AlreadyFinish2 OUTPUT	
					RAISERROR(@AlreadyFinish2, 16, 1)
					RETURN
			END
			-- 추가 2  (kilee)


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

			UPDATE	STB_SetInfo
			SET LotDecisionResult = 'Pass'
			WHERE LotNumber = @OldMaterialQcNo

			UPDATE STB_MaterialQcDetail
			SET DecisionResult = 'Pass'
			WHERE
					MaterialQcNo = @OldMaterialQcNo AND
					ISNULL(DecisionResult, '') = '' 


			DELETE FROM @MaterialDocDetail
			
			INSERT INTO @MaterialDocDetail		(IDX, MaterialDocDetailNo, PickingAssignQty)
			SELECT ROW_NUMBER() OVER (ORDER BY MDD.MaterialDocDetailNo)
				  ,	MDD.MaterialDocDetailNo
				  ,	MDD.PickingAssignQty
			FROM
					STB_MaterialDocDetail MDD		LEFT OUTER JOIN STB_MaterialDocInfo MDI ON (MDI.MaterialDocNo = MDD.MaterialDocNo)
			WHERE 
					MDD.MaterialIqcNo = @OldMaterialQcNo AND
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

