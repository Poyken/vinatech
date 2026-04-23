-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-01
-- Browsable : true
-- Group : 금형관리
-- Description:	금형타입정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldTypeInfo_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMoldTypeName NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MoldTypeName NVARCHAR(50) = CASE WHEN ISNULL(@pMoldTypeName,'') = '' THEN '*' ELSE @pMoldTypeName END

    
	SELECT
	        MTI.MoldTypeCode AS OldMoldTypeCode,
	        MTI.MoldTypeCode,
	        MTI.MoldTypeName,
	        MTI.MoldTypeDesc,
	        MTI.CreateDateTime,
	        MTI.CreateUserID,
	        MTI.ChangeDateTime,
	        MTI.ChangeUserID
	FROM
	        STB_MoldTypeInfo MTI WITH(NOLOCK)
	WHERE
	        ((@MoldTypeName = '*') OR (MTI.MoldTypeName = @MoldTypeName)) 

END


