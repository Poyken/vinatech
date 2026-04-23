-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-04-25
-- Browsable : true
-- Group : 생산관리
-- Description:	생산자주검사 결과 조회
-- =============================================
CREATE PROC usp_SelfInspectionInfoForChartD1
	@pProcessLanguage VARCHAR(20),
	@pProcessUserID VARCHAR(20),
	@pFromDt DateTime,
	@pToDt DateTime
AS
BEGIN 
	Declare @FromDt VARCHAR(10) = CONVERT(VARCHAR(10), @pFromDt, 121)
	       ,@ToDt VARCHAR(10) = CONVERT(VARCHAR(10), @pToDt, 121)

	 exec ERPSVR.VINATech.dbo.usp_SelfInspectionInfoForChart @FromDt, @ToDt, 'D1'
END
