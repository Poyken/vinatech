-- Procedure: usp_DoUpdateVOC




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-26
-- Description:	VOC 이력을 업데이트 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateVOC]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pSeqNo BIGINT,
	@pReplyContents NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SeqNo BIGINT = @pSeqNo

	UPDATE
			STB_VOC
	SET
			ReplyUserID = @pProcessUserID,
			ReplyContents = @pReplyContents,
			ReplyDateTime = GETDATE()
	WHERE
			SeqNo = @SeqNo
END





GO

