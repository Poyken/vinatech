-- Procedure: usp_DoUpdateSlackMessageSent

-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-21
-- Description: 슬랙 전송여부를 업데이트 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateSlackMessageSent]
	@pId BIGINT
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @id BIGINT = @pId

    UPDATE STB_SlackMessage
	SET
			IsSend = 1,
			SendDateTime = GETDATE()
	WHERE
			Id = @id
END


GO

