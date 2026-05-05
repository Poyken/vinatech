-- Procedure: usp_RemoteControlSupport_get




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-26
-- Description:	원격지원 이력을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_RemoteControlSupport_get]
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromDate DATE = @pFromDate,
			@ToDate DATE = DATEADD(DD, 1, @pToDate)

	SELECT
			SCSH.SeqNo AS OldSeqNo,
			SCSH.*
	FROM
			STB_RemoteControlSupport SCSH WITH(NOLOCK)
	WHERE
			(@FromDate <= SCSH.StartDateTime) AND
			(SCSH.StartDateTime < @ToDate)
END





GO

