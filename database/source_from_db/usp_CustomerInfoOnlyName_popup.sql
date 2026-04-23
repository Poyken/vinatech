-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 공통
-- Browsable : true
-- Create date : 2022-09-06
-- Description : 거래처 팝업(이름)
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_CustomerInfoOnlyName_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT LN_PARTNER AS CustomerName
	  FROM NEOE.NEOE.MA_PARTNER
	 WHERE USE_YN = 'Y'
	   AND CD_COMPANY = '1000'
	 GROUP BY LN_PARTNER
	 ORDER BY LN_PARTNER
END
