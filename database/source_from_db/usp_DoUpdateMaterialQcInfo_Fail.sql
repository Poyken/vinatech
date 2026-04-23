
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-18
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사 불합격을 처리합니다
-- Modified: 불합격처리 시에도 제품검사자 사번을 업데이트하도록 수정 By Jackaroe 2020.05.18
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateMaterialQcInfo_Fail]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null,
	@pProdInspWorkerCode VARCHAR(20) = NULL
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
	DECLARE @ProdInspWorkerCode VARCHAR(20) = @pProdInspWorkerCode

	DECLARE @BefQcStatus VARCHAR(10)

	DECLARE @iDoc INT

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

        WHILE 1 = 1 BEGIN
            FETCH NEXT FROM SourceData INTO @OldMaterialQcNo

            IF @@FETCH_STATUS <> 0 BEGIN
				BREAK
			END

			SELECT
					@BefQcStatus = MQI.DecisionResult
			FROM
					STB_MaterialQcInfo MQI
			WHERE
					MQI.MaterialQcNo = @OldMaterialQcNo	

			-- 어떤 놈이냐 @BefQcStatus를 VARCHAR(1)로 잡아놓은게 찢어죽일테다!!!!
			-- 판정이 된 제품검사 Lot를 재처리 할 수 있도록 아래 조건을 주석처리함. 품질부문 요청. 2019.10.28 By Jackaroe
			--IF ISNULL(@BefQcStatus,'') NOT IN ('None') BEGIN
			--		DECLARE @AlreadyFinish NVARCHAR(MAX)
			--		EXEC SmartFramework.dbo.usp_GetAddonStringResource @pLanguage = @ProcessLanguage,
			--															@pName = '^이미 완료처리된 문서입니다.^',
			--															@pValue = @AlreadyFinish OUTPUT
			--		RAISERROR(@AlreadyFinish, 16, 1)
			--		RETURN
			--END

			-- 대우 루컴즈 부장 요청을 왜 남겨놨... -_-
			-- 2016-11-03 LDS 수정 불합격 판정 1개라도 있어야 처리하게 by 대우루컴즈 송요섭 부장 요청
			/*
			IF (
					SELECT
							COUNT(*)
					FROM
							STB_MaterialQcDetail 
					WHERE 
							MaterialQcNo = @OldMaterialQcNo AND
							ISNULL(DecisionResult,'') = 'Reject'
				) <= 0
			BEGIN
				RAISERROR('불합격 판정이 1건 이상 존재해야 합니다!',16,1)
				RETURN
			END
			*/

            UPDATE STB_MaterialQcInfo
				SET
				    DecisionResult = 'Reject',
				    DecisionDateTime = GETDATE(),
				    DecisionUserID = @pProcessUserID,
					MIIExtText01 = @ProdInspWorkerCode,
				    ChangeDateTime = GETDATE(),
				    ChangeUserID = @pProcessUserID
				WHERE
				    MaterialQcNo = @OldMaterialQcNo
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