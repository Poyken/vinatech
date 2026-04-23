CREATE PROC usp_DoAddEletrodeCommonInfo
	@pOriginalBarcode VARCHAR(20)
   ,@pTargetBarcode VARCHAR(20)
AS
BEGIN
	INSERT INTO STB_ElectrodeCommon
	SELECT @pTargetBarcode
		  ,LivingSubstance
		  ,MixRatio
		  ,TankVolume
		  ,ElectrodeType
		  ,MeasureViscosity
		  ,Remark
		  ,OneSide
		  ,BothSide
		  ,RollingDensityMin
		  ,RollingDensityMax
		  ,ViscosityMin
		  ,ViscosityMax
		  ,UnwndngStdMin
		  ,UnwndngStdMax
		  ,UnwndngMeasureValue
		  ,RwndngStdMin
		  ,RwndngStdMax
		  ,RwndngMeasureValue
		  ,ProdConLinePressure
		  ,ProdConTemp
		  ,ProdConSpeed
		  ,ProdConThickStdMin
		  ,ProdConThickStdMax
		  ,CoolingWaterStdMin
		  ,CoolingWaterStdMax
		  ,LeftHeadGap
		  ,RightHeadGap
		  ,AlFoilWidth
		  ,CoatingWidth
		  ,OneSideSpeed
		  ,BothSideSpeed
		  ,GETDATE()
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
		  ,OneSideUpperTolerance
		  ,OneSideLowerTolerance
		  ,BothSideUpperTolerance
		  ,BothSideLowerTolerance
		  ,ProdConTempUpperTolerance
		  ,ProdConTempLowerTolerance
		  ,ProdConSpeedUpperTolerance
		  ,ProdConSpeedLowerTolerance
	  FROM STB_ElectrodeCommon
	 WHERE ProdCode = @pOriginalBarcode

	-- ElectrodeStep
	INSERT INTO STB_ElectrodeStep
	SELECT @pTargetBarcode
		  ,seq
		  ,ElectrodeStepCode
		  ,MaterialCode
		  ,StdMinVal
		  ,StdMaxVal
		  ,WorkTime
		  ,HighSpeedSpin
		  ,LowSpeedSpin
		  ,Remark
		  ,CreateDateTime
		  ,CreateUserID
		  ,ChangeDateTime
		  ,ChangeUserID
	  FROM STB_ElectrodeStep
	 WHERE ProdCode = @pOriginalBarcode

	--Oven 정보
	INSERT INTO STB_ElectrodeOven
	SELECT @pTargetBarcode
		  ,Seq
		  ,DryingFurnaceName
		  ,DryingFurnaceTemp
		  ,DryingFurnaceAirUpperPart
		  ,DryingFurnaceAirLowerPart
		  ,GETDATE()
		  ,'yjyu'
		  ,NULL
		  ,NULL
		  ,TempUpperTolerance
		  ,TempLowerTolerance
		  ,AirUpperTolerance
		  ,AirLowerTolerance
	  FROM STB_ElectrodeOven
	 WHERE ProdCode = @pOriginalBarcode
END