-- =============================================
-- Author: kilee@vina.co.kr
-- Create date: 2020-05-08
-- Browsable : true
-- Group : 생산관리 > [B799] 전극재고현황 > 슬리팅재고
-- Description:	
-- Modified:

-- usp_ElectrodeInventoryInquirySlitting_get 'klee', 'Korean', 'VNT', '2020-05-01', '2020-05-15'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeInventoryInquirySlitting_get]
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
			 --  , @ElectrodeRouteGroup  VARCHAR(20) = CASE WHEN ISNULL(@pElectrodeRouteGroup, '') = '' THEN '*' ELSE @pElectrodeRouteGroup END
			    , @PrintYn                  BIT = CASE WHEN @pCompanyCode = 'VVT' THEN CONVERT(BIT, 1)   ELSE  CONVERT(BIT, 0) END


		
			-- [슬리팅 실적 체크]

   SELECT A.ElectrodeLotNumber
			, A.ElectrodeType
		    ,A.MachineCode
			,A.MachineName
			,A.WorkDate
			,A.WorkerCode 
			,A.WorkerName
			,A.Temperature
			,A.Humidity			
			,A.SlittingLength
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
			 SELECT  ISNULL(ESI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
				       , Case When MM2.MaterialName like '%MSP%' Then 'MSP'
						        When MM2.MaterialName like '%YP%' Then 'YP'
						        When MM2.MaterialName like '%CEP%' Then 'CEP'
								When MM2.MaterialName like '%LMO%' Then 'LMO' ELSE '기타' END  ElectrodeType						
						,ESI.MachineCode
						,MM.MachineName
						,ESI.WorkDate
						,ESI.WorkerCode 
						,PWI.WorkerName
						,ESI.Temperature
						,ESI.Humidity						
						, ESI.SlittingLength    AS SlittingLength    						
						,ESI.VisualInspectionResult
						,ESI.CreateDateTime
						,ESI.CreateUserID
						,ESI.ChangeDateTime
						,ESI.ChangeUserID
						,SI.MaterialCode
						,MM2.MaterialName
						,MM2.MaterialThickness
						,'Report' AS CommandType
						,'O' AS IsRollPress
						, ECI.PrintYn AS PrintYn
						,'SlittingRoll'     AS ElectrodeRouteGroup
				  FROM STB_SetInfo SI
						  LEFT OUTER JOIN STB_MaterialMaster MM2	       ON SI.MaterialCode = MM2.MaterialCode
						  LEFT OUTER JOIN STB_ElectrodeSlittingInfo ESI	   ON SI.Barcode = ESI.ElectrodeLotNumber
						  LEFT OUTER JOIN STB_MachineMaster MM	       ON ESI.MachineCode = MM.MachineCode
						  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	       ON ESI.WorkerCode = PWI.WorkerCode
						  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI   ON ECI.ElectrodeLotNumber = ESI.ElectrodeLotNumber   AND ECI.ElectrodeLotNumber = SI.Barcode 

				 WHERE 1=1					
					AND ESI.CreateDateTime BetWeen  @FromDate AND @ToDate 
					--AND ESI.PrintYn <> '1'                                                                                             -- 프린트 출력이 안된제품 (출력하면 법인으로 이동) 

			) A
	LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC		  ON BC.ItemCode = A.ElectrodeRouteGroup		 AND BC.CodeGroup = 'ElectrodeRouteGroup'
 WHERE 1=1
     AND A.CreateDateTime BETWEEN @FromDate AND @ToDate
	 --AND (@ElectrodeRouteGroup = '*' OR A.ElectrodeRouteGroup = @ElectrodeRouteGroup)	 	 
	 AND ISNULL(A.PrintYn, CONVERT(BIT, 0)) = @PrintYn
ORDER BY A.CreateDateTime, A.ElectrodeLotNumber, A.ElectrodeRouteGroup

  
END
