
-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-19
-- Description:	수불문서 상세번호를 생성합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoMakeMaterialDocDetailNo]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pMaterialDocDetailNo VARCHAR(20) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ProcessUserID VARCHAR(20) = @pProcessUserID

    DECLARE @IsAutoKey BIT
	DECLARE @IsLoopIUD BIT
	DECLARE @PrefixString VARCHAR(20)
	DECLARE @SerialLen INT
    DECLARE @MaxKeyField VARCHAR(20)
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)

	SELECT
			@CompanyCode = UI.CompanyCode,
			@WorkCenterCode = UI.WorkCenterCode
	FROM
			STB_UserInfo UI
	WHERE
			UI.UserID = @ProcessUserID
	
	EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MaterialDocDetail',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT

	SELECT
			@MaxKeyField = MAX(MaterialDocDetailNo)
	FROM
			STB_MaterialDocDetail
	WHERE
			MaterialDocDetailNo LIKE @PrefixString + '%'
													
	IF @MaxKeyField IS NULL BEGIN
		SET @pMaterialDocDetailNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
	END ELSE BEGIN
		SET @pMaterialDocDetailNo = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
	END
END

