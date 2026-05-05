-- Procedure: usp_CheckPartInfo_popup
-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2019-07-29
-- Description : 일상점검파트 popup
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckPartInfo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT CheckPartNo
	      ,CheckPartName
		  ,Remark AS CheckPartNameVVT
	  FROM STB_CheckPartInfo
	 WHERE IsUsed = 1
	 ORDER BY CheckPartNo
END

GO

