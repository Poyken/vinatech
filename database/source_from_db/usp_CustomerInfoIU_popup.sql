-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2018-07-23
-- Description : 거래처 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE usp_CustomerInfoIU_popup
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT CD_PARTNER AS CustomerCode
	      ,LN_PARTNER AS CustomerName
	  FROM NEOE.NEOE.MA_PARTNER
	 WHERE USE_YN = 'Y'
	   AND CD_COMPANY = '1000'
END