-- Procedure: usp_PaperTypeInfo_get



-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-30
-- Browsable : true
-- Group : 용지유형정보
-- Description:	용지유형정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_PaperTypeInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pPaperType NVARCHAR(30) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @PaperType NVARCHAR(30) = CASE WHEN ISNULL(@pPaperType,'') = '' THEN '*' ELSE @pPaperType END

    
	SELECT
			PTI.PaperType AS OldPaperType,
			PTI.PaperType,
			PTI.PaperTypeName,
			PTI.IsUsed,
			PTI.CreateDateTime,
			PTI.CreateUserID,
			PTI.ChangeDateTime,
			PTI.ChangeUserID
	FROM
			STB_PaperTypeInfo PTI WITH(NOLOCK)
	WHERE
			((@PaperType = '*') OR (PTI.PaperType = @PaperType)) 

END




GO

