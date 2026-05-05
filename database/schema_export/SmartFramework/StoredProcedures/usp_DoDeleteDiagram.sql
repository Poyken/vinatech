-- Procedure: usp_DoDeleteDiagram




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-03
-- Browsable: false
-- Description:	Diagram 을 삭제합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_DoDeleteDiagram]
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pSeqNo BIGINT,
	@pDeleteContents BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @SeqNo BIGINT = @pSeqNo

	IF @pDeleteContents = 1 BEGIN 
		DECLARE @FileID BIGINT

		SELECT
				@FileID = D.FileID
		FROM
				STB_Diagrams D
		WHERE
				D.SeqNo = @SeqNo

		EXEC usp_DoDeleteFile @FileID

		DELETE FROM STB_Diagrams
		WHERE	SeqNo = @SeqNo
	END ELSE BEGIN
		UPDATE
				STB_Diagrams
		SET
				IsDelete = 1,
				DeleteDateTime = GETDATE(),
				DeleteUserID  = @pProcessUserID
		WHERE
				SeqNo = @SeqNo
	END
END





GO

