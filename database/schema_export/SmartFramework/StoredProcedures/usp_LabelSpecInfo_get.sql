-- Procedure: usp_LabelSpecInfo_get


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨스팩정보
-- Description:	라벨스팩정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LabelSpecInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLabelType NVARCHAR(30) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LabelType NVARCHAR(30) = CASE WHEN ISNULL(@pLabelType,'') = '' THEN '*' ELSE @pLabelType END

    
	SELECT
			LSI.LabelType AS OldLabelType,
			LSI.LabelSpecCode AS OldLabelSpecCode,
			LSI.LabelType,
			LTI.LabelTypeName,
			LSI.LabelSpecCode,
			LSI.LabelSpecName,
			LSI.LabelSpecDesc,
			LSI.CreateDateTime,
			LSI.CreateUserID,
			LSI.ChangeDateTime,
			LSI.ChangeUserID
	FROM
			STB_LabelSpecInfo LSI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LabelTypeInfo LTI
				ON (LTI.LabelType = LSI.LabelType)
	WHERE
			((@LabelType = '*') OR (LSI.LabelType = @LabelType)) 

END



GO

