-- Procedure: usp_GetSlackMessages

-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : System
-- Browsable : true
-- Create date: 2017-07-21
-- Description:	전송할 슬랙메세지를 가져옵니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetSlackMessages]
	@pId INT = NULL
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Id BIGINT = CASE WHEN @pId IS NULL THEN -1 ELSE @pId END

	SELECT
			SM.Id,
			SM.Url,
			SM.Title,
			SM.Text,
			SM.Author,
			SM.[User],
			SM.BarColor,
			SM.Fields,
			SM.CreateDateTime,
			SM.CreateUserID
	FROM
			STB_SlackMessage SM WITH(NOLOCK)
	WHERE
			((@Id = -1) OR (SM.Id = @Id)) AND
			SM.IsSend = 0
END


GO

