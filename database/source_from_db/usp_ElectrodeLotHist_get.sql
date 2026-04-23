-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2022-02-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극 Lot 이력정보
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeLotHist_get]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pFromDate DATE,
	@pToDate DATE,
	@pMaterialCode VARCHAR(20) = NULL,
	@pBarcode VARCHAR(20) = NULL
AS
BEGIN
	Declare @FromDate DATE = @pFromDate
	       ,@ToDate DATE = @pToDate
		   ,@MaterialCode VARCHAR(20) = CASE WHEN ISNULL(@pMaterialCode, '') = '' THEN '*' ELSE @pMaterialCode END
		   ,@Barcode VARCHAR(20) = CASE WHEN ISNULL(@pBarcode, '') = '' THEN '*' ELSE @pBarcode END

	SELECT SI.InputJobDate AS AssemblyJobDate
		  ,SI.Barcode
		  ,PRH1.MachineCode AS WindingMachineCode
		  ,MM1.MachineName AS windingMachineName
		  ,PRH2.MachineCode AS CurlingMachineCode
		  ,MM2.MachineName AS CurlingMachineName
		  ,PRH3.MachineCode AS DopingMachineCode
		  ,MM3.MachineName AS DopingMachineName
		  ,PRH3.RouteCode
		  ,RI.RouteName
		  ,SUM(PRH3.ProdQty) AS InputQty
		  ,SUM(PRH3.ProdQty) - SUM(DRI.DefectQty - DRI.RepairQty) AS ProdQty
		  ,SUM(CASE WHEN DRI.DefectCode = 'E-29_03' THEN DRI.DefectQty ELSE 0 END) AS ESRDefectQty
		  ,SUM(CASE WHEN DRI.DefectCode = 'E-29_02' THEN DRI.DefectQty ELSE 0 END) AS OCVDefectQty
		  ,SUM(CASE WHEN DRI.DefectCode = 'E-29_01' THEN DRI.DefectQty ELSE 0 END) AS FaradDefectQty
		  ,RMIH1.RawMaterialBarcode AS AnodeBarcode
		  ,EMI1.WorkDate AS AnodeWorkDate
		  ,EMI1.MachineCode AS AnodeMixerMachineCode
		  ,MM4.MachineName AS AnodeMixerMachineName
		  ,EMI1.ViscosityValue AS AnodeViscosityValue
		  ,dbo.fnGetElectrodeDensityAvg(EMI1.ElectrodeLotNumber) AS AnodeRollingDensityValue
		  ,RMIH2.RawMaterialBarcode AS CathodeBarcode
		  ,EMI2.WorkDate AS CathodeWorkDate
		  ,EMI2.MachineCode AS CathodeMixerMachineCode
		  ,MM5.MachineName AS CathodeMixerMachineName
		  ,EMI2.ViscosityValue AS CathodeViscosityValue
		  ,dbo.fnGetElectrodeDensityAvg(EMI2.ElectrodeLotNumber) AS CathodeRollingDensityValue
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_ProdRouteHist PRH1
		ON SI.ControlNo = PRH1.ControlNo
	   AND PRH1.RouteCode = 'E-22'
	  LEFT OUTER JOIN STB_MachineMaster MM1
		ON MM1.MachineCode = PRH1.MachineCode
	  LEFT OUTER JOIN STB_ProdRouteHist PRH2
		ON SI.ControlNo = PRH2.ControlNo
	   AND PRH2.RouteCode = 'E-24'
	  LEFT OUTER JOIN STB_MachineMaster MM2
		ON MM2.MachineCode = PRH2.MachineCode
	  LEFT OUTER JOIN STB_ProdRouteHist PRH3
		ON SI.ControlNo = PRH3.ControlNo
	   AND PRH3.RouteCode = 'E-29'
	  LEFT OUTER JOIN STB_MachineMaster MM3
		ON MM3.MachineCode = PRH3.MachineCode
	  LEFT OUTER JOIN STB_RouteInfo RI
		ON RI.RouteCode = PRH3.RouteCode
	  LEFT OUTER JOIN ( SELECT ControlNo, FindRouteCode, DefectCode, SUM(DefectQty) AS DefectQty, SUM(RepairQty) AS RepairQty
						  FROM STB_DefectRepairInfo  WITH(NOLOCK) 
						 WHERE RepairType = 'NONE'
						 GROUP BY ControlNo, FindRouteCode, DefectCode
					) DRI	                                              
		ON PRH3.ControlNo = DRI.ControlNo        
	   AND PRH3.RouteCode = DRI.FindRouteCode
	  LEFT OUTER JOIN STB_RawMaterialInputHist RMIH1
		ON RMIH1.Barcode = SI.Barcode
	   AND RMIH1.ProductGroupCode = 'ElectrodeP'
	  LEFT OUTER JOIN STB_RawMaterialInputHist RMIH2
		ON RMIH2.Barcode = SI.Barcode
	   AND RMIH2.ProductGroupCode = 'ElectrodeM'
	  LEFT OUTER JOIN STB_ElectrodeMixInfo EMI1
		ON EMI1.ElectrodeLotNumber = LEFT(RMIH1.RawMaterialBarcode, 14)
	  LEFT OUTER JOIN STB_ElectrodeMixInfo EMI2
		ON EMI2.ElectrodeLotNumber = LEFT(RMIH2.RawMaterialBarcode, 14)
	  LEFT OUTER JOIN STB_MachineMaster MM4
		ON MM4.MachineCode = EMI1.MachineCode
	  LEFT OUTER JOIN STB_MachineMaster MM5
		ON MM5.MachineCode = EMI2.MachineCode
	  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI1
		ON ERPI1.ElectrodeLotNumber = SI.Barcode
	  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI2
		ON ERPI2.ElectrodeLotNumber = SI.Barcode                                                        
	 WHERE 1=1
	   AND SI.InputJobDate BETWEEN @FromDate AND @ToDate
	   AND (@MaterialCode = '*' OR SI.MaterialCode = @MaterialCode)
	   AND (@Barcode = '*' OR SI.Barcode = @Barcode)
	 GROUP BY  SI.InputJobDate
			  ,SI.Barcode
			  ,PRH1.MachineCode
			  ,MM1.MachineName
			  ,PRH2.MachineCode
			  ,MM2.MachineName
			  ,PRH3.MachineCode
			  ,MM3.MachineName
			  ,PRH3.RouteCode
			  ,PRH3.RouteCode
			  ,RI.RouteName
			  ,RMIH1.RawMaterialBarcode
			  ,EMI1.WorkDate
			  ,EMI1.MachineCode
			  ,MM4.MachineName
			  ,EMI1.ViscosityValue
			  ,EMI1.ElectrodeLotNumber
			  ,RMIH2.RawMaterialBarcode
			  ,EMI2.WorkDate
			  ,EMI2.MachineCode
			  ,MM5.MachineName
			  ,EMI2.ViscosityValue
			  ,EMI2.ElectrodeLotNumber
END