-- Procedure: usp_DoAddDiagramToScreen


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-12
-- Description:	화면에 Diagram 을 추가합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoAddDiagramToScreen]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pDiagramSeqNo BIGINT,
	@pScreenName VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@DiagramSeqNo BIGINT = @pDiagramSeqNo,
			@ScreenName VARCHAR(50) = @pScreenName

	IF NOT EXISTS ( SELECT 1 FROM STB_ScreenDiagrams WHERE Name = @ScreenName AND DiagramSeqNo = @DiagramSeqNo) BEGIN

		INSERT INTO STB_ScreenDiagrams
		(
			Name,
			DiagramSeqNo
		)
		VALUES
		(
			@ScreenName,
			@DiagramSeqNo
		)

	END
END



GO

