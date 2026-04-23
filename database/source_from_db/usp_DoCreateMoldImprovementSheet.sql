
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-19
-- Browsable : true
-- Group : 금형관리
-- Description:	금형문제점개선시트를 생성합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoCreateMoldImprovementSheet]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @TableName VARCHAR(200) = '/DataSet/' + @ProcessViewName
 
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @iDoc INT
	DECLARE	@MoldNumber VARCHAR(50)
	--DECLARE	@RepairHistNo VARCHAR(20)
	DECLARE @ImproveHistNo VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @MoldSeqNo VARCHAR(10)
	
	DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)
			
	EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldImprovementSheet',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	BEGIN TRY
		SELECT
				@WorkCenterCode = XMLData.WorkCenterCode,
				@MoldNumber = XMLData.MoldNumber
		FROM
				OPENXML(@idoc, @TableName, 2)
				WITH(
						WorkCenterCode VARCHAR(20),
						MoldNumber VARCHAR(50)
					) XMLData
	END TRY
	BEGIN CATCH
		SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR(@ERROR_MSG,16,1)
	END CATCH
	
	EXEC sp_xml_removedocument @idoc		


    EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldImprovementSheet',
												@ImproveHistNo OUTPUT
	
	--MoldSeqNo 생성
	SELECT
			@MoldSeqNo = CONVERT(VARCHAR(10),MAX(MIS.MoldSeqNo))
	FROM
			STB_MoldImprovementSheet MIS
	WHERE
			MIS.MoldNumber = @MoldNumber
	
	IF @MoldSeqNo IS NULL BEGIN
		SET @MoldSeqNo = '1'
	END
	ELSE BEGIN
		SET @MoldSeqNo = CONVERT(VARCHAR(10),CONVERT(INT,@MoldSeqNo) + 1)
	END
	
	
	INSERT INTO STB_MoldImprovementSheet
	(
		ImproveHistNo,
		MoldSeqNo,
		MoldNumber,
		WorkCenterCode,
		RegistDate,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@ImproveHistNo,
		@MoldSeqNo,
		@MoldNumber,
		@WorkCenterCode,
		GETDATE(),
		GETDATE(),
		@ProcessUserID
	)
	
END


