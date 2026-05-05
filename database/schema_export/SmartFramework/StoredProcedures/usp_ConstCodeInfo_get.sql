-- Procedure: usp_ConstCodeInfo_get






-- =============================================
-- Author:		Kim Han Young
-- Browsable: true
-- Create date: 2015-01-19
-- Description:	상수코드를 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_ConstCodeInfo_get]
	@pConstName NVARCHAR(100) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ConstName NVARCHAR(100) = CASE WHEN ISNULL(@pConstName,'') = '' THEN '*' ELSE @pConstName END

	--THROW 51000, 'The record does not exist.', 1;  

    SELECT
			CCI.ConstName AS OldConstName,
			CCI.*
    FROM
			STB_ConstCodeInfo CCI WITH(NOLOCK)
	WHERE
			((@ConstName = '*') OR (CCI.ConstName = @ConstName))
END







GO

