-- Procedure: usp_GetAddonStringResource




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-06-18
-- Description:	프로그램용 문자열 리소스를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetAddonStringResource]
	@pLanguage VARCHAR(20),
	@pName NVARCHAR(200),
	@pValue NVARCHAR(500) = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Language VARCHAR(20) = @pLanguage,
			@Name NVARCHAR(200) = @pName,
			@Value NVARCHAR(500)

	SELECT
			@Value = SR.Value
	FROM
			STB_StringResources SR WITH(NOLOCK)
	WHERE
			SR.Language = @Language AND
			SR.Type = 'Addon' AND
			SR.Name = @Name

	IF @Value IS NULL BEGIN
		SET @Value = REPLACE(@pName,'^','')

		INSERT INTO STB_StringResources
		(
			Language,
			Type,
			Name,
			Value
		)
		VALUES
		(
			@Language,
			'Addon',
			@Name,
			@Value
		)		
	END
	SET @pValue = isnull(@Value,@pName) --Add @pName Original by Mr.Tung on 2023-01-18
END





GO

