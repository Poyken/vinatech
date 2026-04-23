-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-02-06
-- Browsable : true
-- Group : 생산관리
-- Description:	슬리터 칼날 교체이력 조회
-- Modified:
-- =============================================
CREATE PROCEDURE usp_ElectrodeSlittingCutterUsageHist_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pMachineCode VARCHAR(20) = NULL,
	@pFromDate DATE,
	@pToDate DATE

AS
BEGIN
	Declare @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode, '') = '' THEN '*' ELSE @pMachineCode END
		   ,@FromDate DATETIME = @pFromDate
		   ,@ToDate DATETIME = @pToDate

	SELECT ESCUH.ElectrodeSlittingCutterUsageHistNo
          ,ESCUH.BaseDate
          ,ESCUH.MachineCode
		  ,MM.MachineName
          ,ESCUH.ShiftCode
		  ,SC.[Shift] AS ShiftName
          ,ESCUH.UseQty
          ,ESCUH.CumulativeQty
          ,ESCUH.Remark
          ,ESCUH.IsExchange
          ,ESCUH.CreateDateTime
          ,ESCUH.CreateUserID
          ,ESCUH.ChangeDateTime
          ,ESCUH.ChangeUserID
	  FROM STB_ElectrodeSlittingCutterUsageHist ESCUH
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON MM.MachineCode = ESCUH.MachineCode
	  LEFT OUTER JOIN VW_ShiftCode SC
	    ON SC.ShiftCode = ESCUH.ShiftCode
	 WHERE ESCUH.BaseDate BETWEEN @FromDate AND @ToDate
	   AND (@MachineCode = '*' OR ESCUH.MachineCode = @MachineCode)
	 ORDER BY ESCUH.ElectrodeSlittingCutterUsageHistNo
END
