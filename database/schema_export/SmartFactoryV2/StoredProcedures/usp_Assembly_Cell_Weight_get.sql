-- Procedure: usp_Assembly_Cell_Weight_get
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-01-28
-- Browsable : true
-- Group : 생산관리
-- Description:	라인별 ESR 스펙오버 체크 현황
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_Assembly_Cell_Weight_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE
AS


BEGIN
	Declare  @FromDate DATE = @pFromDate
	         , @ToDate DATE = @pToDate

	SELECT *
	  FROM STB_AssemblyCellWeightInfo SCW
	 WHERE SCW.CreateDateTime BETWEEN @FromDate AND @ToDate
     ORDER BY CreateDateTime

END
GO

