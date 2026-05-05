-- Procedure: usp_DoStartRemoteControlSupport





-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-07-25
-- Description:	지원요청을 합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoStartRemoteControlSupport]
	@pRequestUserID VARCHAR(20),
	@pSeqNo BIGINT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT
			@pSeqNo = ISNULL(MAX(RC.SeqNo),0) + 1
	FROM
			STB_RemoteControlSupport RC
	
	INSERT INTO STB_RemoteControlSupport
	(
		SeqNo,
		RequestUserID,
		StartDateTime		
	)
	VALUES
	(
		@pSeqNo,
		@pRequestUserID,
		GETDATE()
	)
END






GO

