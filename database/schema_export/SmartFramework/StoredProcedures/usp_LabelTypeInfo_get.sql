-- Procedure: usp_LabelTypeInfo_get


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨유형정보
-- Description:	라벨유형정보를 관리합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LabelTypeInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLabelType NVARCHAR(30) = NULL

AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LabelType NVARCHAR(30) = CASE WHEN ISNULL(@pLabelType,'') = '' THEN '*' ELSE @pLabelType END

    
	SELECT
			LTI.LabelType AS OldLabelType,
			LTI.LabelType,
			LTI.LabelTypeName,
			LTI.LabelTypeDesc,
			LTI.IsUsed,
			LTI.CreateDateTime,
			LTI.CreateUserID,
			LTI.ChangeDateTime,
			LTI.ChangeUserID
	FROM
			STB_LabelTypeInfo LTI WITH(NOLOCK)
	WHERE
			((@LabelType = '*') OR (LTI.LabelType = @LabelType)) 

END


GO

