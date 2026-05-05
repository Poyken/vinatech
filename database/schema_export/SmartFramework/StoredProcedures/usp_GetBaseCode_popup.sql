-- Procedure: usp_GetBaseCode_popup





-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-07-23
-- Browsable : true
-- Group : 시스템관리
-- Description:	기본코드관리 조회_POPUP
-- Modified:

-- exec usp_GetBaseCode_popup '','',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetBaseCode_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCodeGroup VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @CodeGroup VARCHAR(50) = CASE WHEN ISNULL(@pCodeGroup,'') = '' THEN '*' ELSE @pCodeGroup END
      ,@WorkCenterCode varchar(20) 
    select @WorkCenterCode=WorkCenterCode from [SmartFactoryV2].[dbo].[STB_UserInfo] where UserID =@pProcessUserID
	if(@WorkCenterCode='VVT_F3' and @pCodeGroup='OccurProcessCode') -- nếu là tk ở hà nam sẽ lấy các công đoạn ở hà nam
		set @CodeGroup='OccurProcessCode_HN'
	SELECT
			IsNull(BC.ItemCode,'') AS [ItemCode],
			IsNull(BC.Description,'') AS [Description]
			
	FROM
			STB_BaseCode BC WITH(NOLOCK)
	WHERE 	
			( @CodeGroup = '*') OR (BC.CodeGroup = @CodeGroup)
    ORDER BY BC.DisplayIndex

END





--select * from STB_BaseCode where CodeGroup = 'ITWorkerCode'


--insert into STB_BaseCode values ( 'ITWorkerCode', '19080501', 'Mr.Tung', '','')


GO

