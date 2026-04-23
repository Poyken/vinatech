-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 전극혼합단계코드 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeStep_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			BC.ItemCode AS ElectrodeStepCode
		   ,BC.Description AS ElectrodeStepName
	FROM
			SmartFramework.dbo.STB_BaseCode BC WITH(NOLOCK)
	WHERE
			BC.CodeGroup = 'ElectrodeStep'
    ORDER BY CASE WHEN BC.ItemCode = 'D' THEN 1
		          WHEN BC.ItemCode = 'G' THEN 2
			      WHEN BC.ItemCode = 'K' THEN 3
			      WHEN BC.ItemCode = 'P' THEN 4
			      WHEN BC.ItemCode = 'S' THEN 5
				  WHEN BC.ItemCode = 'S1' THEN 6
				  WHEN BC.ItemCode = 'S2' THEN 7
				  WHEN BC.ItemCode = 'S3' THEN 8
				  WHEN BC.ItemCode = 'S4' THEN 9
				  WHEN BC.ItemCode = 'S5' THEN 10
			      WHEN BC.ItemCode = 'DA' THEN 11
			      ELSE 100 END 
END
