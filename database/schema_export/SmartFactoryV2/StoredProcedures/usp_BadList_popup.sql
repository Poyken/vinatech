-- Procedure: usp_BadList_popup

-- =============================================
-- Author:	kilee
-- Create date: 2020-01-03
-- Browsable : true
-- Group :
-- Description:	불량리스트 popup 조회용
-- EXEC [usp_BadList_popup]
-- =============================================
CREATE PROCEDURE [dbo].[usp_BadList_popup] 

WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	
	SELECT  ItemCode	
	        ,  Description  as ItemName	
	FROM SmartFramework.DBO.STB_BaseCode  				
	WHERE 1=1
	   AND CodeGroup = 'BAD_KIND'
	

END


GO

