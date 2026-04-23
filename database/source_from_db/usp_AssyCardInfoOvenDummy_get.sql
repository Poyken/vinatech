-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019.02.11
-- Browsable : true
-- Group : 생산관리
-- Description:	건조오븐 기준정보 출력
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_AssyCardInfoOvenDummy_get]
	@pProcessUserID [varchar](20),
	@pProcessLanguage [varchar](20)
AS
BEGIN
	;WITH OvenList AS (
		SELECT '' AS OvenCode, '' AS Barcode
		UNION ALL
		SELECT '', ''
		UNION ALL
		SELECT '', ''
	)
	SELECT *
	      ,'Report' AS CommandType
	  FROM OvenList
END