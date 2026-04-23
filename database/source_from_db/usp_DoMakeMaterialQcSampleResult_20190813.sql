
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-03-24
-- Browsable : true
-- Group : 품질관리
-- Description:	시료별 수입검사에서 검사항목의 SampleQty에 따라 샘플 리스트를 생성하는 프로시저
--				이 프로시저로는 SampleQty 이상의 샘플은 자동으로 추가하지 않음. 그 이상은 + 버튼을 눌러 직접 추가하도록 함 
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeMaterialQcSampleResult_20190813]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
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
    DECLARE @MaxKeyInt INT --

    -- Declare Columns Variable
	DECLARE @MaterialQcNo VARCHAR(20)
	DECLARE @MaterialQcDetailNo INT
	DECLARE @SampleQty INT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialQcSampleResult',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
        
			DECLARE @SampleCount INT = 0
			
		    DECLARE SourceData CURSOR FOR
				SELECT
						XMLData.MaterialQcNo,
						XMLData.MaterialQcDetailNo,
						XMLData.SampleQty
				FROM
						OPENXML(@idoc , @UpdateTableName , 2)
				        WITH  (
								 MaterialQcNo VARCHAR(20),
								 MaterialQcDetailNo INT,
								 SampleQty INT
								) XMLData

            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @MaterialQcNo,
								 @MaterialQcDetailNo,
								 @SampleQty

                IF @@FETCH_STATUS <> 0 AND @SampleCount >= @SampleQty BEGIN
					BREAK
				END
				
				SELECT
						@MaxKeyInt = ISNULL(MAX(MaterialQcSampleNo), 0)
				FROM
						STB_MaterialQcSampleResult 
				WHERE
						MaterialQcNo = @MaterialQcNo AND
						MaterialQcDetailNo = @MaterialQcDetailNo
				
				-- 샘플리스트의 맥스값이 SampleQty 보다 클 경우 Break
				IF @MaxKeyInt >= (SELECT
										CASE WHEN ISNULL(SampleQty, 0) = 0 THEN RequestSampleQty ELSE ISNULL(SampleQty, 0) END
								FROM
										STB_MaterialQcDetail 
								WHERE
										MaterialQcNo = @MaterialQcNo AND
										MaterialQcDetailNo = @MaterialQcDetailNo)
				BEGIN
					BREAK
				END
				
				SET @MaxKeyInt += 1
						
                INSERT INTO STB_MaterialQcSampleResult
				(
				    MaterialQcNo,
				    MaterialQcDetailNo,
				    MaterialQcSampleNo,
				    CreateDateTime,
				    CreateUserID
				)
				VALUES
				(
				    @MaterialQcNo,
				    @MaterialQcDetailNo,
				    @MaxKeyInt,
				    GETDATE(),
				    @pProcessUserID
				)
				
				SET @SampleCount += 1

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
END

