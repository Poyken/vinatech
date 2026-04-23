
-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-30
-- Browsable : true
-- Group : 금형
-- Description:	금형현재보관위치 업데이트 
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateCurrentMoldLocation]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @ERROR_MSG NVARCHAR(MAX)
	DECLARE @iDoc INT,
			@TableName VARCHAR(200)
			
	DECLARE @CurrentIDX INT,
			@rowCnt INT
	
	DECLARE @OldMoldNumber VARCHAR(50),
			@MoldNumber VARCHAR(50),
			@MoldLocationCode VARCHAR(20)
	
	DECLARE @tbMoldLocation TABLE
	(
		IDX INT IDENTITY,
		OldMoldNumber VARCHAR(50),
		MoldNumber VARCHAR(50),
		MoldLocationCode  VARCHAR(20)
	)
	
	SET @TableName = '/DataSet/GetCurrentMoldLocationInfo_UPDATE'
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	BEGIN TRY
			
			INSERT @tbMoldLocation
			SELECT
					XMLData.OldMoldNumber,
					XMLData.MoldNumber,
					XMLData.MoldLocationCode
			FROM
					OPENXML(@idoc , @TableName , 2)
					WITH  (
								OldMoldNumber VARCHAR(50),
								MoldNumber VARCHAR(50),
								MoldLocationCode VARCHAR(20)
							) XMLData
    END TRY
    BEGIN CATCH
        SET @ERROR_MSG = ERROR_MESSAGE()
		RAISERROR( @ERROR_MSG ,16, 1)
    END CATCH
	
    EXEC sp_xml_removedocument @idoc	
    
    
    SET @rowCnt = (SELECT COUNT(*) FROM @tbMoldLocation)
    SET @CurrentIDX = 1
    
    WHILE (@CurrentIDX <= @rowCnt) BEGIN
		
		SELECT
				@OldMoldNumber = OldMoldNumber,
				@MoldNumber = MoldNumber,
				@MoldLocationCode = MoldLocationCode
		FROM
				@tbMoldLocation
		WHERE
				IDX = @CurrentIDX
		
		
		UPDATE	STB_MoldBasicInfo
		SET
			MoldNumber =	CASE
								WHEN @MoldNumber IS NULL THEN MoldNumber
								ELSE @MoldNumber
							END, 
			CurrentPosition =	CASE
									WHEN @MoldLocationCode IS NULL THEN NULL
									ELSE '보관창고'
								END, 
			MoldLocationCode =	CASE
									WHEN @MoldLocationCode IS NULL THEN NULL
									ELSE @MoldLocationCode
								END, 
			ChangeDateTime = GetDate(), 
			ChangeUserID =	@pProcessUserID
		WHERE
			MoldNumber =	CASE
								WHEN @OldMoldNumber IS NOT NULL THEN @OldMoldNumber
								ELSE @MoldNumber
							END

		
		
		SET @CurrentIDX = @CurrentIDX + 1
		
    END
    
END



