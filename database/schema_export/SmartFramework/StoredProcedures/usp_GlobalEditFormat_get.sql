-- Procedure: usp_GlobalEditFormat_get




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr
-- Create date: 2016-07-27
-- Description: 전역 편집 포맷을 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GlobalEditFormat_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFieldName VARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FieldName VARCHAR(100) = CASE WHEN ISNULL(@pFieldName,'') = '' THEN '*' ELSE @pFieldName END

    SELECT
			GEF.FieldName AS OldFieldName,
			GEF.*
	FROM
			STB_GlobalEditFormat GEF WITH(NOLOCK)
	WHERE
			((@FieldName = '*') OR (GEF.FieldName = @FieldName))
END





GO

