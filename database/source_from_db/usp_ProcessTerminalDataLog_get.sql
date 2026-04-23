

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-07-24
-- Browsable : true
-- Group : 실적 재처리
-- Description:	Process Terminal Data 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ProcessTerminalDataLog_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromEventDateTime DATETIME = NULL,
	@pToEventDateTime DATETIME = NULL
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @FromEventDateTime DATETIME = @pFromEventDateTime
	DECLARE @ToEventDateTime DATETIME = @pToEventDateTime
	
	IF ISNULL(@FromEventDateTime , '') = ''
	BEGIN
		RAISERROR('No DateTime', 16, 1)
		RETURN
	END

	IF ISNULL(@ToEventDateTime, '') = ''
	BEGIN
		RAISERROR('No DateTime', 16, 1)
		RETURN
	END
    
	SELECT
			--CONVERT(BIT,0) AS IsChecked,
			PTDL.ProcessIndex AS OldProcessIndex,
			PTDL.ProcessIndex AS ProcessLogID,
			PTDL.IPAddress,
			PTDL.PortNo,
			PTDL.Data,
			'Y' AS IsRecovery,
			PTDL.ProcessResult,
			PTDL.ProcessDateTime,
			PTDL.EventDateTime
	FROM
			STB_ProcessTerminalDataLog PTDL WITH(NOLOCK)
	WHERE
			(PTDL.EventDateTime >= @FromEventDateTime)
			AND (PTDL.EventDateTime <= @ToEventDateTime)
	ORDER BY
			PTDL.ProcessIndex

END



