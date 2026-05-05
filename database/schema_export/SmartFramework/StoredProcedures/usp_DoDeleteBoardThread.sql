-- Procedure: usp_DoDeleteBoardThread


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 게시판
-- Browsable : true
-- Create date: 2017-07-06
-- Description:	게시판 글을 삭제합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteBoardThread]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pThreadNo VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ThreadNo VARCHAR(20) = @pThreadNo

	DELETE FROM STB_Board
	WHERE
			ThreadNo = @ThreadNo

	DELETE FROM STB_BoardComment
	WHERE
			ThreadNo = @ThreadNo
END



GO

