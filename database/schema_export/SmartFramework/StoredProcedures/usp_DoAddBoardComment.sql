-- Procedure: usp_DoAddBoardComment

-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 게시판
-- Browsable : false
-- Create date : 2017-08-23
-- Description : 댓글을 작성합니다.
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddBoardComment]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pThreadNo VARCHAR(20),
	@pComment NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@CommentNo VARCHAR(20)

	EXEC usp_DoCreateSerial 'STB_BoardComment',@CommentNo OUTPUT
	INSERT INTO STB_BoardComment
	(
		CommentNo,
		ThreadNo,
		Comment,
		CreateDateTime,
		CreateUserID
	)
	VALUES
	(
		@CommentNo,
		@pThreadNo,
		@pComment,
		GETDATE(),
		@ProcessUserID
	)
END


GO

