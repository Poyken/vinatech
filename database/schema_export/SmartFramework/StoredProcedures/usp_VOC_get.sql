-- Procedure: usp_VOC_get




-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-26
-- Description:	VOC 이력을 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_VOC_get]
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,
	@pSeqNo BIGINT = NULL,
	@pIncludeSnapshot BIT = 0
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @FromDate DATE = @pFromDate,
			@ToDate DATE = DATEADD(DD, 1, @pToDate),
			@SeqNo BIGINT = @pSeqNo,
			@IncludeSnapshot BIT = @pIncludeSnapshot

	SELECT
			V.SeqNo AS OldSeqNo,
			V.SeqNo,
			V.UserID,
			V.Phone,
			V.Email,
			ISNULL(V.Title,'') AS Title,
			REPLACE(REPLACE(REPLACE(V.Contents, CHAR(1), ''), CHAR(2), ''), CHAR(0X1E), '') AS Contents,
			V.CreateDateTime,
			V.ReplyUserID,
			V.ReplyContents,
			V.ReplyDateTime,
			CASE @IncludeSnapshot
				WHEN 1 THEN V.Snapshot
				ELSE NULL
			END AS Snapshot,
			ISNULL(UI.UserName,'Unknown') AS CreateUserName,
			RUI.UserName AS ReplyUserName,
			CONVERT(BIT,
			CASE
				WHEN ISNULL(V.ReplyContents,'') = '' THEN 0
				ELSE 1
			END) AS IsReply
	FROM
			STB_VOC V WITH(NOLOCK)
			LEFT OUTER JOIN STB_UserInfo UI WITH(NOLOCK)
				ON	UI.UserID = V.UserID
			LEFT OUTER JOIN STB_UserInfo RUI WITH(NOLOCK)
				ON	RUI.UserID = V.ReplyUserID
	WHERE
			((@SeqNo IS NOT NULL) OR (@FromDate IS NULL) OR (@FromDate <= V.CreateDateTime)) AND
			((@SeqNo IS NOT NULL) OR (@ToDate IS NULL) OR (V.CreateDateTime < @ToDate)) AND
			(@SeqNo IS NULL OR V.SeqNo = @SeqNo)
	ORDER BY
			V.CreateDateTime DESC
END





GO

