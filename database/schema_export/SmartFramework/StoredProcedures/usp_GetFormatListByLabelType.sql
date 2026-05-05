-- Procedure: usp_GetFormatListByLabelType


-- =============================================
-- Author:	    Park Jong Seob(jspark@awoo.co.kr)
--- Create date: 2016-05-29
-- Browsable : true
-- Group : 라벨정보
-- Description:	라벨유형와 포멧정보를 정보를 가져옵니다.
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetFormatListByLabelType]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLabelType NVARCHAR(30) = NULL,
	@pCommandType VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @LabelType NVARCHAR(30) = CASE WHEN ISNULL(@pLabelType,'') = '' THEN '*' ELSE @pLabelType END
	DECLARE @CommandType VARCHAR(20) = CASE WHEN ISNULL(@pCommandType,'') = '' THEN '*' ELSE @pCommandType END
    
	SELECT
			DISTINCT
			LI.LabelType,
			LTI.LabelTypeName,
			LI.FormatName,
			LI.CommandType,
			LI.Dpi
	FROM
			STB_LabelInfo LI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LabelTypeInfo LTI WITH(NOLOCK)
				ON (LTI.LabelType = LI.LabelType)
	WHERE
			((@LabelType = '*') OR (LI.LabelType = @LabelType)) AND
			((@CommandType = '*') OR (LI.CommandType = @CommandType))

END



GO

