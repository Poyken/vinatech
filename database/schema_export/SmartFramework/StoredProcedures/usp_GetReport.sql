-- Procedure: usp_GetReport






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-13
-- Browsable : false
-- Description:	Get Report
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetReport]
	@pScreenID VARCHAR(50),
    @pSeqNo VARCHAR(4) = NULL,
    @pIncludeBinary BIT
AS
BEGIN
	IF (@pSeqNo IS NULL) OR (@pSeqNo = '')
    	SET @pSeqNo = '*'
        
    SELECT 
    		REP.ScreenID AS OLDScreenID,
            REP.SeqNo AS OLDSeqNo,
            REP.ScreenID,
            REP.SeqNo,
            REP.ReportName,
            CASE @pIncludeBinary
            	WHEN 1 THEN REP.ReportLayout
                ELSE NULL
            END AS ReportLayout,
            REP.[Description],
            REP.ChangeDateTime,
            REP.ChangeUserID,
            UI.UserName AS ChangeUserName
    FROM
            dbo.STB_Reports REP WITH(NOLOCK)
			LEFT OUTER JOIN STB_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = REP.ChangeUserID
	WHERE
    		(REP.ScreenID = @pScreenID) AND
            ((@pSeqNo = '*') OR (REP.SeqNo = @pSeqNo))
END







GO

