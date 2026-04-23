
-- =============================================
-- Author:	   kilee
-- Create date: 2019-04-16
-- Browsable : true
-- Group : 생산관리 > 실적등록 > 베트남불량실적입력
-- Description:	
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_VNM_BadQty_get]
	@pProcessUserID     VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pToDay                datetime
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID      VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage  VARCHAR(20) = @pProcessLanguage    			
	--DECLARE @ToDay             VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 9, 2)                                                                        -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)	
	DECLARE @ToDay           VARCHAR(20) =SUBSTRING(CONVERT(VARCHAR(20), @pToDay, 121), 1, 20)                 -- 금일 6자리           SELECT  SUBSTRING(CONVERT(VARCHAR(20), '2019-04-17 08:30:00', 121), 1, 20)     --> '201904'

--  EXEC  usp_Cell_Line_Plan_get  '', '', '2019-04-12 08:30:00'


--SELECT *	       
--FROM STB_ProdRouteSummary_VNM 
--WHERE 1=1
--    AND JOBDATE  BETWEEN '2019-04-16 08:30:00' AND '2019-04-17 08:30:00'
-- -- AND JOBDATE  BETWEEN @ToMonth AND @ToMonth


SELECT * 
FROM 조립불량실적_VNM
WHERE 1=1
AND 입력일시  BETWEEN '2019-04-17 08:30:00' AND '2019-04-18 08:30:00'
--AND 입력일시  BETWEEN '2019-04-17 08:30:00' AND @ToMonth


END



--SELECT *	       
--FROM STB_ProdRouteSummary