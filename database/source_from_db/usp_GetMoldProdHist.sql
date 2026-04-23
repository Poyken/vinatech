

-- =============================================
-- Author:		Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 생산관리
-- Description:	일계획일련번호 변경가능한 생산금형실적화면
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldProdHist]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL,
	@pFromDate DATE = NULL,
	@pToDate DATE = NULL,	
	@pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	
	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '%' ELSE @pMachineCode END
	DECLARE @FromDate DATE = @pFromDate
    DECLARE @ToDate DATE = @pToDate
	
	
	SELECT
			MPH.JobDate AS YearMonth,
			MPH.MoldProdNo AS OldMoldProdNo,
			MPH.MoldProdNo,
			MPH.CompanyCode,
			CI.CompanyName,
			MPH.WorkCenterCode,
			WCI.WorkCenterName,
			MPH.JobDate,
			MPH.ShiftCode,
			--MPH.ActStartDateTime,
			MPH.StartDateTime AS ActStartDateTime,
			MPH.ActEndDateTime,
			MPH.DayPlanNo,
			MPH.MachineCode,
			PM.MachineName,
			PM.DisplayIndex,
			PM.InjectType,
			PM.Capa,
			PM.MachineDesc1,
			PM.MonitoringGroup,
			PM.ErpMachineCode,
			PM.MachineDesc2,
			PM.MachineDesc3,
			PM.MachineDesc4,
			PM.MachineDesc5,
			PM.IsTemperatureControl,
			PM.IsCommunication,
			PM.RunMode,
			PM.IsMachineAlarm,
			PM.IsMoldTempControl,
			PM.MoldTemp1,
			PM.MoldTemp2,
			PM.MoldTemp3,
			PM.MoldTemp4,
			PM.MoldTemp5,
			PM.MoldTemp6,
			PM.IsMoldTempAlarm1,
			PM.IsMoldTempAlarm2,
			PM.IsMoldTempAlarm3,
			PM.IsMoldTempAlarm4,
			PM.IsMoldTempAlarm5,
			PM.IsMoldTempAlarm6,
			PM.MoldTemperatureSet1,
			PM.MoldTemperatureSet2,
			PM.MoldTemperatureSet3,
			PM.MoldTemperatureSet4,
			PM.MoldTemperatureSet5,
			PM.MoldTemperatureSet6,
			MPH.MoldNumber,
			MBI.MoldTypeCode,
			MTI.MoldTypeName,
			MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
			MBI.MoldCategory4,
			MBI.RawMaterial,
			MBI.MakeDate,
			MBI.MakeVendor,
			MBI.CurrentPosition,
			MBI.MoldGrade,
			MBI.GuaranteeQty,
			MBI.AccumulateQty,
			MBI.CurrentQty,
			MBI.AlarmStatus,
			MBI.MBIExtText01,
			MBI.MBIExtText02,
			MBI.MBIExtText03,
			MBI.MBIExtText04,
			MBI.MBIExtText05,
			MBI.MBIExtImage01,
			MBI.MBIExtImage02,
			MBI.MBIExtImage03,
			MBI.MBIExtImage04,
			MBI.MBIExtImage05,
			MBI.MoldLocationCode,
			MBI.RFTagID,
			MBI.CheckTerm1,
			MBI.CheckTerm2,
			MBI.CheckTerm3,
			MBI.MoldGradeTypeCode,
			MBI.CheckSheetType1,
			MBI.CheckSheetType2,
			MBI.CheckSheetType3,
			MBI.CheckSheetType4,
			MPH.ShotQty,
			MPH.WorkerCode,
			WI.WorkerName,
			--MPH.StartupLossQty,
			0 AS StartupLossQty,
			0 AS StartupLossWeight,
			--MPH.StartupLossWeight,
			MPH.PurgingWeight
	FROM
			STB_MoldProdHist MPH
			LEFT OUTER JOIN STB_MoldProductMachine PM
				ON MPH.MachineCode = PM.MachineCode
			LEFT OUTER JOIN STB_WorkCenterInfo WCI
				ON (MPH.WorkCenterCode = WCI.WorkCenterCode)	
			LEFT OUTER JOIN STB_CompanyInfo CI
				ON (MPH.CompanyCode = CI.CompanyCode)
			LEFT OUTER JOIN STB_ProdWorkerInfo WI
				ON MPH.WorkerCode = WI.WorkerCode
			LEFT OUTER JOIN STB_MoldBasicInfo MBI 
				ON MPH.MoldNumber = MBI.MoldNumber
			LEFT OUTER JOIN STB_MoldTypeInfo MTI WITH(NOLOCK)
				ON MBI.MoldTypeCode = MTI.MoldTypeCode
	WHERE
			MPH.CompanyCode LIKE @CompanyCode AND
			MPH.WorkCenterCode LIKE @WorkCenterCode AND
			MPH.MachineCode LIKE @MachineCode AND
			(MPH.JobDate >= @pFromDate AND MPH.JobDate <= @pToDate)
END
