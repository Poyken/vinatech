-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형이동 구분 설정 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldMoveType_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMoldMoveTypeName NVARCHAR(100) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MoldMoveTypeName NVARCHAR(100) = CASE WHEN ISNULL(@pMoldMoveTypeName,'') = '' THEN '*' ELSE @pMoldMoveTypeName END

    
	SELECT
	        MMT.MoldMoveTypeCode AS OldMoldMoveTypeCode,
	        MMT.MoldMoveTypeCode,
	        MMT.MoldMoveTypeName,
	        MMT.IsGR,
	        MMT.IsCheckWhenGR,
	        MMT.IsGI,
	        MMT.IsMove,
	        MMT.CreateDateTime,
	        MMT.CreateUserID,
	        MMT.ChangeDateTime,
	        MMT.ChangeUserID
	FROM
	        STB_MoldMoveType MMT WITH(NOLOCK)
	WHERE
	        ((@MoldMoveTypeName = '*') OR (MMT.MoldMoveTypeName = @MoldMoveTypeName)) 

END





