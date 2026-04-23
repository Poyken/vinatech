-- =============================================
-- Author : Jackaroe(yjyu@vina.co.kr)
-- Group : 모듈관리
-- Browsable : true
-- Create date : 2026-04-18
-- Description : 
-- =============================================
CREATE PROCEDURE usp_ESDAreaWorkerInOutHist_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE,
	@pESDAreaCode VARCHAR(20) = NULL,
	@pWorkerCode VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(VARCHAR(10), @pFromDate, 121) + ' 00:00:00'
	Declare @ToDate DATETIME = CONVERT(VARCHAR(10), @pToDate, 121) + ' 23:59:59'

	SELECT EWIH.ESDAreaCode
	      ,BC.Description AS ESDAreaName
		  ,EWIH.InOutCode
		  ,EWIH.WorkerCode
		  ,PWI.WorkerName
		  ,EWIH.CreateDateTime
	FROM STB_ESDAreaWorkerInOutHist EWIH
	LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	  ON BC.CodeGroup = 'ESDAreaCode'
	 AND BC.ItemCode = EWIH.ESDAreaCode
	LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	  ON PWI.WorkerCode = EWIH.WorkerCode
	WHERE EWIH.CreateDateTime BETWEEN @FromDate AND @ToDate
	ORDER BY EWIH.CreateDateTime ASC
END
