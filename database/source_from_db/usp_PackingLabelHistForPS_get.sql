-- ED-VJPMTR000000013
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024.11.21
-- Browsable : true
-- Group : PS부문
-- Description:	수기라벨출력이력을 조회합니다.
-- Modified:
-- =============================================
CREATE PROC usp_PackingLabelHistForPS_get
    @pProcessLanguage VARCHAR(20)
   ,@pProcessUserID VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'

	SELECT PLHPS.PackingLabelHistNo
          ,PLHPS.LotNo
          ,PLHPS.Voltage
          ,PLHPS.Farad
          ,PLHPS.Rating
          ,PLHPS.PartNo
          ,PLHPS.LotQty
          ,PLHPS.LabelQty
          ,PLHPS.CreateDateTime
          ,PLHPS.CreateUserID
          ,PLHPS.ChangeDateTime
          ,PLHPS.ChangeUserID
		  ,'Report' AS CommandType
	  FROM STB_PackingLabelHistForPS PLHPS
	 WHERE PLHPS.CreateDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY PLHPS.PackingLabelHistNo
END
