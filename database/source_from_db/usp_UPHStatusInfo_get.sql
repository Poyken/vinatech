-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2025-06-18
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROC usp_UPHStatusInfo_get
	@pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pUtcOffset INT
   ,@pFromDate DATE
   ,@pToDate DATE
   ,@pLineCode VARCHAR(20) = NULL
   ,@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
		   ,@ToDate DATE = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@LineCode VARCHAR(20) = CASE WHEN ISNULL(@pLineCode, '') = '' THEN '*' ELSE @pLineCode END
		   ,@MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode, '') = '' THEN '*' ELSE @pMachineCode END

	SELECT dbo.fnGetLocalTime(UTSI.BaseDate, @pUtcOffset) AS BaseDate
		  ,UTSI.MachineCode
		  ,MM.MachineName
		  ,UTSI.LineCode
		  ,LI.LineName
		  ,MAX(UTSI.DayWorkTime) AS DayWorkTime
		  ,SUM(UTSI.RequiredTime) AS RequiredTime
		  ,MAX(UTSI.DayWorkTime) -  SUM(UTSI.RequiredTime) AS ActualDayWorkTime
		  ,CONVERT(NUMERIC(20,5), MAX(PRH.ProdQty)) / (CONVERT(NUMERIC(20,5), (MAX(UTSI.DayWorkTime) -  SUM(UTSI.RequiredTime)) / 60.0)) AS UPH
	  FROM STB_UPHTimeSetupInfo UTSI
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC1
	    ON BC1.CodeGroup  = 'UPHItemCode'
	   AND BC1.ItemCode = UTSI.UPHItemCode
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON MM.MachineCode = UTSI.MachineCode
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON LI.LineCode = UTSI.LineCode
	  LEFT OUTER JOIN (
						SELECT CONVERT(VARCHAR(10), PRH.ProdDateTime, 121) AS ProdDate
						      ,PRH.MachineCode
						      ,SUM(ProdQty) AS ProdQty
						  FROM STB_ProdRouteHist PRH
						 WHERE ProdDateTime BETWEEN @FromDate AND @ToDate
						 GROUP BY CONVERT(VARCHAR(10), PRH.ProdDateTime, 121)
						         ,PRH.MachineCode
					) PRH
	            ON PRH.ProdDate = UTSI.BaseDate
			   AND PRH.MachineCode = UTSI.MachineCode
	 WHERE UTSI.BaseDate BETWEEN @FromDate AND @ToDate
	   AND (@LineCode = '*' OR UTSI.LineCode = @LineCode)
	   AND (@MachineCode = '*' OR UTSI.MachineCode = @MachineCode)
	 GROUP BY dbo.fnGetLocalTime(UTSI.BaseDate, @pUtcOffset)
	         ,UTSI.MachineCode
			 ,MM.MachineName
			 ,UTSI.LineCode
			 ,LI.LineName
END