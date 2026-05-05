-- Procedure: usp_DoAddStringResourceByXml






-- =============================================
-- Author:		Kim Han Young
-- Browsable : false
-- Create date: 2016-01-14
-- Description:	Save String Resource by XML
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddStringResourceByXml]
	@pXml NVARCHAR(MAX),
	@pProcessUserID VARCHAR(20),
	@pScreenName VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @iDoc INT,
			@ScreenName VARCHAR(50) = @pScreenName
	
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
    BEGIN TRY 
		DECLARE @Resource TABLE
		(
			ROW INT IDENTITY(1,1),
			Language VARCHAR(20),
			Name NVARCHAR(50),
			Value NVARCHAR(100)
		)
		INSERT INTO @Resource
		SELECT
				Language,
				Name,
				Value
		FROM
				OPENXML(@idoc , '/ArrayOfStringResource/StringResource' , 2)
				WITH  (
								 Language VARCHAR (20),
								 Name NVARCHAR (50),
								 Value NVARCHAR (100)
						)
						
		SELECT * FROM @Resource
		DECLARE @ROW INT = 1,
				@COUNT INT,
				@Language VARCHAR(20),
				@Name NVARCHAR(50),
				@Value NVARCHAR(100)
				
		SELECT @COUNT = COUNT(1) FROM @Resource
		
		WHILE @ROW <= @COUNT BEGIN
			SELECT
					@Language = R.Language,
					@Name = R.Name,
					@Value = R.Value
			FROM
					@Resource R
			WHERE
					R.ROW = @ROW
					
			EXEC usp_DoAddStringResource @pProcessLanguage = @Language,
										 @pType = 'Addon',
										 @pName = @Name,
										 @pValue = @Value
					
			SET @ROW = @ROW + 1
		END

		IF ISNULL(@ScreenName,'') <> '' BEGIN
			DELETE FROM STB_ScreenStringResources
			WHERE	ScreenName = @ScreenName

			INSERT INTO STB_ScreenStringResources
			(
				ScreenName,
				ResourceName
			)
			SELECT
					DISTINCT
					@ScreenName,
					R.Name
			FROM
					@Resource R
		END

		EXEC sp_xml_removedocument @iDoc
	END TRY
	BEGIN CATCH
		EXEC sp_xml_removedocument @iDoc
		DECLARE @ERROR NVARCHAR(MAX) = ERROR_MESSAGE()
		RAISERROR(@ERROR,16,1)
	END CATCH
END







GO

