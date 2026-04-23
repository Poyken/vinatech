

--   EXEC usp_VN_SearchLotNoCell  'VVKU163R033515'

-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_SearchLotNoCell]
	@pBarcode [varchar](20) 
WITH EXECUTE AS CALLER
AS
BEGIN
    --SELECT @TotalCount = COUNT(*) FROM STB_ProdRouteHist WHERE ControlNo = (SELECT ControlNo FROM STB_SetInfo WHERE Barcode = @Barcode)

	SET NOCOUNT ON;

	Declare @Barcode VARCHAR(20) = @pBarcode
	       ,@TotalCount INT
		   ,@Bar NVARCHAR(50)

SELECT
	@Bar = PRH.RouteCode
 FROM STB_ProdRouteHist PRH
 WHERE PRH.ControlNo = ( SELECT ControlNo
									   FROM STB_SetInfo SI
									  WHERE Barcode = @Barcode
									  ) AND PRH.RouteCode = 'V-28'

IF @Bar IS NOT NULL
BEGIN
 SELECT 
			PRH.MaterialCode
	       ,MM.MaterialName
		   ,PRH.LineCode
		   ,PRH.RouteCode
		   ,RI.RouteName
		   ,PRH.ProdQty AS InputProdQty
		   ,ISNULL(DRI.DefectQty, 0) AS DefectQty
		   ,(PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
		  , PRH.ProdDateTime AS ProdDate,
		  ' '  AS 'QTYACT'
	   FROM STB_ProdRouteHist PRH
			   LEFT OUTER JOIN STB_MaterialMaster MM	     ON PRH.MaterialCode = MM.MaterialCode
			   LEFT OUTER JOIN STB_ProdWorkerInfo PWI	     ON PRH.WorkerCode = PWI.EmpNo
			   LEFT OUTER JOIN STB_MachineMaster MM2	     ON PRH.MachineCode = MM2.MachineCode
			   LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty - RepairQty) AS DefectQty 
										  FROM STB_DefectRepairInfo 
										 WHERE RepairType NOT IN ('MISSING', 'FINISH')
										 GROUP BY ControlNo, FindRouteCode
									  ) DRI	     ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

			   LEFT OUTER JOIN STB_RouteInfo RI	     ON PRH.RouteCode = RI.RouteCode

	  WHERE PRH.ControlNo = ( SELECT ControlNo
									   FROM STB_SetInfo SI
									  WHERE Barcode = @Barcode
									  ) AND PRH.RouteCode = 'V-28' 
END

ELSE

	BEGIN
	 SELECT 
			PRH.MaterialCode
	       ,MM.MaterialName
		   ,PRH.LineCode
		   ,PRH.RouteCode
		   ,RI.RouteName
		   ,PRH.ProdQty AS InputProdQty
		   ,ISNULL(DRI.DefectQty, 0) AS DefectQty
		   ,(PRH.ProdQty - ISNULL(DRI.DefectQty, 0)) AS ProdQty
		  , PRH.ProdDateTime AS ProdDate,
		  ' '  AS 'QTYACT'
	   FROM STB_ProdRouteHist PRH
			   LEFT OUTER JOIN STB_MaterialMaster MM	     ON PRH.MaterialCode = MM.MaterialCode
			   LEFT OUTER JOIN STB_ProdWorkerInfo PWI	     ON PRH.WorkerCode = PWI.EmpNo
			   LEFT OUTER JOIN STB_MachineMaster MM2	     ON PRH.MachineCode = MM2.MachineCode
			   LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, SUM(DefectQty - RepairQty) AS DefectQty 
										  FROM STB_DefectRepairInfo 
										 WHERE RepairType NOT IN ('MISSING', 'FINISH')
										 GROUP BY ControlNo, FindRouteCode
									  ) DRI	     ON PRH.ControlNo = DRI.ControlNo        AND PRH.RouteCode = DRI.FindRouteCode

			   LEFT OUTER JOIN STB_RouteInfo RI	     ON PRH.RouteCode = RI.RouteCode

	  WHERE PRH.ControlNo = ( SELECT ControlNo
									   FROM STB_SetInfo SI
									  WHERE Barcode = @Barcode
									  ) AND PRH.RouteCode ='E-28'
	END

	

END

--select * from STB_SetInfo