-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-24
-- Browsable : true
-- Group : 생산관리
-- Description:	전극롤프레싱정보
-- =============================================
Create PROCEDURE [dbo].[usp_ElectrodeRollPressingInfo_PowerBI_get]
	--@pProcessUserID VARCHAR(20),
	--@pProcessLanguage VARCHAR(20),
	--@pElectrodeLotNumber VARCHAR(20) = NULL
	 @pFromDate Date,
	   @pToDate Date


AS
BEGIN
	--DECLARE @ElectrodeLotNumber VARCHAR(20)
	--SET @ElectrodeLotNumber = @pElectrodeLotNumber

		DECLARE @FromDate DATE = CASE WHEN @pFromDate IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pFromDate END
	DECLARE @ToDate     DATE = CASE WHEN @pToDate    IS NULL THEN CONVERT(DATE, GETDATE()) ELSE @pToDate    END


	SELECT   ISNULL(ERPI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ERPI.MachineCode
			,MM.MachineName
			,ERPI.WorkDate
			,ERPI.WorkerCode 
			,PWI.WorkerName
			,ERPI.Temperature
			,ERPI.Humidity
			,ERPI.RollingDensityValue
			,ERPI.RollingDensityResult
			,ERPI.HeadGapInitLeft
			,ERPI.HeadGapInitRight
			,ERPI.ProdConTemp
			,ERPI.ProdConSpeed
			,ERPI.ProductionQty
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
			,'O' AS IsRollPress
			--,dbo.fnGetElectrodeDensityAvg(@ElectrodeLotNumber) AS QcRollingDensityValue
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM2	                 ON SI.MaterialCode = MM2.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI	    ON SI.Barcode = ERPI.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM	    ON ERPI.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN STB_ProdWorkerInfo PWI	    ON ERPI.WorkerCode = PWI.WorkerCode
	 WHERE 1=1
	 --and SI.Barcode = @ElectrodeLotNumber
	  AND CONVERT(DATE, ERPI.CreateDateTime)      BETWEEN @FromDate And @ToDate
		  		


END