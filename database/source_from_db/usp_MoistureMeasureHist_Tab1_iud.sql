-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-07-01
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_MoistureMeasureHist_Tab1_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	CREATE TABLE #PRIMARYKEY_TEMP (MoistureMeasureHistNo VARCHAR(20))

	exec usp_MoistureMeasureHist_iud @pProcessUserID, @pProcessLanguage, @pProcessViewName, @pXml

	exec usp_ElectrolyteMoistureMeasureHist_iud @pProcessUserID, @pProcessLanguage, @pProcessViewName, @pXml

	DROP TABLE #PRIMARYKEY_TEMP
END