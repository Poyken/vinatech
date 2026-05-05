-- Procedure: usp_DoAddStringResource






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-14
-- Browsable : false
-- Description:	Add String Resource
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddStringResource]
	@pProcessLanguage VARCHAR(20),
	@pType VARCHAR(20),
	@pName NVARCHAR(200) OUTPUT,
	@pValue NVARCHAR(500),
	@pDescription NVARCHAR(200) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	IF LEFT(@pName,1) <> '^' BEGIN
		--SET @pName = '%' + @pName
		RETURN
	END
	IF RIGHT(@pName,1) <> '^' BEGIN
		--SET @pName = @pName + '%'
		RETURN
	END
	
	IF LEFT(@pValue,1) = '^' BEGIN
		SET @pValue = SUBSTRING(@pValue,2,100)
	END
	IF RIGHT(@pValue,1) = '^' BEGIN
		SET @pValue = LEFT(@pValue,LEN(@pValue) - 1)
	END

	--RAISERROR('%s /%s /%s/ %s',16,1,@pProcessLanguage, @pType, @pName, @pValue)
	--RETURN
	
	MERGE INTO STB_StringResources AS T
	USING (SELECT 'Default', @pType, @pName, @pValue, @pDescription) AS S (Language, Type, Name, Value, Description)
	ON	(T.Language = S.Language AND T.Type = S.Type AND T.Name = S.Name)
	WHEN NOT MATCHED THEN
		INSERT
		(
			Language,
			Type,
			Name,
			Value,
			Description,
			ChangeDateTime
		)
		VALUES
		(
			S.Language,
			S.Type,
			S.Name,
			S.Value,
			S.Description,
			GETDATE()
		);
		
	MERGE INTO STB_StringResources AS T
	USING (SELECT @pProcessLanguage, @pType, @pName, @pValue, @pDescription) AS S (Language, Type, Name, Value, Description)
	ON	(T.Language = S.Language AND T.Type = S.Type AND T.Name = S.Name)
	WHEN NOT MATCHED THEN
		INSERT
		(
			Language,
			Type,
			Name,
			Value,
			Description,
			ChangeDateTime
		)
		VALUES
		(
			S.Language,
			S.Type,
			S.Name,
			S.Value,
			S.Description,
			GETDATE()
		);
END







GO

