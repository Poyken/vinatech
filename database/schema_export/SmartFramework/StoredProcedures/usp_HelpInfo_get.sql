-- Procedure: usp_HelpInfo_get







-- =============================================
-- Author:		Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-07-21
-- Description:	도움말 리스트를 조회합니다.
-- =============================================
CREATE PROCEDURE [dbo].[usp_HelpInfo_get]
	
AS
BEGIN
	SET NOCOUNT ON;

    SELECT
			H.*
	FROM
			STB_Help H WITH(NOLOCK)
END








GO

