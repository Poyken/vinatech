-- Procedure: usp_DoSaveReport






-- =============================================
-- Author:		Kim Han Young
-- Browsable : false
-- Create date: 2015-01-21
-- Description:	Save Report
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoSaveReport]
	@pScreenID VARCHAR(50),
	@pSeqNo VARCHAR(20) OUTPUT,
	@pReportName NVARCHAR(100),
	@pReportLayout NVARCHAR(MAX),
	@pDescription NVARCHAR(MAX) = NULL,
	@pProcessUserID VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    IF EXISTS ( SELECT 1 FROM STB_Reports R WHERE R.ScreenID = @pScreenID AND R.SeqNo = @pSeqNo) BEGIN

		UPDATE STB_Reports
		SET
				ReportName = @pReportName,
				ReportLayout = @pReportLayout,
				Description = @pDescription,
				ChangeDateTime = GETDATE(),
				ChangeUserID = @pProcessUserID
		WHERE
				ScreenID = @pScreenID AND
				SeqNo = @pSeqNo
    END ELSE BEGIN
    
		SELECT
			
    			@pSeqNo = dbo.fnMakeZeroNumber(CONVERT(INT,ISNULL(MAX(REP.SeqNo),'0000'))+1,4)
		FROM
    			STB_Reports REP
		WHERE
    			REP.ScreenID = @pScreenID
    			
    	INSERT INTO STB_Reports
    	(
    		ScreenID,
    		SeqNo,
    		ReportName,
    		ReportLayout,
    		Description,
    		ChangeDateTime,
    		ChangeUserID
    	)    	
    	VALUES
    	(
    		@pScreenID,
    		@pSeqNo,
    		@pReportName,
    		@pReportLayout,
    		@pDescription,
    		GETDATE(),
    		@pProcessUserID
    	)
    END
END







GO

