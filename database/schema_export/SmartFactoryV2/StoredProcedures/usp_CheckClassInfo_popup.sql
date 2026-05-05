-- Procedure: usp_CheckClassInfo_popup
-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2019-07-29
-- Description : 일상점검분류 popup
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckClassInfo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT CheckClassNo
	      ,CheckClassName
		  ,Remark AS CheckClassNameVVT
	  FROM STB_CheckClassInfo
	 WHERE IsUsed = 1
	 ORDER BY CheckClassNo
END

GO

