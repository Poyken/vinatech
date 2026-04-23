-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-03-31
-- Browsable : true
-- Group : 품질관리
-- Description:	수입검사그룹을 조회합니다
-- Modified:
-- =============================================
CREATE  PROCEDURE [dbo].[usp_ShortingValue_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pLotNo nvarchar(50) = null


AS
BEGIN
	SET NOCOUNT ON;
     select lotno, value2 as OCV, value8 as DischargeCapacity , createdatetime 
	 from Stb_ShortingInfor
	 where (@pLotNo IS NULL or @pLotNo='' or lotno like '%'+@pLotNo+'%')
END
