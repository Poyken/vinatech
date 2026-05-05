-- Procedure: usp_DoStopRemoteControlSupport




-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-07-25
-- Description:	원격제어 지원을 종료합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoStopRemoteControlSupport]
	@pSeqNo BIGINT
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SeqNo BIGINT = @pSeqNo

	UPDATE	STB_RemoteControlSupport
	SET
			EndDateTime = GETDATE()
	WHERE
			SeqNo = @SeqNo
END





GO

