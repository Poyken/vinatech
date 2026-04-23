-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019.02.11
-- Browsable : true
-- Group : 생산관리
-- Description:	Lot 생산현황 조회(건조오븐)
-- Modified:
-- =============================================
-- EXEC usp_AssyCardInfoOven_get '', '', ''
-- EXEC usp_AssyCardInfoOven_get '', '', 'VJJO193R033501'

CREATE PROCEDURE [dbo].[usp_AssyCardInfoOven_get]
						@pProcessUserID [varchar](20),
						@pProcessLanguage [varchar](20),
						@pBarcode [varchar](20) = NULL
WITH EXECUTE AS CALLER
AS

BEGIN

	SET NOCOUNT ON;
	
	Declare @Barcode VARCHAR(20) = @pBarcode

	--라인 건조오븐 현황정보
	SELECT SI.SIExtText06 AS OvenCode
	      ,SI.SIExtText02 AS OvenInputDateTime
		  ,SI.SIExtText03 AS OvenOutputDateTime
		  ,SI.BarCode AS Barcode
	  FROM STB_SetInfo SI
	 WHERE InputLineCode = (  SELECT InputLineCode 
										  FROM STB_SetInfo 
										 WHERE Barcode = @Barcode
									   )
	   AND RTRIM(ISNULL(SI.SIExtText02, '')) <> ''
	   AND RTRIM(ISNULL(SI.SIExtText03, '')) = ''
	 ORDER BY OvenInputDateTime

END


--  SELECT SIExtText02, SIExtText03, * FROM STB_SetInfo  ORDER BY CreateDateTime Desc


	--SELECT SI.SIExtText06 AS OvenCode
	--      ,SI.SIExtText02 AS OvenInputDateTime
	--	  ,SI.SIExtText03 AS OvenOutputDateTime
	--  FROM STB_SetInfo SI
	-- WHERE InputLineCode = (  SELECT InputLineCode 
	--									  FROM STB_SetInfo 
	--									 WHERE Barcode = 'VJJO193R033501'
	--								   )