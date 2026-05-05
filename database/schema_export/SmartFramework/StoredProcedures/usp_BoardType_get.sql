-- Procedure: usp_BoardType_get


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 게시판
-- Browsable : true
-- Create date: 2017-07-05
-- Description:	게시판유형을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_BoardType_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBoardType VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@BoardType VARCHAR(20) = CASE WHEN ISNULL(@pBoardType,'') = '' THEN '*' ELSE @pBoardType END

	SELECT
			BT.BoardType AS OldBoardType,
			BT.BoardType,
			BT.Title,
			BT.TopImage,
			BT.UseRange,
			BT.CreateDateTime,
			BT.CreateUserID,
			BT.ChangeDateTime,
			BT.ChangeUserID
	FROM
			STB_BoardType BT WITH(NOLOCK)
	WHERE
			((@BoardType = '*') OR (BT.BoardType = @BoardType))
END



GO

