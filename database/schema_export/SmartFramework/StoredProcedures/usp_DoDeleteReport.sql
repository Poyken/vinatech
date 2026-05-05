-- Procedure: usp_DoDeleteReport






-- =============================================
-- Author:		Kim Han Young
-- Create date: 2016-01-21
-- Browsable : false
-- Description:	Delete Report
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteReport]
	@pScreenID VARCHAR(50),
	@pSeqNo VARCHAR(4)
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM STB_Reports WHERE ScreenID = @pScreenID AND SeqNo = @pSeqNo
END







GO

