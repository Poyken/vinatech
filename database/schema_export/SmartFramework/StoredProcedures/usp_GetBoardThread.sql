-- Procedure: usp_GetBoardThread


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 게시판
-- Browsable : true
-- Create date: 2017-07-06
-- Description:	게시판 글 내용을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBoardThread]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBoardType VARCHAR(20),
	@pThreadNo VARCHAR(20),
	@pIncludeComment BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@BoardType VARCHAR(20) = @pBoardType,
			@ThreadNo VARCHAR(20) = @pThreadNo
	SELECT
			BT.TopImage,
			BT.UseRange,
			BT.Title
	FROM
			STB_BoardType BT WITH(NOLOCK)
	WHERE
			BT.BoardType = @BoardType

	SELECT
			CONVERT(BIGINT,0) AS No,
			B.*,
			CONVERT(BIT, CASE 
				WHEN DATEDIFF(DD, B.CreateDateTime, GETDATE()) < 3 THEN 1
				ELSE 0
			END) AS IsNew,
			(
				SELECT
						COUNT(1)
				FROM
						STB_BoardComment BC WITH(NOLOCK)
				WHERE
						BC.ThreadNo = B.ThreadNo
			) AS CommentCount,
			UI.UserName AS CreateUserName,
			BT.UseRange
	FROM
			STB_Board B WITH(NOLOCK)
			LEFT OUTER JOIN STB_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = B.CreateUserID
			LEFT OUTER JOIN STB_BoardType BT WITH(NOLOCK)
				ON	BT.BoardType = B.BoardType
	WHERE
			B.ThreadNo = @ThreadNo

	UPDATE	STB_Board
	SET
			ReadCount = ISNULL(ReadCount,0) + 1
	WHERE
			ThreadNo = @ThreadNo AND
			CreateUserID <> @ProcessUserID

	IF @pIncludeComment = 1 BEGIN
		SELECT
				BC.Comment,
				BC.CreateDateTime,
				BC.CreateUserID,
				UI.UserName AS CreateUserName
		FROM
				STB_BoardComment BC WITH(NOLOCK)
				LEFT OUTER JOIN STB_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = BC.CreateUserID
		WHERE
				BC.ThreadNo = @ThreadNo
	END
END



GO

