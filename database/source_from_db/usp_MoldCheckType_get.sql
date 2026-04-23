

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형점검유형정보 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldCheckType_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMoldCheckTypeName NVARCHAR(50) = NULL

AS
BEGIN
	SET NOCOUNT ON;
      DECLARE @MoldCheckTypeName NVARCHAR(50) = CASE WHEN ISNULL(@pMoldCheckTypeName,'') = '' THEN '*' ELSE @pMoldCheckTypeName END

    
	SELECT
	        MCT.MoldCheckTypeCode AS OldMoldCheckTypeCode,
	        MCT.MoldCheckTypeCode,
	        MCT.MoldCheckTypeName,
	        MCT.MoldCheckTypeDesc,
	        MCT.CreateDateTime,
	        MCT.CreateUserID,
	        MCT.ChangeDateTime,
	        MCT.ChangeUserID
	FROM
	        STB_MoldCheckType MCT WITH(NOLOCK)
	WHERE
	        ((@MoldCheckTypeName = '*') OR (MCT.MoldCheckTypeName = @MoldCheckTypeName)) 

END




