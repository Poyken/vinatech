
-- =============================================
-- Author:	    kilee
-- Create date: 2019-08-06
-- Browsable : true
-- Group : 생산관리
-- Description: 제품박스실적입력 2번째 Tab
-- Modified: 조립공정카드 (베트남이동시)
-- =============================================

-- EXEC [usp_Assembly_Process_Card] '','','', '2019-08-26', '2019-08-27'

CREATE PROCEDURE [dbo].[usp_Assembly_Process_Card]
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pBarcode VARCHAR(50) = NULL,
								@pFromDate DATE = NULL,
								@pToDate DATE = NULL
AS

BEGIN
	SET NOCOUNT ON;

	DECLARE @Barcode VARCHAR(50) = @pBarcode	
	DECLARE @FromDate DATE         = @pFromDate
	DECLARE @ToDate DATE            = @pToDate
		
	--;WITH LabelInfo AS
	--(
	--	SELECT
	--			RANK() OVER (PARTITION BY LI.LabelType,LI.FormatName ORDER BY LI.FormatVersion DESC) AS RankIndex,
	--			LI.LabelType,
	--			LI.FormatName,
	--			LI.CommandType,
	--			LI.Dpi,
	--			LI.PrinterName
	--	FROM
	--			SmartFramework.dbo.STB_LabelInfo LI WITH(NOLOCK)
	--	WHERE
	--			LI.IsApproval = 1 AND
	--			LI.ApplyDate <= GETDATE()
	--) , MainAssemble AS
	--(
	--	SELECT
	--			MAPI.ControlNo,
	--			COUNT(*) AS AssmCount
	--	FROM
	--			STB_MainAssemblePartInfo MAPI WITH(NOLOCK)
	--	WHERE
	--			MAPI.ControlNo IN (
	--										SELECT 
	--												ControlNo 
	--										FROM 
	--												STB_SetInfo SI WITH(NOLOCK) 
	--										WHERE
	--												SI.PONo = @PONo AND
	--												SI.DayPlanNo LIKE @DayPlanNo
	--							        )
	--	GROUP BY
	--			MAPI.ControlNo
	--)

	SELECT
			SI.ControlNo AS OldControlNo,
			SI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.MaterialCode,
			MM.MaterialName,
			SI.SetSeq,
			SI.IsLineInput,
			SI.IsLoss,
			SI.IsDefect,
			SI.CurrentRouteCode,
			SI.InternalProdNo,
			SI.OutSetNo,
			SI.OutSetNoSeq,
			SI.Barcode,
			SUBSTRING(SI.Barcode, 16, 3) AS Cutno ,
			SI.InputLineCode,
			LI.LineName,
			SI.InputJobDate,
			SI.InputShiftCode,
			SI.InputDateTime,
			SI.DefectQty,
			SI.IsProdFinish,
			SI.ProdFinishJobDate,
			SI.ProdFinishShiftCode,
			SI.ProdFinishDateTime,
			SI.SalesOrderNo,
			SI.SOISequence,
			SI.IsOutboundFinalInspection,
			SI.IsFinalInspection,
			SI.FinalInspectionJobDate,
			SI.FinalInspectionShiftCode,
			SI.FinalInspectionDateTime,
			SI.LotNumber,
			SI.LotCreateDateTime,
			SI.LotDecisionResult,
			SI.GradeCode,
			SI.GradeChangeJobDate,
			SI.GradeChangeShiftCode,
			SI.GradeChangeDateTime,
			SI.GradeChangeUserID,
			SI.GradeModelCode,
			SI.GradeChangeSetNo,
			SI.PrintDate,
			SI.LineOutTactTime,
			SI.ProdQty,
			SI.SIExtText01,
			SI.SIExtText02,
			SI.SIExtText03,
			SI.SIExtText04,
			SI.SIExtText05,
			SI.SIExtInt01,
			SI.SIExtInt02,
			SI.SIExtInt03,
			SI.SIExtInt04,
			SI.SIExtInt05,
			SI.SIExtReal01,
			SI.SIExtReal02,
			SI.SIExtReal03,
			SI.SIExtReal04,
			SI.SIExtReal05,
			SI.CreateDateTime,
			SI.CreateUserID,
			SI.ChangeDateTime,
			SI.ChangeUserID,
			SUBSTRING(SI.Barcode,10,2) AS MixBatchNo,
			SUBSTRING(SI.Barcode,12,1) AS EDLC,
			0 AS LabelQty,
			--LBI.CommandType,
			--LBI.FormatName,
			--LBI.LabelType,
			--LBI.PrinterName,
			--MA.AssmCount,
			MBI.MBIExtText04 + '(V)-' + MBIExtText05 + '(F)' AS ItemSpec,
			LotUniqueNumber
       FROM
			STB_SetInfo SI WITH(NOLOCK)
			LEFT OUTER JOIN STB_LineInfo LI WITH(NOLOCK)				    ON LI.LineCode = SI.InputLineCode
			LEFT OUTER JOIN STB_MaterialMaster MM WITH(NOLOCK)		ON MM.MaterialCode = SI.MaterialCode
			--LEFT OUTER JOIN STB_ModelLabelInfo MLI WITH(NOLOCK)		ON MLI.ModelCode = SI.MaterialCode        AND MLI.LabelType = @LabelType
			--LEFT OUTER JOIN LabelInfo LBI				                        ON LBI.LabelType = @LabelType             AND LBI.FormatName = MLI.FormatName     AND LBI.RankIndex = 1
			--LEFT OUTER JOIN MainAssemble MA				                ON MA.ControlNo = SI.ControlNo
			LEFT OUTER JOIN STB_ModelBasicInfo MBI WITH(NOLOCK)		ON SI.MaterialCode = MBI.ModelCode	   
	   WHERE 1=1
			AND (SI.CreateDateTime BetWeen @FromDate  AND  @ToDate)
			AND  SI.Barcode = 'VJJQ262R718601'

	ORDER BY SI.ControlNo

