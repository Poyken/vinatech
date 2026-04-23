-- =============================================
-- Author:	    Anonymous()
-- Create date: 2017-06-29
-- Browsable : true
-- Group : SmartCTQ
-- Description:	샘플합격품질수준정보를 저장합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_AqlBasicRule_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pAQL VARCHAR(10) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @AQL VARCHAR(10) = CASE WHEN ISNULL(@pAQL,'') = '' THEN '*' ELSE @pAQL END

    
	SELECT
			ABR.AQL AS OldAQL,
			ABR.SampleChar AS OldSampleChar,
			ABR.AQL,
			ABR.SampleChar,
			ABR.MaxAllowDefectQty,
			ABR.IsBasicRule,
			ABR.CreateDateTime,
			ABR.CreateUserID,
			ABR.ChangeDateTime,
			ABR.ChangeUserID
	FROM
			STB_AqlBasicRule ABR WITH(NOLOCK)
	WHERE
			((@AQL = '*') OR (ABR.AQL = @AQL)) 

END
