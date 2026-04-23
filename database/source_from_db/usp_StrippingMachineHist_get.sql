-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-07-24
-- Browsable : true
-- Group : 생산관리
-- Description:	스트리핑 이력을 등록합니다.
-- Modified:
-- =============================================
CREATE PROCEDURE usp_StrippingMachineHist_get
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20),
	@pWorkCenterCode VARCHAR(20),
	@pElectrodeSlittingLotNumber VARCHAR(20),
	@pMachineCode VARCHAR(20)
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), GETDATE(), 121) + ' 08:30:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), DATEADD(day, 1, GETDATE()), 121) + ' 08:30:00'
		   ,@StrippingMachineHistNo VARCHAR(20)

	EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_StrippingMachineHist', @StrippingMachineHistNo OUTPUT

	INSERT INTO STB_StrippingMachineHist 
	(
		StrippingMachineHistNo
	   ,CompanyCode
	   ,WorkCenterCode
	   ,ElectrodeSlittingLotNumber
	   ,MachineCode
	   ,CreateUserID
	) VALUES (
		@StrippingMachineHistNo
	   ,@pCompanyCode
	   ,@pWorkCenterCode
	   ,@pElectrodeSlittingLotNumber
	   ,@pMachineCode
	   ,@pProcessUserID
	)

	SELECT SMH.StrippingMachineHistNo
		  ,SMH.CompanyCode
		  ,CI.CompanyName
		  ,SMH.WorkCenterCode
		  ,WCI.WorkCenterName
		  ,SMH.ElectrodeSlittingLotNumber
		  ,SMH.MachineCode
		  ,MM.MachineName
		  ,SMH.CreateDateTime
		  ,SMH.CreateUserID
		  ,SMH.ChangeDateTime
		  ,SMH.ChangeUserID
	  FROM STB_StrippingMachineHist SMH
	  LEFT OUTER JOIN STB_CompanyInfo CI
		ON SMH.CompanyCode = CI.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WCI
		ON SMH.WorkCenterCode = WCI.WorkCenterCode
	  LEFT OUTER JOIN STB_MachineMaster MM
		ON SMH.MachineCode = MM.MachineCode
	 WHERE SMH.CreateDateTime BETWEEN @FromDate AND @ToDate
	 ORDER BY SMH.CreateDateTime ASC
END
