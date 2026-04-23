-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-02-01
-- Browsable : true
-- Group : 모듈관리
-- Description:	거래처별 모듈 생산정보
-- =============================================
CREATE PROCEDURE usp_ModuleProductionHist_get
					@pProcessUserID VARCHAR(20),
					@pProcessLanguage VARCHAR(20),
					@pMPHExtText01 VARCHAR(MAX),
					@pFromDate DATE,
					@pToDate DATE
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'
		   ,@MPHExtText01 VARCHAR(MAX) = CASE WHEN ISNULL(@pMPHExtText01, '') = '' THEN '*' ELSE @pMPHExtText01 END

	SELECT MPH.ModuleProductionHistNo
		  ,MPH.MPHExtText01
		  ,MPH.MPHExtText02
		  ,MPH.MPHExtText03
		  ,MPH.MPHExtText04
		  ,MPH.MPHExtText05
		  ,MPH.MPHExtText06
		  ,MPH.MPHExtText07
		  ,MPH.MPHExtText08
		  ,MPH.MPHExtText09
		  ,MPH.MPHExtText10
		  ,MPH.MPHExtInt01
		  ,MPH.MPHExtInt02
		  ,MPH.MPHExtInt03
		  ,MPH.MPHExtInt04
		  ,MPH.MPHExtInt05
		  ,MPH.MPHExtInt06
		  ,MPH.MPHExtInt07
		  ,MPH.MPHExtInt08
		  ,MPH.MPHExtInt09
		  ,MPH.MPHExtInt10
		  ,MPH.MPHExtReal01
		  ,MPH.MPHExtReal02
		  ,MPH.MPHExtReal03
		  ,MPH.MPHExtReal04
		  ,MPH.MPHExtReal05
		  ,MPH.MPHExtReal06
		  ,MPH.MPHExtReal07
		  ,MPH.MPHExtReal08
		  ,MPH.MPHExtReal09
		  ,MPH.MPHExtReal10
		  ,MPH.MPHExtDate01
		  ,MPH.MPHExtDate02
		  ,MPH.MPHExtDate03
		  ,MPH.MPHExtDate04
		  ,MPH.MPHExtDate05
		  ,MPH.MPHExtDate06
		  ,MPH.MPHExtDate07
		  ,MPH.MPHExtDate08
		  ,MPH.MPHExtDate09
		  ,MPH.MPHExtDate10
		  ,MPH.CreateDateTime
		  ,MPH.CreateUserID
		  ,MPH.ChangeDateTime
		  ,MPH.ChangeUserID
		  ,CI.CustomerName
	  FROM STB_ModuleProductionHist MPH
	  LEFT OUTER JOIN STB_CustomerInfo CI
	    ON CI.CustomerCode = MPH.MPHExtText01
	 WHERE MPHExtDate01 BETWEEN @FromDate AND @ToDate
	   AND (@MPHExtText01 = '*' OR MPH.MPHExtText01 = @MPHExtText01)
END