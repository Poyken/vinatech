




-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Find Procedure by keyword
-- =============================================
CREATE PROCEDURE [dbo].[usp_FindProcedure]
	@pKeyword VARCHAR(100)
AS
BEGIN
	DECLARE @Keyword VARCHAR(100) = @pKeyword
    --SELECT
    --        SO.[name],
    --        SC.[text]
    --FROM
    --        syscomments	SC
    --        INNER JOIN sysobjects SO
    --            ON	SO.id = SC.id
    --WHERE
    --        SC.text like '%' + @pKeyword + '%'

	
	DECLARE @Objects TABLE
	(
		[Type] VARCHAR(100),
		[Name] VARCHAR(255),
		[Text] NVARCHAR(MAX)
	)
	INSERT INTO @Objects
	SELECT		
			SO.type,
			SO.name	,
			SM.definition
		FROM
				sysobjects SO
				INNER JOIN sys.sql_modules SM
					ON	SM.object_id = SO.id
		WHERE
				SO.type IN ('P','FN','TR')


	SELECT 
			*
	FROM 
			@Objects O
	WHERE
			O.text like '%' + @pKeyword + '%'
	ORDER BY
			O.Type
END






