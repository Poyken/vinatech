-- Procedure: usp_GetBoardThreads


-- =============================================
-- Author: Kim Han Young(hykim@awoo.co.kr)
-- Group : 게시판
-- Browsable : true
-- Create date: 2017-07-06
-- Description:	게시판 글 리스트를 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBoardThreads]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBoardType VARCHAR(20) = NULL,
	@pPageSize INT = 10,
	@pPageNo INT = 1,
	@pTotalCount INT = NULL OUTPUT,
	@pTotalPage INT = NULL OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage,
			@BoardType VARCHAR(20) = @pBoardType,
			@PageSize INT = @pPageSize,
			@PageNo INT = @pPageNo,
			@UseRange BIT,
			@Today DATE = GETDATE()

	SELECT
			BT.TopImage,
			BT.UseRange,
			BT.Title
	FROM
			STB_BoardType BT WITH(NOLOCK)
	WHERE
			BT.BoardType = @BoardType
	
	SELECT
			@pTotalCount = COUNT(*)
	FROM
			STB_Board B WITH(NOLOCK)
	WHERE
			B.BoardType = @BoardType AND
			((B.FromDate IS NULL OR B.FromDate <= @Today) AND
			(B.ToDate IS NULL OR @Today <= B.ToDate))

	SET @pTotalPage = @pTotalCount / @PageSize
	IF (@pTotalCount % @PageSize) > 0
		SET @pTotalPage = @pTotalPage + 1
	;
	WITH Board AS
	(
		SELECT
				
				TOP (@PageSize * @PageNo)
				ROW_NUMBER() OVER(ORDER BY B.CreateDateTime DESC) AS No,
				B.*,
				CONVERT(BIT, CASE 
					WHEN DATEDIFF(DD, B.CreateDateTime, GETDATE()) < 3 THEN 1
					ELSE 0
				END) AS IsNew,
				(
					SELECT
							COUNT(1)
					FROM
							STB_BoardComment BC WITH(NOLOCK)
					WHERE
							BC.ThreadNo = B.ThreadNo
				) AS CommentCount,
				UI.UserName AS CreateUserName
		FROM
				STB_Board B WITH(NOLOCK)
				LEFT OUTER JOIN STB_UserInfo UI WITH(NOLOCK)
					ON	UI.UserID = B.CreateUserID
		WHERE
				B.BoardType = @BoardType AND
				((B.FromDate IS NULL OR B.FromDate <= @Today) AND
				(B.ToDate IS NULL OR @Today <= B.ToDate))
		ORDER BY
				B.CreateDateTime DESC
	)
	SELECT
			B.*
	FROM
			Board B
	WHERE
			B.No >= ((@PageNo - 1) * @PageSize) + 1
END



GO

