-- Procedure: usp_GetDiagrams




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-03
-- Browsable: false
-- Description:	Diagram 을 조회합니다
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetDiagrams]
	@pProcessUserID VARCHAR(20),
	@pKeyword NVARCHAR(100) = NULL,
	@pScreenName VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @Keyword NVARCHAR(100) = CASE WHEN ISNULL(@pKeyword,'') = '' THEN '*' ELSE @pKeyword END
	DECLARE @ScreenName NVARCHAR(50) = CASE WHEN ISNULL(@pScreenName,'') = '' THEN '*' ELSE @pScreenName END
	DECLARE @SystemCode VARCHAR(20)

	SELECT
			@SystemCode = UI.SystemCode
	FROM
			STB_UserInfo UI WITH(NOLOCK)
	WHERE
			UI.UserID = @ProcessUserID

	IF @ScreenName = '*' BEGIN
		SELECT
				D.*
		FROM
				STB_Diagrams D WITH(NOLOCK)
		WHERE
				D.SystemCode = @SystemCode AND
				D.IsDelete = 0 AND
				((@Keyword = '*') OR ( D.Keywords LIKE '%' + @pKeyword + '%'))
	END ELSE BEGIN
		SELECT
				D.*
		FROM
				STB_ScreenDiagrams SD WITH(NOLOCK)
				INNER JOIN STB_Diagrams D
					ON	D.SeqNo = SD.DiagramSeqNo
		WHERE
				SD.Name = @ScreenName AND
				D.SystemCode = @SystemCode
	END
END





GO

