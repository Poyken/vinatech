-- Procedure: usp_LabelTypeInfo_popup


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨유형정보
-- Description:	라벨유형정보를 가져옵니다.(POPUP용)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_LabelTypeInfo_popup]
AS
BEGIN
	SET NOCOUNT ON;
    
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
			LTI.IsUsed = 1

END



GO

