-- Trigger: tgSlackMessageInsert


-- =============================================
-- Author:		Kim Han Young
-- Description:	슬랙메세지 입력 시 전송합니다.
-- =============================================
CREATE TRIGGER [dbo].[tgSlackMessageInsert]
   ON  [dbo].[STB_SlackMessage]
   AFTER INSERT
AS 
BEGIN
	SET NOCOUNT ON;

	DECLARE @Msg TABLE
	(
		Row INT IDENTITY(1,1),
		Id BIGINT
	)
	INSERT INTO @Msg
	(
		Id
	)
    SELECT
			I.Id
	FROM
			inserted I

	DECLARE @Row INT,
			@Count INT
	SELECT
			@Row = 1,
			@Count = COUNT(1)
	FROM
			@Msg

	DECLARE @Id BIGINT

	WHILE @Row <= @Count BEGIN
		SELECT
				@Id = M.Id
		FROM
				@Msg M
		WHERE
				M.Row = @Row

		EXEC usp_CLRSendSlackMessage @Id = @Id

		SET @Row = @Row + 1
	END
END


GO

