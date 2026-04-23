-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-08
-- Browsable : true
-- Group : 생산관리 > [B799] 전극재고현황 > Grid1. OneRoll 재공현황 조회부분
-- Description:	
-- Modified:

-- [usp_ElectrodeInventoryInquiryOneRoll_get] 'klee', 'Korean', 'VNT', '2020-01-01', '2020-05-28'
-- [usp_ElectrodeInventoryInquiryOneRoll_get] 'klee', 'Korean', 'VVT', '2020-01-01', '2020-05-28'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeInventoryInquiryOneRoll_get]
								@pProcessUserID VARCHAR(20),
								@pProcessLanguage VARCHAR(20),
								@pCompanyCode VARCHAR(20) = NULL,
								@pFromDate DATE,
								@pToDate     DATE
								--@pElectrodeRouteGroup VARCHAR(20) = NULL
								--@pPrintYn     VARCHAR(1)
								
AS

BEGIN
	DECLARE @ElectrodeLotNumber  VARCHAR(20) 
		       , @FromDate                DATE = @pFromDate
	           , @ToDate                   DATE = @pToDate
			  -- , @ElectrodeRouteGroup  VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteGroup, '') = '' THEN '*' ELSE @pElectrodeRouteGroup END
			  -- , @PrintYn                   VARCHAR(1) = CASE WHEN ISNULL(@pPrintYn, '') = '' THEN '*' ELSE @pPrintYn END
			  -- , @PrintYn                   VARCHAR(1) = CASE WHEN @pCompanyCode = 'VVT' THEN '1'  WHEN @pCompanyCode = 'VNT' THEN '0'  ELSE '' END
			   --, @CompanyCode         VARCHAR(20) = @pCompanyCode
			    , @PrintYn                  BIT = CASE WHEN @pCompanyCode = 'VVT' THEN CONVERT(BIT, 1)   ELSE  CONVERT(BIT, 0) END

 SELECT A.ElectrodeLotNumber
			, A.ElectrodeType
		    ,A.MachineCode
			,A.MachineName
			,A.WorkDate
			,A.WorkerCode 
			,A.WorkerName
			,A.Temperature
			,A.Humidity
			,A.RollingDensityValue
			,A.RollingDensityResult
			,A.HeadGapInitLeft
			,A.HeadGapInitRight
			,A.ProdConTemp
			,A.ProdConSpeed
			,A.ProductionQty
			,A.GoodQty
			,A.BadQty
			,A.VisualInspectionResult
			,A.CreateDateTime
			,A.CreateUserID
			,A.ChangeDateTime
			,A.ChangeUserID
			,A.MaterialCode
			,A.MaterialName
			,A.MaterialThickness
			, A.PrintYn
			, A.ElectrodeRouteGroup		 
 FROM (
			SELECT   ISNULL(ERPI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
					  , Case When MM2.MaterialName like '%MSP%' Then 'MSP'
						       When MM2.MaterialName like '%YP%' Then 'YP'
						       When MM2.MaterialName like '%CEP%' Then 'CEP'
								When MM2.MaterialName like '%LMO%' Then 'LMO' ELSE '기타' END  ElectrodeType
					   , ERPI.MachineCode
					   , MM.MachineName						
					   , ERPI.WorkDate
					   , ERPI.WorkerCode 
					   , PWI.WorkerName
					   , ERPI.Temperature
					   , ERPI.Humidity
					   , ISNULL(ERPI.RollingDensityValue, 0) AS RollingDensityValue              -- SELECT ISNULL(RollingDensityValue,0), *  FROM STB_ElectrodeRollPressingInfo
					   , ERPI.RollingDensityResult
					   , ERPI.HeadGapInitLeft
					   , ERPI.HeadGapInitRight
					   , ERPI.ProdConTemp
					   , ERPI.ProdConSpeed
					   , ERPI.ProductionQty
						,ERPI.GoodQty
						,ERPI.BadQty
						,ERPI.VisualInspectionResult
						,ERPI.CreateDateTime
						,ERPI.CreateUserID
						,ERPI.ChangeDateTime
						,ERPI.ChangeUserID
						,SI.MaterialCode
						,MM2.MaterialName
						,MM2.MaterialThickness
						,'Report' AS CommandType
						,'O'        AS IsRollPress
						, ECI.PrintYn
						,'OneRoll'     AS ElectrodeRouteGroup
				  FROM STB_SetInfo SI
						  LEFT OUTER JOIN STB_MaterialMaster MM2	               ON SI.MaterialCode = MM2.MaterialCode
						  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	   ON SI.Barcode = ERPI.ElectrodeLotNumber
						  LEFT OUTER JOIN STB_MachineMaster MM	               ON ERPI.MachineCode = MM.MachineCode
						  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	               ON ERPI.WorkerCode = PWI.WorkerCode
						  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI           ON ECI.ElectrodeLotNumber = ERPI.ElectrodeLotNumber   AND ECI.ElectrodeLotNumber = SI.Barcode 
				 WHERE  1=1					
					AND NOT SI.Barcode IN ( SELECT ElectrodeLotNumber  FROM STB_ElectrodeSlittingInfo )
					AND ERPI.CreateDateTime BetWeen @FromDate AND @ToDate 
	) A
	LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		  ON BC.ItemCode = A.ElectrodeRouteGroup		 AND BC.CodeGroup = 'ElectrodeRouteGroup'
 WHERE 1=1
     AND A.CreateDateTime BETWEEN @FromDate AND @ToDate
	 --AND (@ElectrodeRouteGroup = '*' OR A.ElectrodeRouteGroup = @ElectrodeRouteGroup)	 	 
	 AND ISNULL(A.PrintYn, CONVERT(BIT, 0)) = @PrintYn
ORDER BY A.CreateDateTime, A.ElectrodeLotNumber, A.ElectrodeRouteGroup
	
		
END