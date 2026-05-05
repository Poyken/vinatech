


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-29
-- Browsable : true
-- Group : 금형관리
-- Description:	현재설비금형온도
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldProductMachineCurrentTemp]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pCompanyCode VARCHAR(20) = NULL,
	@pWorkCenterCode VARCHAR(20) = NULL 
WITH RECOMPILE
AS
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '*' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '*' ELSE @pWorkCenterCode END
		
	SELECT
			WCI.CompanyCode,
			CI.CompanyName,
			CI.CompanyNameL,
			MPM.WorkCenterCode,
			WCI.WorkCenterName,
			WCI.WorkCenterNameL,
			MPM.MachineCode,
			MPM.MachineName,
			MPM.InjectType,
			MPM.Capa,
			MPM.MachineDesc1,
			MPM.MonitoringGroup,
			MPM.ErpMachineCode,
			MPM.MachineDesc2,
			MPM.MachineDesc3,
			MPM.MachineDesc4,
			MPM.MachineDesc5,
			MPM.IsTemperatureControl,
			MPM.IsCommunication,
			MPM.RunMode,
			MPM.IsMachineAlarm,
			MPM.IsMoldTempControl,
			MPH.MoldNumber,
			MPH.JobDate,
			MPH.ShiftCode,
			MBI.MoldCategory1 AS CarType,
			MBI.MoldCategory2 AS Product,
			MBI.MoldCategory3 AS Spec,
			MBI.MoldCategory4,
			MBI.RawMaterial,
			MPM.MoldTemp1,
			MPM.MoldTemp2,
			MPM.MoldTemp3,
			MPM.MoldTemp4,
			MPM.MoldTemp5,
			MPM.MoldTemp6,
			--MPM.MoldTemp7,
			--MPM.MoldTemp8,
			--MPM.MoldTemp9,
			--MPM.MoldTemp10,
			ISNULL(MPM.IsMoldTempAlarm1,0) AS IsMoldTempAlarm1,
			ISNULL(MPM.IsMoldTempAlarm2,0) AS IsMoldTempAlarm2,
			ISNULL(MPM.IsMoldTempAlarm3,0) AS IsMoldTempAlarm3,
			ISNULL(MPM.IsMoldTempAlarm4,0) AS IsMoldTempAlarm4,
			ISNULL(MPM.IsMoldTempAlarm5,0) AS IsMoldTempAlarm5,
			ISNULL(MPM.IsMoldTempAlarm6,0) AS IsMoldTempAlarm6,
			--ISNULL(MPM.IsMoldTempAlarm7,0) AS IsMoldTempAlarm7,
			--ISNULL(MPM.IsMoldTempAlarm8,0) AS IsMoldTempAlarm8,
			--ISNULL(MPM.IsMoldTempAlarm9,0) AS IsMoldTempAlarm9,
			--ISNULL(MPM.IsMoldTempAlarm10,0) AS IsMoldTempAlarm10,
			MPM.MoldTemperatureSet1,
			MPM.MoldTemperatureSet2,
			MPM.MoldTemperatureSet3,
			MPM.MoldTemperatureSet4,
			MPM.MoldTemperatureSet5,
			MPM.MoldTemperatureSet6--,
			--MPM.MoldTemperatureSet7,
			--MPM.MoldTemperatureSet8,
			--MPM.MoldTemperatureSet9,
			--MPM.MoldTemperatureSet10,
			--ISNULL(MPM.HoperStatus,0) AS HoperStatus,
			--ISNULL(MPM.CallStatus,0) AS CallStatus
	FROM
			STB_MoldProductMachine MPM WITH(NOLOCK)
			LEFT OUTER JOIN STB_MoldProdHist MPH WITH(NOLOCK)
				ON MPM.MoldProdNo = MPH.MoldProdNo
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MPH.MoldNumber = MBI.MoldNumber
			LEFT OUTER JOIN STB_WorkCenterInfo WCI WITH(NOLOCK)
				ON MPM.WorkCenterCode = WCI.WorkCenterCode
			LEFT OUTER JOIN STB_CompanyInfo CI WITH(NOLOCK)
				ON WCI.CompanyCode = CI.CompanyCode
			
	WHERE
			((@CompanyCode = '*') OR (WCI.CompanyCode = @CompanyCode))
			AND ((@WorkCenterCode = '*') OR (MPM.WorkCenterCode = @WorkCenterCode))
			AND (MPM.IsTemperatureControl = 1)
	ORDER BY
			MPM.DisplayIndex

END






