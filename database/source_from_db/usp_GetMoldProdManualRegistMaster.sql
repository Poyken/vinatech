


-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2017-09-13
-- Browsable : true
-- Group : 생산관리
-- Description:	수작업 금형별 생산실적 조회 및 등록 화면
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetMoldProdManualRegistMaster]
	@pProcessUserID VARCHAR(20),	
	@pProcessLanguage VARCHAR(20),
    @pCompanyCode VARCHAR(20) = NULL,
    @pWorkCenterCode VARCHAR(20) = NULL,
    @pFromJobDate DATE = NULL,
    @pToJobDate DATE = NULL,
    @pShiftCode VARCHAR(1) = NULL,
    @pMachineCode VARCHAR(20) = NULL
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @CompanyCode VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END
    DECLARE @WorkCenterCode VARCHAR(20) = CASE WHEN ISNULL(@pWorkCenterCode,'') = '' THEN '%' ELSE @pWorkCenterCode END
    DECLARE @FromJobDate DATE = @pFromJobDate
    DECLARE @ToJobDate DATE = @pToJobDate
    DECLARE @ShiftCode VARCHAR(20) = CASE WHEN ISNULL(@pShiftCode,'') = '' THEN '%' ELSE @pShiftCode END
    DECLARE @MachineCode VARCHAR(20) = CASE WHEN ISNULL(@pMachineCode,'') = '' THEN '%' ELSE @pMachineCode END
    
	; WITH DayProdPlan AS
	(
		SELECT
				DPP.*
		FROM
				STB_DayProdPlan DPP WITH(NOLOCK)
		WHERE
				DPP.CompanyCode LIKE @CompanyCode AND
				DPP.WorkCenterCode LIKE @WorkCenterCode AND
				DPP.IsCancel = 0 AND
				DPP.IsFixed = 1 AND
				DPP.MachineCode LIKE @MachineCode AND
				DPP.PlanShiftCode LIKE @ShiftCode AND
				DPP.PlanDate BETWEEN @FromJobDate AND @ToJobDate
	), MoldProdHist AS
	(
		SELECT
				MPH.DayPlanNo,
				SUM(MPH.ShotQty) AS ShotQty
		FROM
				STB_MoldProdHist MPH WITH(NOLOCK)
		WHERE
				MPH.DayPlanNo IN (SELECT DayPlanNo FROM DayProdPlan)
		GROUP BY
				MPH.DayPlanNo
	), MoldProdWorkerHist AS
	(
		SELECT
				MPH.DayPlanNo,
				MPH.WorkerCode,
				MIN(MPH.StartDateTime) AS StartDateTime,
				MIN(MPH.ActStartDateTime) AS ActStartDateTime,
				MAX(MPH.ActEndDateTime) AS ActEndDateTime
		FROM
				STB_MoldProdHist MPH WITH(NOLOCK)
		WHERE
				MPH.DayPlanNo IN (SELECT DayPlanNo FROM DayProdPlan)
		GROUP BY
				MPH.DayPlanNo,
				MPH.WorkerCode
	)
	SELECT
	        DPP.DayPlanNo,
	        DPP.PlanDate AS JobDate,
	        DPP.PlanShiftCode AS ShiftCode,
	        DPP.ProdPrior AS WorkSeq,
	        DPP.MachineCode,
	        MPM.MachineName,
	        MPM.InjectType,
			MPM.Capa,
			MPM.DisplayIndex,
	        DPP.MoldNumber,
	        MBI.MoldCategory1,
			MBI.MoldCategory2,
			MBI.MoldCategory3,
	        DPP.PlanQty AS PlanShot,
			ISNULL(MPH.ShotQty,0) AS RealShotQty,
			CASE WHEN MPWH.ActStartDateTime IS NULL THEN dbo.fnGetStartWorkingTime(DPP.PlanDate,DPP.PlanShiftCode,DPP.CompanyCode,DPP.WorkCenterCode,DPP.LineCode,NULL,DPP.MachineCode)
					ELSE  MPWH.ActStartDateTime 
			END AS ActStartDateTime,

			CASE WHEN MPWH.StartDateTime IS NULL THEN dbo.fnGetStartWorkingTime(DPP.PlanDate,DPP.PlanShiftCode,DPP.CompanyCode,DPP.WorkCenterCode,DPP.LineCode,NULL,DPP.MachineCode)
					ELSE  MPWH.StartDateTime 
			END AS StartDateTime,

			CASE WHEN MPWH.ActEndDateTime IS NULL THEN dbo.fnGetEndWorkingTime(DPP.PlanDate,DPP.PlanShiftCode,DPP.CompanyCode,DPP.WorkCenterCode,DPP.LineCode,NULL,DPP.MachineCode)
					ELSE  MPWH.ActEndDateTime 
			END AS ActEndDateTime,			
	        MPWH.WorkerCode,
			PWI.WorkerName,
	        DPP.PlanWorkTime
	        --MPP.MoldAlarm
	FROM
	        DayProdPlan DPP WITH(NOLOCK)
	        LEFT OUTER JOIN STB_MoldProductMachine MPM WITH(NOLOCK)
				ON MPM.MachineCode = DPP.MachineCode 
			LEFT OUTER JOIN STB_MoldBasicInfo MBI WITH(NOLOCK)
				ON MBI.MoldNumber = DPP.MoldNumber
			LEFT OUTER JOIN MoldProdHist MPH
				ON MPH.DayPlanNo = DPP.DayPlanNo
			LEFT OUTER JOIN MoldProdWorkerHist MPWH
				ON MPWH.DayPlanNo = DPP.DayPlanNo
			LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)
				ON PWI.WorkerCode = MPWH.WorkerCode
END