-- Procedure: usp_DoSaveBoardThread


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 게시판
-- Browsable : true
-- Create date: 2017-07-06
-- Description:	게시글을 저장합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveBoardThread]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pThreadNo VARCHAR(20) = NULL OUTPUT,
	@pBoardType VARCHAR(20),
	@pTitle NVARCHAR(200),
	@pContents NVARCHAR(MAX),
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@ThreadNo VARCHAR(20) = @pThreadNo

	IF ISNULL(@ThreadNo,'') = '' BEGIN

		EXEC usp_DoCreateSerial @pTableName = 'STB_Board',
								@pSerialNo = @pThreadNo OUTPUT
		INSERT INTO STB_Board
		(
			ThreadNo,
			BoardType,
			Title,
			Contents,
			ReadCount,
			FromDate,
			ToDate,
			CreateDateTime,
			CreateUserID
		)
		VALUES
		(
			@pThreadNo,
			@pBoardType,
			@pTitle,
			@pContents,
			0,
			@pFromDate,
			@pToDate,
			GETDATE(),
			@ProcessUserID
		)
	END ELSE BEGIN
		UPDATE	STB_Board
		SET
				Title = @pTitle,
				Contents = @pContents,
				FromDate = @pFromDate,
				ToDate = @pToDate,
				ChangeDateTime = GETDATE()
		WHERE
				ThreadNo = @ThreadNo
	END
END



GO

