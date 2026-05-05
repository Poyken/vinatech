-- Procedure: usp_DoRemoveDiagramFromScreen


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : false
-- Create date: 2017-07-12
-- Description:	화면에서 Diagram 을 제거합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoRemoveDiagramFromScreen]
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

	DELETE FROM STB_ScreenDiagrams
	WHERE
			Name = @ScreenName AND
			DiagramSeqNo = @DiagramSeqNo
END



GO

