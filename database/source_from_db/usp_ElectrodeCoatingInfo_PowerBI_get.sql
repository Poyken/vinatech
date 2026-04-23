-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리 >
--            품질관리 > 
-- Description:

-- usp_ElectrodeCoatingInfo_PowerBI_get '2020-09-01','2020-09-30' 
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeCoatingInfo_PowerBI_get]						
						--@pElectrodeLotNumber VARCHAR(20) = NULL
							@pFromDate Date,
							@pToDate Date


AS

BEGIN
	--DECLARE @ElectrodeLotNumber VARCHAR(20) SET @ElectrodeLotNumber = @pElectrodeLotNumber
	DECLARE @FromDate DATE = CASE WHEN @pFromDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pFromDate END
	DECLARE @ToDate     DATE = CASE WHEN @pToDate    IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pToDate    END
	

	SELECT   ISNULL(ECI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ECI.MachineCode
			,MM.MachineName
			,ECI.WorkDate
			,ECI.WorkerCode 
			,PWI.WorkerName
			,ECI.Temperature
			,ECI.Humidity
			,ECI.ElectrodeMaterialCode
			,ECI.MaterialLotNumber
			,ECI.OneSideHeadGapLeft
			,ECI.OneSideHeadGapRight
			,ECI.BothSideHeadGapLeft
			,ECI.BothSideHeadGapRight
			,ECI.OneSideCoatingWidth
			,ECI.BothSideCoatingWidth
			,ECI.UnwindingValue
			,ECI.RewindingValue
			,ECI.ProductionQty
			,ECI.GoodQty
			,ECI.BadQty
			,ECI.Remark
			,ECI.SpecificComment1
			,ECI.SpecificComment2
			,ECI.CreateDateTime
			,ECI.CreateUserID
			,ECI.ChangeDateTime
			,ECI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
			,'Report' AS CommandType
			,'X'        AS IsRollPress				
			, Case When Right(MM2.MaterialName, 3) = '(+)'  Then '에칭' 
			         When Right(MM2.MaterialName, 3) = '(-)'  Then '화성'  Else '기타' End  AS ElectrodeDivision       -- 에칭/화성구분 (kilee추가-구형규요청, 2020-08-13)           

	  FROM STB_SetInfo SI
			  LEFT OUTER JOIN STB_MaterialMaster MM2	      ON SI.MaterialCode = MM2.MaterialCode
			  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI	  ON SI.Barcode = ECI.ElectrodeLotNumber
			  LEFT OUTER JOIN STB_MachineMaster MM	      ON ECI.MachineCode = MM.MachineCode
			  LEFT OUTER JOIN STB_ProdWorkerInfo PWI	      ON ECI.WorkerCode = PWI.WorkerCode
	 WHERE 1=1
	     --AND SI.Barcode = @ElectrodeLotNumber
		 AND CONVERT(DATE, ECI.WorkDate)      BETWEEN @FromDate And @ToDate
		  		
END


--select SIExtText01, SIExtText02, SIExtText03, SIExtText04, SIExtText05, SIExtText06, SIExtText07
--      ,  *
--from STB_SetInfo
--where 1=1
--and SIExtText04 is not null