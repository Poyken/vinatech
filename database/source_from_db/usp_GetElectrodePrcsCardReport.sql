-- =============================================
-- Author: Jackaroe (yjyu@vina.co.kr)
-- Create date: 2019-01-31
-- Browsable : true
-- Group : 생산관리
-- Description:	전극공정카드(레포트)
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_GetElectrodePrcsCardReport]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
	@pElectrodeLotNumber VARCHAR(20)

AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @ElectrodeLotNumber VARCHAR(20) = @pElectrodeLotNumber
	DECLARE @ProdCode VARCHAR(20) 

	SELECT @ProdCode = MaterialCode
	  FROM STB_SetInfo
	 WHERE Barcode = @ElectrodeLotNumber

	-- 전극공통정보
	SELECT
			 EC.ProdCode
			,MM.MaterialName AS ProdName
			,EC.LivingSubstance
			,EC.MixRatio
			,EC.TankVolume
			,EC.ElectrodeType
			,EC.MeasureViscosity
			,EC.Remark
			,EC.OneSide
			,EC.OneSideLowerTolerance
			,EC.OneSideUpperTolerance
			,EC.BothSide
			,EC.BothSideLowerTolerance
			,EC.BothSideUpperTolerance
			,EC.RollingDensityMin
			,EC.RollingDensityMax
			,EC.ViscosityMin
			,EC.ViscosityMax
			,EC.UnwndngStdMin
			,EC.UnwndngStdMax
			,EC.UnwndngMeasureValue
			,EC.RwndngStdMin
			,EC.RwndngStdMax
			,EC.RwndngMeasureValue
			,EC.ProdConLinePressure
			,EC.ProdConTemp
			,EC.ProdConTempLowerTolerance
			,EC.ProdConTempUpperTolerance
			,EC.ProdConSpeed
			,EC.ProdConSpeedLowerTolerance
			,EC.ProdConSpeedUpperTolerance
			,EC.ProdConThickStdMin
			,EC.ProdConThickStdMax
			,EC.CoolingWaterStdMin
			,EC.CoolingWaterStdMax
			,EC.LeftHeadGap
			,EC.RightHeadGap
			,EC.AlFoilWidth
			,EC.CoatingWidth
			,EC.OneSideSpeed
			,EC.BothSideSpeed
			,EC.CreateDateTime
			,EC.CreateUserID
			,EC.ChangeDateTime
			,EC.ChangeUserID
			,SI.LotUniqueNumber
			,MM.MaterialThickness
			,VUI.UserName
			,SI.Barcode
	FROM	STB_SetInfo SI
		   ,STB_ElectrodeCommon EC
		   ,STB_MaterialMaster MM
		   ,VW_UserInfo VUI
   WHERE SI.MaterialCode = EC.ProdCode
     AND EC.ProdCode = MM.MaterialCode
     AND SI.Barcode = @ElectrodeLotNumber
	 AND SI.CreateUserID = VUI.UserID

	-- 전극믹싱정보 마스터
	SELECT 	 ISNULL(EM.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,EM.MachineCode
			,MM.MachineName
			,EM.WorkDate
			,EM.WorkerCode 
			,PWI.WorkerName
			,EM.Temperature 
			,EM.Humidity    
			,EM.ProductionQty  
			,EM.TankInsideTemp 
			,EM.ViscosityValue 
			,EM.SpecificGravityValue 
			,EM.MixingTemperature    
			,EM.SpecificComment      
			,EM.CreateDateTime       
			,EM.CreateUserID         
			,EM.ChangeDateTime       
			,EM.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness        
		FROM STB_SetInfo SI
		LEFT OUTER JOIN STB_MaterialMaster MM2
		ON SI.MaterialCode = MM2.MaterialCode
		LEFT OUTER JOIN STB_ElectrodeMixInfo EM
		ON SI.Barcode = EM.ElectrodeLotNumber
		LEFT OUTER JOIN STB_MachineMaster MM
		ON EM.MachineCode = MM.MachineCode
		LEFT OUTER JOIN STB_ProdWorkerInfo PWI
		ON EM.WorkerCode = PWI.WorkerCode
		WHERE SI.Barcode = @ElectrodeLotNumber

	-- 전극 믹싱레시피 및 투입정보
	SELECT 	 ISNULL(EMSI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(EMSI.ElectrodeStep, ES.ElectrodeStepCode) AS ElectrodeStep
			,ISNULL(EMSI.Seq, ES.Seq) AS Seq
			,ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode) AS ElectrodeMaterialCode
			,MM.MaterialName AS ElectrodeMaterialName
			,EMSI.InputQty1
			,EMSI.InputQty2
			,EMSI.MaterialLotNumber
			,EMSI.BinderInputTime
			,EMSI.BinderOutputTime
			,EMSI.MixingInputTime
			,EMSI.MixingOutputTime
			,EMSI.SpecInOut
			,EMSI.SpecOutQty
			,EMSI.CreateDateTime
			,EMSI.CreateUserID
			,EMSI.ChangeDateTime
			,EMSI.ChangeUserID
	  FROM STB_ElectrodeStep ES 
	 INNER JOIN STB_SetInfo SI
	    ON ES.ProdCode = SI.MaterialCode
     LEFT OUTER JOIN STB_ElectrodeMixStepInfo EMSI
	    ON SI.Barcode = EMSI.ElectrodeLotNumber
	   AND EMSI.ElectrodeStep = ES.ElectrodeStepCode
	   AND EMSI.Seq = ES.Seq
	 LEFT OUTER JOIN STB_MaterialMaster MM
	   ON MM.MaterialCode = ISNULL(EMSI.ElectrodeMaterialCode, ES.MaterialCode)
	 WHERE SI.Barcode = @ElectrodeLotNumber
	 ORDER BY CASE WHEN ES.ElectrodeStepCode = 'D'  THEN 1
	               WHEN ES.ElectrodeStepCode = 'G'  THEN 2
				   WHEN ES.ElectrodeStepCode = 'K'  THEN 3
				   WHEN ES.ElectrodeStepCode = 'S'  THEN 4
				   WHEN ES.ElectrodeStepCode = 'DA' THEN 5
				   ELSE ES.ElectrodeStepCode END
			,ES.Seq

	-- 전극코딩정보 마스터
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
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM2
	    ON SI.MaterialCode = MM2.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeCoatingInfo ECI
	    ON SI.Barcode = ECI.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON ECI.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON ECI.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber

	 -- 전극코딩정보 건조로 정보
	 SELECT
			EO.ProdCode
		   ,EO.Seq
		   ,EO.DryingFurnaceName
		   ,CONVERT(NUMERIC(20, 1), EO.DryingFurnaceTemp) AS DryingFurnaceTemp
		   ,CONVERT(NUMERIC(20, 1), EO.DryingFurnaceAirUpperPart) AS DryingFurnaceAirUpperPart
		   ,CONVERT(NUMERIC(20, 1), EO.DryingFurnaceAirLowerPart) AS DryingFurnaceAirLowerPart
		   ,CONVERT(NUMERIC(20, 1), EO.TempLowerTolerance) AS TempLowerTolerance
		   ,CONVERT(NUMERIC(20, 1), EO.TempUpperTolerance) AS TempUpperTolerance
		   ,CONVERT(NUMERIC(20, 1), EO.AirLowerTolerance) AS AirLowerTolerance
		   ,CONVERT(NUMERIC(20, 1), EO.AirUpperTolerance) AS AirUpperTolerance
		   ,EO.CreateDateTime
		   ,EO.CreateUserID
		   ,EO.ChangeDateTime
		   ,EO.ChangeUserID
	FROM
			STB_ElectrodeOven EO
   WHERE EO.ProdCode = @ProdCode
   ORDER BY Seq

   -- 전극코팅외관검사정보
	;WITH DefaultList AS (
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'O' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'FIRST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'MIDDLE' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 1 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 2 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
		UNION ALL
		SELECT 'B' AS SideCode, 'LAST' AS MeasureTimeCode, 3 AS Seq, NULL AS LeftValue, NULL AS MiddleValue, NULL AS RightValue
	)
	SELECT   ISNULL(ECVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ECVII.SideCode, DL.SideCode) AS SideCode
			,BC2.Description AS SideCodeName
			,ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ECVII.Seq, DL.Seq) AS Seq
			,ECVII.LeftValue
			,ECVII.MiddleValue
			,ECVII.RightValue
			,ECVII.CreateDateTime
			,ECVII.CreateUserID
			,ECVII.ChangeDateTime
			,ECVII.ChangeUserID
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL
	    ON 1=1
	  LEFT OUTER JOIN STB_ElectrodeCoatingVisualInspectionInfo ECVII
	    ON SI.Barcode = ECVII.ElectrodeLotNumber
	   AND DL.SideCode = ECVII.SideCode
	   AND DL.MeasureTimeCode = ECVII.MeasureTimeCode
	   AND DL.Seq = ECVII.Seq
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.CodeGroup = 'MeasureTime'
	   AND ISNULL(ECVII.MeasureTimeCode, DL.MeasureTimeCode) = BC.ItemCode
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC2
	    ON ISNULL(ECVII.SideCode, DL.SideCode) = BC2.ItemCode
	   AND BC2.CodeGroup = 'SideCode'
	 WHERE SI.Barcode = @ElectrodeLotNumber
	 ORDER BY CASE WHEN DL.SideCode = 'O' THEN 1
	               WHEN DL.SideCode = 'B' THEN 2
				   ELSE DL.SideCode END
		     ,CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
			       WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3
				   ELSE 4 END
		     ,DL.Seq

	-- 전극롤프레싱정보 마스터
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
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM2
	    ON SI.MaterialCode = MM2.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeRollPressingInfo ERPI
	    ON SI.Barcode = ERPI.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON ERPI.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON ERPI.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber

	 -- 전극 롤프레싱 측정정보
	 ;WITH DefaultList AS (
		SELECT 'FIRST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'FIRST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'FIRST' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'MIDDLE' AS MeasureTimeCode, 3 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 1 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 2 AS Seq UNION ALL
		SELECT 'LAST' AS MeasureTimeCode, 3 AS Seq
	)
	SELECT   ISNULL(ERPVII.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ISNULL(ERPVII.MeasureTimeCode, DL.MeasureTimeCode) AS MeasureTimeCode
			,BC.Description AS MeasureTimeCodeName
			,ISNULL(ERPVII.Seq, DL.Seq) AS Seq
			,ERPVII.LeftValue
			,ERPVII.MiddleValue
			,ERPVII.RightValue
			,ERPVII.CreateDateTime
			,ERPVII.CreateUserID
			,ERPVII.ChangeDateTime
			,ERPVII.ChangeUserID
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN DefaultList DL
	    ON 1 = 1
	  LEFT OUTER JOIN STB_ElectrodeRollPressingVisualInspectionInfo ERPVII
	    ON SI.Barcode = ERPVII.ElectrodeLotNumber
	   AND DL.MeasureTimeCode = ERPVII.MeasureTimeCode
	   AND DL.Seq = ERPVII.Seq
	  LEFT OUTER JOIN SmartFramework.dbo.STB_BaseCode BC
	    ON BC.ItemCode = DL.MeasureTimeCode
	 WHERE SI.Barcode = @ElectrodeLotNumber
	 ORDER BY CASE WHEN DL.MeasureTimeCode = 'FIRST' THEN 1
	               WHEN DL.MeasureTimeCode = 'MIDDLE' THEN 2
				   WHEN DL.MeasureTimeCode = 'LAST' THEN 3
				   ELSE 4 END
		     ,DL.Seq

	-- 슬리팅정보 마스터
	SELECT   ISNULL(ESI.ElectrodeLotNumber, SI.Barcode) AS ElectrodeLotNumber
			,ESI.MachineCode
			,MM.MachineName
			,ESI.WorkDate
			,ESI.WorkerCode 
			,PWI.WorkerName
			,ESI.Temperature
			,ESI.Humidity
			,ESI.PushingYn
			,ESI.VisualInspectionResult
			,ESI.SlittingLength
			,ESI.Remark
			,ESI.CreateDateTime
			,ESI.CreateUserID
			,ESI.ChangeDateTime
			,ESI.ChangeUserID
			,SI.MaterialCode
			,MM2.MaterialName
			,MM2.MaterialThickness
	  FROM STB_SetInfo SI
	  LEFT OUTER JOIN STB_MaterialMaster MM2
	    ON SI.MaterialCode = MM2.MaterialCode
	  LEFT OUTER JOIN STB_ElectrodeSlittingInfo ESI
	    ON SI.Barcode = ESI.ElectrodeLotNumber
	  LEFT OUTER JOIN STB_MachineMaster MM
	    ON ESI.MachineCode = MM.MachineCode
	   LEFT OUTER JOIN STB_ProdWorkerInfo PWI
	    ON ESI.WorkerCode = PWI.WorkerCode
	 WHERE SI.Barcode = @ElectrodeLotNumber

	 -- 전극슬리팅정보 슬리팅결과
	 SELECT  ESR.ElectrodeLotNumber
			,ESR.Seq
			,ESR.ElectrodeThick
			,ESR.SlittingWidth
			,ESR.ProductionQty
			,ESR.GoodQtyLength
			,ESR.CreateDateTime
			,ESR.CreateUserID
			,ESR.ChangeDateTime
			,ESR.ChangeUserID
	  FROM STB_ElectrodeSlittingResult ESR
	 WHERE ESR.ElectrodeLotNumber = @ElectrodeLotNumber
	 ORDER BY Seq

END

