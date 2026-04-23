-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 자재관리
-- Browsable : true
-- Create date : 2019-11-12
-- Description : 
-- Modified :
-- =============================================
CREATE PROCEDURE usp_SalesMonthlyPlan_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromMonth DATETIME,
	@pToMonth DATETIME,
	@pProductClassCode VARCHAR(10) = NULL
AS
BEGIN
	Declare @FromMonth VARCHAR(7) = CONVERT(VARCHAR(7), @pFromMonth, 121)
	       ,@ToMonth VARCHAR(7) = CONVERT(VARCHAR(7), @pToMonth, 121)
		   
	SELECT SalesIndex
		  ,Region
		  ,SizeW
		  ,SizeH
		  ,Volt
		  ,Farad
		  ,BaseMonth
		  ,PlanQty
	  FROM STB_SalesMonthlyPlan
	 WHERE BaseMonth BETWEEN @FromMonth AND @ToMonth
	 ORDER BY BaseMonth
END