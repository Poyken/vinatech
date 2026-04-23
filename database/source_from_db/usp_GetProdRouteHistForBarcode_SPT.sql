-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2024-05-09
-- Browsable : true
-- Group : 생산관리
-- Description: 

-- =============================================

CREATE PROCEDURE usp_GetProdRouteHistForBarcode_SPT
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pBarcode VARCHAR(50)
AS

BEGIN
	Declare @Barcode VARCHAR(20) = @pBarcode
	Declare @PONo VARCHAR(20)

	SELECT @PONo = PONo
	  FROM STB_SetInfo
	 WHERE Barcode = @Barcode

	IF @PONo IS NULL BEGIN
		EXEC usp_RaiseLocalizedError @pProcessLanguage, 'PO정보가 존재하지 않습니다. Lot번호를 확인하세요.'
		RETURN
	END

	SELECT PRH.CompanyCode
	      ,CI.CompanyName
	      ,PRH.WorkCenterCode
		  ,WI.WorkCenterName
		  ,PRH.PONo
		  ,PRH.MaterialCode
		  ,MM1.MaterialName
		  ,PRH.JobDate
		  ,PRH.LineCode
		  ,LI.LineName
		  ,PRH.RouteCode
		  ,RI.RouteName
		  ,PRH.WorkerCode
		  ,PWI.WorkerName
		  ,PRH.MachineCode
		  ,MM2.MachineName
		  ,PRH.ProdQty
		  ,PRH.ProdDateTime
	  FROM STB_ProdRouteHist PRH
	  LEFT OUTER JOIN STB_SetInfo SI
	    ON SI.ControlNo = PRH.ControlNo
	  LEFT OUTER JOIN STB_ProductionOrderRouting POR
	    ON POR.PONo = SI.PONo
	   AND POR.RouteCode = PRH.RouteCode
	  LEFT OUTER JOIN STB_CompanyInfo CI
	    ON CI.CompanyCode = PRH.CompanyCode
	  LEFT OUTER JOIN STB_WorkCenterInfo WI
	    ON WI.WorkCenterCode = PRH.WorkCenterCode
	  LEFT OUTER JOIN STB_MaterialMaster MM1
	    ON MM1.MaterialCode = PRH.MaterialCode
	  LEFT OUTER JOIN STB_LineInfo LI
	    ON LI.LineCode = PRH.LineCode
	  LEFT OUTER JOIN STB_RouteInfo RI
	    ON RI.RouteCode = PRH.RouteCode
	  LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON PWI.WorkerCode = PRH.WorkerCode
	  LEFT OUTER JOIN STB_MachineMaster MM2
	    ON MM2.MachineCode = PRH.MachineCode
	 WHERE SI.Barcode = @Barcode
	 ORDER BY POR.RouteIndex
END