-- Procedure: usp_DoReplyVOC





-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-26
-- Description:	VOC 응답을 작성합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoReplyVOC]
	@pSeqNo BIGINT,
	@pReplyUserID VARCHAR(20),
	@pReplyContents NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

    UPDATE
			STB_VOC
	SET
			ReplyUserID = @pReplyUserID,
			ReplyContents = @pReplyContents,
			ReplyDateTime = GETDATE()
	WHERE
			SeqNo = @pSeqNo
END






GO

