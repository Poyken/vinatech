-- =============================================
-- Author: Kangs (yjyu@vina.co.kr)
-- Create date: 2020-09-30
-- Browsable : true
-- Group : PowerBI >  전극 메인정보
-- Description:	

-- [프로시저 실행]   usp_ElectrodeInfoPowerBI_get  '2020-10-14','2020-10-30'
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeInfoPowerBI_get]					
                        --@pCompanyCode VARCHAR(20) = NULL,  -- 사업장 코드 추가 (2020.10.15)
						@pFromDate Date,
						@pToDate Date
						
AS

BEGIN
	
	--DECLARE @ElectrodeLotNumber VARCHAR(20)
	DECLARE @RowCount INT
	DECLARE @FromDate DATE = @pFromDate
	DECLARE @ToDate   DATE = @pToDate
	--DECLARE @CompanyCode      VARCHAR(20) = CASE WHEN ISNULL(@pCompanyCode,'') = '' THEN '%' ELSE @pCompanyCode END

	IF @FromDate = '1900-01-01' OR @ToDate = '1900-01-01' BEGIN
		SET @FromDate = dbo.fnGetAggregationPeriod(1)
		SET @ToDate = dbo.fnGetAggregationPeriod(2)
	END

 BEGIN
		SELECT                
			     SDP.CompanyCode AS CompanyCode
		    -- 1. 믹싱정보	
		       , ISNULL(EM.ElectrodeLotNumber, SI.Barcode) as 전극Lot번호    --AS ElectrodeLotNumber
		        , SI.MaterialCode       as 품목코드             
				, MM2.MaterialName as 품목명
			--, (SELECT MM5.MaterialName FROM STB_MaterialMaster MM5 WHERE MM5.MaterialCode = SI.MaterialCode ) as 품목명
			,EM.MachineCode     as 믹싱_설비코드
			--,MM.MachineName  as 믹싱_설비명
			, (SELECT MM.MachineName FROM  STB_MachineMaster MM	WHERE MM.MachineCode = EM.MachineCode) as 믹싱_설비명

			,CONVERT(VARCHAR(10), EM.WorkDate, 121) as 믹싱_WorkDate
			,EM.WorkerCode  as 믹싱_작업자코드
			, (SELECT   PWI.WorkerName  FROM   STB_ProdWorkerInfo PWI WHERE PWI.WorkerCode = EM.WorkerCode) as 믹싱_작업자명
			
			--,PWI.WorkerName as 믹싱_작업자명
			,EM.Temperature  as 믹싱_온도
			,EM.Humidity    as 믹싱_습도
			,EM.ProductionQty   as 믹싱_생산량
			,EM.TankInsideTemp as 믹싱_탱크내부온도
			,EM.ViscosityValue  as 믹싱_점도측정값
			,EM.SpecificGravityValue as 믹싱_비중값				
			,EM.SpecificComment    as 믹싱_유의사항   
			,EM.CoolantTemperature AS 믹싱_냉각수온도   --CoolantTemperature                               -- 냉각수온도 추가 (안제헌, 2020.09.22)
			--,EM.MixingTemperature    
			--,EM.CreateDateTime       
			--,EM.CreateUserID         
			--,EM.ChangeDateTime       
			--,EM.ChangeUserID
				
			--,MM2.MaterialName
			--,MM2.MaterialThickness
			--,MM2.MaterialSource
			--,dbo.fnGetCalendarCode() AS SystemCalendarCode

			, EM.ViscosityResult as 믹싱_점도측정결과

	-- 2.코팅정보
				--, ISNULL(ECI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber			
			,ECI.MachineCode    as 코팅_설비코드

			, (SELECT MM.MachineName FROM  STB_MachineMaster MM	WHERE MM.MachineCode = ECI.MachineCode) as 코팅_설비명
			
			--,MM.MachineName  as 코팅_설비명
			,CONVERT(VARCHAR(10), ECI.WorkDate, 121) as 코팅_WorkDate

			,ECI.WorkerCode  as 코팅_작업자코드
			, (SELECT   PWI.WorkerName  FROM   STB_ProdWorkerInfo PWI WHERE PWI.WorkerCode = ECI.WorkerCode) as 코팅_작업자명

			,ECI.Temperature     as 코팅_온도
			,ECI.Humidity          as 코팅_습도
		--,ECI.ElectrodeMaterialCode as 코팅_
		--,ECI.MaterialLotNumber as 코팅_
			,ECI.OneSideHeadGapLeft as 코팅_단면HeadGap_좌
			,ECI.OneSideHeadGapRight as 코팅_단면HeadGap_우
			,ECI.BothSideHeadGapLeft as 코팅_양면HeadGap_좌
			,ECI.BothSideHeadGapRight as 코팅_양면HeadGap_우
			,ECI.OneSideCoatingWidth as 코팅폭_단면
			,ECI.BothSideCoatingWidth as 코팅폭_양면
			,ECI.UnwindingValue
			,ECI.RewindingValue
			,ECI.ProductionQty as 코팅_생산수
			,ECI.GoodQty as 코팅_양품수
			,ECI.BadQty as 코팅_불량수
			--,ECI.Remark  as 코팅_비고
			,ECI.SpecificComment1 as 코팅_특이사항1
			,ECI.SpecificComment2 as 코팅_특이사항2
			,ECI.CreateDateTime as 코팅_생성일자
			,ECI.CreateUserID as 코팅_생성자
			--,ECI.ChangeDateTime as 코팅_
			--,ECI.ChangeUserID as 코팅_
			--,SI.MaterialCode as 코팅_
			--,MM2.MaterialName as 코팅_
			,MM2.MaterialThickness as 코팅_원자재두께
			--, Case When Right(MM2.MaterialName, 3) = '(+)'  Then '에칭' 
			--         When Right(MM2.MaterialName, 3) = '(-)'  Then '화성'  Else '기타' End  as 코팅_    --AS ElectrodeDivision

			, ECI.CohesionResult as 코팅_결착력검사결과

	-- 3. 롤프레싱정보		

			,ERPI.MachineCode as 롤프레싱_설비코드
			, (SELECT MM.MachineName FROM  STB_MachineMaster MM	WHERE MM.MachineCode = ERPI.MachineCode) as 롤프레싱_설비명
			--,MM.MachineName as 롤프레싱_설비명
			,CONVERT(VARCHAR(10), ERPI.WorkDate, 121) as 롤프레싱_WorkDate
			,ERPI.WorkerCode as 롤프레싱_작업자코드
			, (SELECT   PWI.WorkerName  FROM   STB_ProdWorkerInfo PWI WHERE PWI.WorkerCode = ERPI.WorkerCode) as 롤프레싱_작업자명
			--,PWI.WorkerName as 롤프레싱_작업자명

			,ERPI.Temperature                as 롤프레싱_온도
			,ERPI.Humidity                    as 롤프레싱_습도
			,ERPI.RollingDensityValue     as 롤프레싱_압면밀도값
			,ERPI.RollingDensityResult  as 롤프레싱_압면밀도판정
			,ERPI.HeadGapInitLeft    as 롤프레싱_HeadGap초반설정지_좌
			,ERPI.HeadGapInitRight as 롤프레싱_HeadGap초반설정지_우
			,ERPI.ProdConTemp   as 롤프레싱_생산조건_온도
			,ERPI.ProdConSpeed as 롤프레싱_생산조건_속도
			,ERPI.ProductionQty as 롤프레싱_생산량
			,ERPI.GoodQty  as 롤프레싱_양품수
			,ERPI.BadQty  as 롤프레싱_불량수
			,ERPI.VisualInspectionResult as 롤프레싱_외관검사결과
			,ERPI.CreateDateTime as 롤프레싱_정보일자
			,ERPI.CreateUserID      as 롤프레싱_정보생성자
			--,ERPI.ChangeDateTime as 롤프레싱_
			--,ERPI.ChangeUserID  as 롤프레싱_
			--,SI.MaterialCode  as 롤프레싱_
			--,MM2.MaterialName   as 롤프레싱_
			,MM2.MaterialThickness    as 롤프레싱_원자재두께
			--,dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber) AS QcRollingDensityValue


		  FROM STB_SetInfo SI
				  LEFT OUTER JOIN STB_MaterialMaster MM2			ON SI.MaterialCode = MM2.MaterialCode
				  LEFT OUTER JOIN STB_ElectrodeMixInfo EM			ON SI.Barcode = EM.ElectrodeLotNumber           -- 1. 전극믹싱정보 
				  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI	          ON SI.Barcode = ECI.ElectrodeLotNumber  AND   EM.ElectrodeLotNumber =  ECI.ElectrodeLotNumber     -- 2. 전극코팅정보 
				  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	  ON SI.Barcode = ERPI.ElectrodeLotNumber  AND   EM.ElectrodeLotNumber =  ECI.ElectrodeLotNumber   -- 3. 전극롤프레싱정보
			   -- LEFT OUTER JOIN STB_MachineMaster MM	ON EM.MachineCode = MM.MachineCode  AND ECI.MachineCode = MM.MachineCode AND ERPI.MachineCode = MM.MachineCode				  				  
			   -- LEFT OUTER JOIN STB_ProdWorkerInfo PWI	ON ( EM.WorkerCode = PWI.WorkerCode    and   PWI.WorkerCode = ECI.WorkerCode                   and  PWI.WorkerCode = ERPI.WorkerCode )
			      LEFT OUTER JOIN STB_DayProdPlan SDP	    ON SDP.DayPlanNo = SI.DayPlanNo
		 WHERE 1=1
		     AND EM.WorkDate BETWEEN @FromDate And @ToDate
			 --AND  (select Distinct SDP.CompanyCode from STB_DayProdPlan  SDP where SDP.PONo  = SI.PONo Group By SDP.CompanyCode)  = 'VNT'
			 --  AND SI.Barcode = 'VJKS0420001E01'                             -- 주석부분임!!
		    -- AND ((@CompanyCode = '*') OR ( SDP.CompanyCode = @CompanyCode))

	END

END
