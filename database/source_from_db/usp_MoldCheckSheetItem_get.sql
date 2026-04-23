-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형체크시트항목기준 조회
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldCheckSheetItem_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pMoldCheckSheetCode VARCHAR(20) = NULL
    
AS
BEGIN
	SET NOCOUNT ON;
    --DECLARE @MoldCheckSheetCode VARCHAR(20) = CASE WHEN ISNULL(@pMoldCheckSheetCode,'') = '' THEN '*' ELSE @pMoldCheckSheetCode END
	DECLARE @MoldCheckSheetCode VARCHAR(20) = CASE WHEN ISNULL(@pMoldCheckSheetCode,'') = '' THEN '' ELSE @pMoldCheckSheetCode END
    
	SELECT
	        MCSI.MoldCheckSheetCode AS OldMoldCheckSheetCode,
	        MCSI.ItemNo AS OldItemNo,
	        MCSI.MoldCheckSheetCode,
	        MCSM.MoldCheckSheetName,
	        MCSM.MoldCheckTypeCode,
	        MCT.MoldCheckTypeName,
	        MCT.MoldCheckTypeDesc,
	        MCSM.MoldImage,
	        MCSI.ItemNo,
	        MCSI.DisplayIndex,
	        MCSI.CheckPointNo,
	        MCSI.CheckPointText,
	        MCSI.CheckSubNo,
	        MCSI.CheckItem,
	        MCSI.CheckText,
	        MCSI.CheckDesc,
	        MCSI.CreateDateTime,
	        MCSI.CreateUserID,
	        MCSI.ChangeDateTime,
	        MCSI.ChangeUserID
	FROM
	        STB_MoldCheckSheetItem MCSI WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MoldCheckSheetMaster MCSM WITH(NOLOCK)
				ON MCSI.MoldCheckSheetCode = MCSM.MoldCheckSheetCode
			LEFT OUTER JOIN STB_MoldCheckType MCT WITH(NOLOCK)
				ON MCSM.MoldCheckTypeCode = MCT.MoldCheckTypeCode
			
	WHERE
	        ((@MoldCheckSheetCode = '*') OR (MCSI.MoldCheckSheetCode = @MoldCheckSheetCode)) 
	        

END



