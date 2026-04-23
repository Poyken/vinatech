-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-06
-- Browsable : false
-- Group : 현장용
-- Description:	공정별 생산실적을 가져옵니다
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdRouteHistForBarcode]
	@pBarcode VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode VARCHAR(50) = @pBarcode

	;WITH ProdWorker AS
	(
		SELECT
				PRH.ControlNo,
				PRH.RouteCode,
				PRWH.WorkerCode,
				PWI.WorkerName,
				COUNT(*) AS WorkerCount
		FROM
				STB_ProdRouteHist PRH WITH(NOLOCK)
				INNER JOIN STB_SetInfo SI WITH(NOLOCK)
					ON SI.ControlNo = PRH.ControlNo
				LEFT OUTER JOIN STB_ProdRouteWorkerHist PRWH WITH(NOLOCK)
					ON PRWH.ProdRouteHistNo = PRH.ProdRouteHistNo
				LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)
					ON PWI.WorkerCode = PRWH.WorkerCode
		WHERE
				SI.Barcode = @Barcode
		GROUP BY
				SI.Barcode,
				PRH.ControlNo,
				PRH.RouteCode,
				PRWH.WorkerCode,
				PWI.WorkerName
	)
		SELECT
				ISNULL(SI.SIExtInt01,0) AS IsHolding,
				SI.ControlNo,
				SI.Barcode,
				SI.MaterialCode,
				MM.MaterialName,
				PRH.RouteCode,
				RI.RouteName,
				PRH.WorkerCode,
				CASE
					WHEN (
							SELECT COUNT(*) 
							FROM 
									ProdWorker 
							WHERE 
									ControlNo = SI.ControlNo AND
									RouteCode = PRH.RouteCode) > 1 THEN (
																			SELECT  TOP 1
																					WorkerName 
																			FROM 
																					ProdWorker 
																			WHERE 
																					ControlNo = SI.ControlNo AND
																					RouteCode = PRH.RouteCode
																		) + ' 외'
				ELSE PWI.WorkerName
				END AS WorkerName,
				SUM(PRH.ProdQty) AS ProdQty,
				ISNULL(Defect.DefectQty,0) AS DefectQty,
				MAX(PRH.ProdDateTime) AS ProdDateTime,
				SI.ProdQty AS PlanQty,
				SI.CreateUserID,
				UI.UserName,
				SI.CreateDateTime,
				MBI.MBIExtText04 + 'V-' + MBI.MBIExtText05 + 'F (' 
				    + CASE WHEN MBI.MBISizeW < 10 THEN '0' + CONVERT(CHAR(1), CONVERT(INT, MBI.MBISizeW)) 
					  ELSE CONVERT(CHAR(2), CONVERT(INT, MBI.MBISizeW)) END 
				    + CONVERT(CHAR(2), CONVERT(INT, MBI.MBISizeH)) + ')' AS ProdModel,
				CASE
					WHEN ISNULL(PM.MachineCode,'') = '' THEN PRH.MachineCode
					ELSE PM.MachineCode
				END AS MachineCode,
				CASE
					WHEN ISNULL(PM.MachineCode,'') = '' THEN MCM.MachineName
					ELSE PMCM.MachineName
				END AS MachineName
		FROM
				STB_SetInfo SI WITH(NOLOCK)
				LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)
					ON SI.ControlNo = PRH.ControlNo
				LEFT OUTER JOIN STB_RouteInfo RI WITH(NOLOCK)
					ON RI.RouteCode = PRH.RouteCode
				LEFT OUTER JOIN STB_ProdWorkerInfo PWI WITH(NOLOCK)
					ON PWI.WorkerCode = PRH.WorkerCode
				LEFT OUTER JOIN
				(
					SELECT
							SI.ControlNo,
							DRI.FindRouteCode,
							ISNULL(SUM(DRI.DefectQty),0) AS DefectQty
					FROM
							STB_SetInfo SI WITH(NOLOCK)
							INNER JOIN STB_DefectRepairInfo DRI WITH(NOLOCK)
								ON DRI.ControlNo = SI.ControlNo
					WHERE
							SI.Barcode = @Barcode AND
							DRI.RepairType NOT IN ('MISSING', 'FINISH')
					GROUP BY
							SI.ControlNo,
							DRI.FindRouteCode
				) Defect
					ON Defect.ControlNo = PRH.ControlNo AND
					PRH.RouteCode = Defect.FindRouteCode
				LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)
					ON MM.MaterialCode = SI.MaterialCode
				LEFT OUTER JOIN SmartFramework.dbo.STB_UserInfo UI WITH(NOLOCK)
					ON UI.UserID = SI.CreateUserID
				LEFT OUTER JOIN VW_ModelBasicInfo MBI
				    ON MBI.ModelCode = SI.MaterialCode
				LEFT OUTER JOIN STB_ProductMachine PM WITH(NOLOCK)
					ON PM.LineCode = SI.InputLineCode AND
					PM.RouteCode = PRH.RouteCode
				LEFT OUTER JOIN STB_MachineMaster PMCM WITH(NOLOCK)
					ON PMCM.MachineCode = PM.MachineCode
				LEFT OUTER JOIN STB_MachineMaster MCM WITH(NOLOCK)
					ON MCM.MachineCode = PRH.MachineCode
		WHERE
				SI.Barcode = @Barcode
		GROUP BY
				SI.SIExtInt01,
				SI.ControlNo,
				SI.Barcode,
				SI.MaterialCode,
				MM.MaterialName,
				PRH.RouteCode,
				RI.RouteName,
				PRH.WorkerCode,
				PWI.WorkerName,
				Defect.DefectQty,
				SI.ProdQty,
				SI.CreateUserID,
				UI.UserName,
				SI.CreateDateTime,
				MBI.MBIExtText04,
				MBI.MBIExtText05,
				MBI.MBISizeW,
				MBI.MBISizeH,
				PRH.MachineCode,
				PM.MachineCode,
				MCM.MachineName,
				PMCM.MachineName
END

