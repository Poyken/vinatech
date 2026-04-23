-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 거래선지역 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_SalesArea_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			BC.ItemCode AS SalesArea
	FROM
			SmartFramework.dbo.STB_BaseCode BC WITH(NOLOCK)
	WHERE
			BC.CodeGroup = 'SalesArea'
END
