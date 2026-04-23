-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-25
-- Browsable : true
-- Group : 공통
-- Description:	Dummy
-- Modified: 
-- =============================================

CREATE PROCEDURE [dbo].[usp_DataDummy_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT 'Report' AS dummy
END