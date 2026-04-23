
-- ===========================================================================================================
-- Author: Kangs
-- Create date: 2020-04-06
-- Browsable : true
-- Group : 베트남 Power-BI용
-- Description: 
-- Modified: 
-- 프로시저실행 (2021-03-12)  :   usp_TestDateTime_get
-- ===========================================================================================================

CREATE PROCEDURE [dbo].[usp_TestDateTime_get]
						   --@pDateTime DATETIME,
	        --              @pUtcOffset INT
AS

BEGIN

         SELECT dbo.fnGetLocalTime(GETDATE(), -210)
		Union all

     	SELECT dbo.fnGetLocalTime(GETDATE(), 420)
		Union all

		SELECT dbo.fnGetLocalTime(GETDATE(), 540)
		Union all

		SELECT dbo.fnGetLocalTime(GETDATE(), 660)
		Union all

		SELECT dbo.fnGetLocalTime(GETDATE(), 1050)




END