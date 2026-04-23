-- =============================================
-- Author : Kim Han Young(hykim@awoo.co.kr)
-- Group : 영업관리
-- Browsable : true
-- Create date : 2018-07-24
-- Description : 영업오더유형 팝업
-- Modified :
-- =============================================
CREATE PROCEDURE [dbo].[usp_SalesOrderType_popup]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID,
			@ProcessLanguage VARCHAR(20) = @pProcessLanguage

	SELECT
			OrderTypeCode,
			OrderTypeName
	FROM
			VW_SalesOrderType
END
