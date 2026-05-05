-- Procedure: usp_DoUpdateRemoteControlSupport




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-26
-- Description:	원격지원 이력을 업데이트 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoUpdateRemoteControlSupport]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pSeqNo BIGINT,	
	@pSupportContents NVARCHAR(MAX)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SeqNo BIGINT = @pSeqNo

	UPDATE
			STB_RemoteControlSupport
	SET
			SupportUserID = @pProcessUserID,
			SupportContents = @pSupportContents
	WHERE
			SeqNo = @SeqNo
END





GO