END


--	@pProcessUserID VARCHAR(20),
--	@pProcessLanguage VARCHAR(20),
--	@pBarcode VARCHAR(50) = NULL,
--	--@pLineCode VARCHAR(20) = NULL,
--	--@pWorkerCode VARCHAR(20) = NULL,
--	--@pMachineID VARCHAR(20) = NULL,
--	@pFromDate DATE = NULL,
--	@pToDate DATE = NULL
--AS

--BEGIN
--	SET NOCOUNT ON;

	--DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	--DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	----DECLARE @WorkerCode VARCHAR(20) = @pWorkerCode
	--DECLARE @Barcode VARCHAR(50) = @pBarcode	
	----DECLARE @MachineID VARCHAR(20) = ISNULL(@pMachineID,'')

	--DECLARE @LineCode VARCHAR(20)
	--DECLARE @ProcessDateTime DATETIME = GETDATE()
	--DECLARE @WorkCenterCode VARCHAR(20)
	--DECLARE @RouteCode VARCHAR(20)
	--DECLARE @PONo VARCHAR(20)
	--DECLARE @ErrorMessage NVARCHAR(500)
	--DECLARE @CurrentQty NUMERIC(20,5)
	--DECLARE @TotalQty NUMERIC(20,5)
	--DECLARE @BasicMaterialType VARCHAR(20)
	--DECLARE @InputLineCode VARCHAR(20)
	--DECLARE @DecisionResult VARCHAR(10)
	--DECLARE @DPPExtText01 NVARCHAR(100)
	--DECLARE @ControlNo VARCHAR(20)
	--DECLARE @FromDate DATE                   = @pFromDate
	--DECLARE @ToDate DATE                      = @pToDate
	
--	SELECT
--			'' AS 스트리핑
--          , '' AS 권취
--		  , '' AS 커링
--		  , '' AS 건조보온
--		  , '' AS 에이징
--		  , '' AS 외관
--		  , '' AS 포장
--	FROM
--			STB_SetInfo SI WITH(NOLOCK)
--			INNER JOIN STB_ProductionOrderRouting POR WITH(NOLOCK)	 ON POR.PONo = SI.PONo                   AND	 POR.IsOutputRoute = 1
--			LEFT OUTER JOIN STB_ProdRouteHist PRH WITH(NOLOCK)		 ON PRH.ControlNo = SI.ControlNo        AND PRH.RouteCode = POR.RouteCode
--			INNER JOIN STB_MaterialQcInfo MQI WITH(NOLOCK)				 ON MQI.MaterialQcNo = SI.LotNumber
--			INNER JOIN STB_DayProdPlan DPP WITH(NOLOCK)				     ON DPP.DayPlanNo = SI.DayPlanNo
--			LEFT OUTER JOIN STB_MaterialLotInfo SML WITH(NOLOCK)		 ON SML.LotNo = SI.Barcode
--	WHERE 1=1
--			--AND SI.Barcode = @Barcode
--			--AND SI.Barcode = 'VJJP233R010503'
--			AND (SI.CreateDateTime BetWeen @FromDate  AND  @ToDate)
	
--END