-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형등급타입 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldGradeType_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMoldGradeTypeName NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MoldGradeTypeName NVARCHAR(50) = CASE WHEN ISNULL(@pMoldGradeTypeName,'') = '' THEN '*' ELSE @pMoldGradeTypeName END

    
	SELECT
	        MGT.MoldGradeTypeCode AS OldMoldGradeTypeCode,
	        MGT.MoldGradeTypeCode,
	        MGT.MoldGradeTypeName,
	        MGT.Level1Qty,
	        MGT.Level2Qty,
	        MGT.Level3Qty,
	        MGT.CreateDateTime,
	        MGT.CreateUserID,
	        MGT.ChangeDateTime,
	        MGT.ChangeUserID
	FROM
	        STB_MoldGradeType MGT WITH(NOLOCK)
	WHERE
	        ((@MoldGradeTypeName = '*') OR (MGT.MoldGradeTypeName = @MoldGradeTypeName)) 

END
