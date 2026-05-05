-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-04-12
-- Browsable : true
-- Group : 생산관리 > 목표입력
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_Cell_Line_Plan_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pUtcOffset INT,
	@pToMonth VARCHAR(08)
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID     VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage    			
	--DECLARE @ToDay      VARCHAR(02) = SUBSTRING(CONVERT(VARCHAR(10), GetDate(), 121), 9, 2)                                                                        -- 전일자 두자리           SELECT  SUBSTRING(CONVERT(VARCHAR(10), GetDate()-1, 121), 9, 2)	
	DECLARE @ToMonth   VARCHAR(10) = REPLACE(SUBSTRING(CONVERT(VARCHAR(10), @pToMonth, 121), 1, 7), '-', '')                                                     -- 금일 6자리           SELECT  REPLACE(SUBSTRING(CONVERT(VARCHAR(12), '2019-05-12 08:30:00', 121), 1, 7), '-', '')     --> '201904'

--  EXEC  usp_Cell_Line_Plan_get  '', '', '2019-04-12 08:30:00'
--  EXEC  usp_Cell_Line_Plan_get  '', '', '2019-05-01 08:30:00'

SELECT 
	       dbo.fnGetLocalTime(CONVERT(DATE, CP.기준년월+'01', 112), @pUtcOffset) AS 기준년월
		,  CP.라인코드 AS LineCode
		,  CP.라인명  AS LineName
		,  CP.사이즈 
		,  CP.규격       
		,  CP.월간계획
		,  CP.특이사항		 
		,  CP.MaterialCode
		,  MM.MaterialName
		, Idx
FROM CURLING_PLAN CP
LEFT OUTER JOIN STB_MaterialMaster MM
  ON MM.MaterialCode = CP.MaterialCode
WHERE 1=1
    --AND 기준년월 = @ToMonth 
    AND 기준년월 LIKE '%' + @ToMonth + '%'

 -- AND 기준년월 = '201905'

END