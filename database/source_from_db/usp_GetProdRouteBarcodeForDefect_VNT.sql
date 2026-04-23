
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-12
-- Browsable : true
-- Group : 생산관리
-- Description: [B530] 제품생산실적입력 > 2TAB 제품불량정보
-- Modified: 제품불량정보
-- 프로시저 실행 :    Exec [usp_GetProdRouteBarcodeForDefect_VNT] '','','E-22','','','VJJP063R010501',''
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetProdRouteBarcodeForDefect_VNT]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pRouteCode VARCHAR(20) = NULL,
	@pWorkerCode VARCHAR(20) = NULL,
	@pMachineCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(50) = NULL,
	@pMachineID VARCHAR(20) = NULL	
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
	DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
	DECLARE @RouteCode VARCHAR(20) = @pRouteCode
	DECLARE @WorkerCode VARCHAR(20) = @pWorkerCode
	DECLARE @Barcode VARCHAR(50) = @pBarcode
	DECLARE @MachineID VARCHAR(20) = ISNULL(@pMachineID,'')
	DECLARE @MachineCode VARCHAR(20) = ISNULL(@pMachineCode,'')
	
	DECLARE @CompanyCode VARCHAR(20)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @LineCode VARCHAR(20)
	DECLARE @ProdQty NUMERIC(20,5)	
	DECLARE @ProcessDateTime DATETIME = GETDATE()
	DECLARE @NewBarcode VARCHAR(50)

	SELECT @NewBarcode = NewBarcode
	  FROM STB_LotChangeMaterialHistory WITH(NOLOCK)
	 WHERE OldBarcode = @Barcode

	SELECT
			@CompanyCode = POI.CompanyCode,
			@WorkCenterCode = POI.WorkCenterCode,
			@LineCode = SI.InputLineCode
	FROM
			STB_SetInfo SI WITH(NOLOCK)
			INNER JOIN STB_ProductionOrderInfo POI WITH(NOLOCK)				ON POI.PONo = SI.PONo
	WHERE
			SI.Barcode = @Barcode

	DECLARE @JobDateShift VARCHAR(20) = dbo.fnGetJobDateShiftTime(@ProcessDateTime,@CompanyCode,@WorkCenterCode,@LineCode,@RouteCode,NULL)
	DECLARE @JobDate DATE = SUBSTRING(@JobDateShift,1,8)
	DECLARE @ShiftCode VARCHAR(1) = SUBSTRING(@JobDateShift,9,1)
	
	
	SELECT
			DRI.DefectSummaryNo,
			DRI.ControlNo,
			SI.PONo,
			SI.DayPlanNo,
			SI.Barcode,
			SI.MaterialCode,
			DI.DefectGroupCode,
			DG.BasicDefectGroupName,
			DRI.DefectCode,
			DI.BasicDefectName,
			DRI.DefectQty,
			@RouteCode AS RouteCode,
			@LineCode AS LineCode,
			DRI.DRIExtText02,
			DRI.MarKingCode,
			DRI.DefectCauseID,
			Y.DefectCause
		
			
	FROM
			                      STB_DefectRepairInfo DRI WITH(NOLOCK)
			INNER JOIN        STB_SetInfo SI              WITH(NOLOCK)	ON SI.ControlNo = DRI.ControlNo
			LEFT OUTER JOIN STB_DefectInfo DI          WITH(NOLOCK)	ON DI.DefectCode = DRI.DefectCode
			LEFT OUTER JOIN STB_DefectGroup DG      WITH(NOLOCK) 	ON DG.DefectGroupCode = DI.DefectGroupCode
			LEFT OUTER JOIN STB_TypeErrorGroupOfFactory TEG      WITH(NOLOCK)	ON DI.DirectlyUnder = TEG.TypeErrorCode
		    LEFT JOIN STB_DefectCauseNG Y  WITH(NOLOCK)  ON Y.Id=DRI.DefectCauseID
	WHERE
			(SI.Barcode = @Barcode OR SI.Barcode = @NewBarcode) AND
			DRI.FindRouteCode = @RouteCode AND
			(DRI.RepairType IS NULL OR DRI.RepairType NOT IN ('FINISH'))
			--and DRI.DefectCode not in (select DefectCode from dbo.fn_VVT_QCPARTCODE() where flag ='QC') -- add by Mr.Tung on 2023-08-15
			--AND DI.DirectlyUnder NOT IN ('PQC')   -- Mr.Duy add 2025-04-01
	 
END