-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-23
-- Description : 거래처 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerInfo_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			CI.CustomerCode,
			CI.CustomerName,
			CI.CIExtText01,
			CI.CIExtText02
	FROM
			STB_CustomerInfo CI WITH(NOLOCK)
	WHERE
			CI.IsUsed = 1
END
