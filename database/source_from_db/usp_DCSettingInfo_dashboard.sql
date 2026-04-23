CREATE PROC [dbo].[usp_DCSettingInfo_dashboard]
	@pProcessLanguage VARCHAR(20)
AS
BEGIN
	SELECT TOP 1
		   DSI.DCSettingSerialNo
          ,DSI.LotNo
          ,DSI.Barcode
          ,DSI.MachineID
          ,DSI.OperationSpeedSV	, dbo.fnGetStringResource(@pProcessLanguage, 'OperationSpeedSV') AS OperationSpeedSVName
          ,DSI.AccelerationTimeSV	, dbo.fnGetStringResource(@pProcessLanguage, 'AccelerationTimeSV') AS AccelerationTimeSVName
          ,DSI.DecelerationTimeSV	, dbo.fnGetStringResource(@pProcessLanguage, 'DecelerationTimeSV') AS DecelerationTimeSVName
          ,DSI.StopTimeSV	, dbo.fnGetStringResource(@pProcessLanguage, 'StopTimeSV') AS StopTimeSVName
          ,DSI.MainSectionInverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'MainSectionInverterSV') AS MainSectionInverterSVName
          ,DSI.Dryer1BlowerInverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1BlowerInverterSV') AS Dryer1BlowerInverterSVName
          ,DSI.Dryer2BlowerInverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2BlowerInverterSV') AS Dryer2BlowerInverterSVName
          ,DSI.XrfBlowerInverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfBlowerInverterSV') AS XrfBlowerInverterSVName
          ,DSI.TurnbarLeftBlowerInverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'TurnbarLeftBlowerInverterSV') AS TurnbarLeftBlowerInverterSVName
          ,DSI.TurnbarRightBlowerInverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'TurnbarRightBlowerInverterSV') AS TurnbarRightBlowerInverterSVName
          ,DSI.DustCollector1InverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'DustCollector1InverterSV') AS DustCollector1InverterSVName
          ,DSI.DustCollector2InverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'DustCollector2InverterSV') AS DustCollector2InverterSVName
          ,DSI.DustCollector3InverterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'DustCollector3InverterSV') AS DustCollector3InverterSVName
          ,DSI.JumboConverterPresureSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'JumboConverterPresureSetupSV') AS JumboConverterPresureSetupSVName
          ,DSI.JumboConverterTiltSetupPresureDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'JumboConverterTiltSetupPresureDisplaySV') AS JumboConverterTiltSetupPresureDisplaySVName
          ,DSI.WindingProductThicknessSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'WindingProductThicknessSetupSV') AS WindingProductThicknessSetupSVName
          ,DSI.NwfUwTensionSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUwTensionSetupSV') AS NwfUwTensionSetupSVName
          ,DSI.UwTensionSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'UwTensionSetupSV') AS UwTensionSetupSVName
          ,DSI.PfUwTensionSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUwTensionSetupSV') AS PfUwTensionSetupSVName
          ,DSI.PfRwTensionSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRwTensionSetupSV') AS PfRwTensionSetupSVName
          ,DSI.NwfRwTensionSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRwTensionSetupSV') AS NwfRwTensionSetupSVName
          ,DSI.OutfeedTensionSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'OutfeedTensionSetupSV') AS OutfeedTensionSetupSVName
          ,DSI.RewinderTensionSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderTensionSetupSV') AS RewinderTensionSetupSVName
          ,DSI.RewinderTensionTiltTargetTensionDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderTensionTiltTargetTensionDisplaySV') AS RewinderTensionTiltTargetTensionDisplaySVName
          ,DSI.DryerServoSpeedRateSV	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerServoSpeedRateSV') AS DryerServoSpeedRateSVName
          ,DSI.XrfServoSpeedRateSV	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfServoSpeedRateSV') AS XrfServoSpeedRateSVName
          ,DSI.OutfeedSpeedRateSV	, dbo.fnGetStringResource(@pProcessLanguage, 'OutfeedSpeedRateSV') AS OutfeedSpeedRateSVName
          ,DSI.EpcPatternDetectStartPositionSV	, dbo.fnGetStringResource(@pProcessLanguage, 'EpcPatternDetectStartPositionSV') AS EpcPatternDetectStartPositionSVName
          ,DSI.EpcPatternDetectEndPositionSV	, dbo.fnGetStringResource(@pProcessLanguage, 'EpcPatternDetectEndPositionSV') AS EpcPatternDetectEndPositionSVName
          ,DSI.JumborollPresureSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'JumborollPresureSetupSV') AS JumborollPresureSetupSVName
          ,DSI.ArchChamberExhaustSV	, dbo.fnGetStringResource(@pProcessLanguage, 'ArchChamberExhaustSV') AS ArchChamberExhaustSVName
          ,DSI.Dryer1ExhaustSV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1ExhaustSV') AS Dryer1ExhaustSVName
          ,DSI.Dryer2ExhaustSV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2ExhaustSV') AS Dryer2ExhaustSVName
          ,DSI.ArchChamberSupplySV	, dbo.fnGetStringResource(@pProcessLanguage, 'ArchChamberSupplySV') AS ArchChamberSupplySVName
          ,DSI.Dryer1SupplySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1SupplySV') AS Dryer1SupplySVName
          ,DSI.Dryer2SupplySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2SupplySV') AS Dryer2SupplySVName
          ,DSI.Dryer3SupplySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer3SupplySV') AS Dryer3SupplySVName
          ,DSI.Dryer4SupplySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer4SupplySV') AS Dryer4SupplySVName
          ,DSI.DryerArchChamberHeaterSetupDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerArchChamberHeaterSetupDisplaySV') AS DryerArchChamberHeaterSetupDisplaySVName
          ,DSI.DryerArchChamberHeaterDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerArchChamberHeaterDisplaySV') AS DryerArchChamberHeaterDisplaySVName
          ,DSI.Dryer1HeaterSetupDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1HeaterSetupDisplaySV') AS Dryer1HeaterSetupDisplaySVName
          ,DSI.Dryer1HeaterDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1HeaterDisplaySV') AS Dryer1HeaterDisplaySVName
          ,DSI.Dryer2HeaterSetupDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2HeaterSetupDisplaySV') AS Dryer2HeaterSetupDisplaySVName
          ,DSI.Dryer2HeaterDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2HeaterDisplaySV') AS Dryer2HeaterDisplaySVName
          ,DSI.Dryer3HeaterSetupDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer3HeaterSetupDisplaySV') AS Dryer3HeaterSetupDisplaySVName
          ,DSI.Dryer3HeaterDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer3HeaterDisplaySV') AS Dryer3HeaterDisplaySVName
          ,DSI.Dryer4HeaterSetupDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer4HeaterSetupDisplaySV') AS Dryer4HeaterSetupDisplaySVName
          ,DSI.Dryer4HeaterDisplaySV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer4HeaterDisplaySV') AS Dryer4HeaterDisplaySVName
          ,DSI.VisionChronicDefectsEquipStopSV	, dbo.fnGetStringResource(@pProcessLanguage, 'VisionChronicDefectsEquipStopSV') AS VisionChronicDefectsEquipStopSVName
          ,DSI.XrfChronicDefectsEquipStopSV	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfChronicDefectsEquipStopSV') AS XrfChronicDefectsEquipStopSVName
          ,DSI.NwfUnwinderFabricDiameterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUnwinderFabricDiameterSV') AS NwfUnwinderFabricDiameterSVName
          ,DSI.UnwinderFabricDiameterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'UnwinderFabricDiameterSV') AS UnwinderFabricDiameterSVName
          ,DSI.PfUnwinderFabricDiameterSV	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUnwinderFabricDiameterSV') AS PfUnwinderFabricDiameterSVName
          ,DSI.PeristalticPumpLevelSensorSV	, dbo.fnGetStringResource(@pProcessLanguage, 'PeristalticPumpLevelSensorSV') AS PeristalticPumpLevelSensorSVName
          ,DSI.RecipeSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'RecipeSetupSV') AS RecipeSetupSVName
          ,DSI.RecipeStringSetupSV	, dbo.fnGetStringResource(@pProcessLanguage, 'RecipeStringSetupSV') AS RecipeStringSetupSVName
          ,DSI.RecipeStringSV	, dbo.fnGetStringResource(@pProcessLanguage, 'RecipeStringSV') AS RecipeStringSVName
          ,DSI.OperationSpeedPV	, dbo.fnGetStringResource(@pProcessLanguage, 'OperationSpeedPV') AS OperationSpeedPVName
          ,DSI.AccelerationTimePV	, dbo.fnGetStringResource(@pProcessLanguage, 'AccelerationTimePV') AS AccelerationTimePVName
          ,DSI.DecelerationTimePV	, dbo.fnGetStringResource(@pProcessLanguage, 'DecelerationTimePV') AS DecelerationTimePVName
          ,DSI.StopTimePV	, dbo.fnGetStringResource(@pProcessLanguage, 'StopTimePV') AS StopTimePVName
          ,DSI.MainSectionInverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'MainSectionInverterPV') AS MainSectionInverterPVName
          ,DSI.Dryer1BlowerInverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1BlowerInverterPV') AS Dryer1BlowerInverterPVName
          ,DSI.Dryer2BlowerInverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2BlowerInverterPV') AS Dryer2BlowerInverterPVName
          ,DSI.XrfBlowerInverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfBlowerInverterPV') AS XrfBlowerInverterPVName
          ,DSI.TurnbarLeftBlowerInverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'TurnbarLeftBlowerInverterPV') AS TurnbarLeftBlowerInverterPVName
          ,DSI.TurnbarRightBlowerInverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'TurnbarRightBlowerInverterPV') AS TurnbarRightBlowerInverterPVName
          ,DSI.DustCollector1InverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'DustCollector1InverterPV') AS DustCollector1InverterPVName
          ,DSI.DustCollector2InverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'DustCollector2InverterPV') AS DustCollector2InverterPVName
          ,DSI.DustCollector3InverterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'DustCollector3InverterPV') AS DustCollector3InverterPVName
          ,DSI.JumboConverterPresureSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'JumboConverterPresureSetupPV') AS JumboConverterPresureSetupPVName
          ,DSI.JumboConverterTiltSetupPresureDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'JumboConverterTiltSetupPresureDisplayPV') AS JumboConverterTiltSetupPresureDisplayPVName
          ,DSI.WindingProductThicknessSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'WindingProductThicknessSetupPV') AS WindingProductThicknessSetupPVName
          ,DSI.NwfUwTensionSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUwTensionSetupPV') AS NwfUwTensionSetupPVName
          ,DSI.UwTensionSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'UwTensionSetupPV') AS UwTensionSetupPVName
          ,DSI.PfUwTensionSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUwTensionSetupPV') AS PfUwTensionSetupPVName
          ,DSI.PfRwTensionSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRwTensionSetupPV') AS PfRwTensionSetupPVName
          ,DSI.NwfRwTensionSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRwTensionSetupPV') AS NwfRwTensionSetupPVName
          ,DSI.OutfeedTensionSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'OutfeedTensionSetupPV') AS OutfeedTensionSetupPVName
          ,DSI.RewinderTensionSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderTensionSetupPV') AS RewinderTensionSetupPVName
          ,DSI.RewinderTensionTiltTargetTensionDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderTensionTiltTargetTensionDisplayPV') AS RewinderTensionTiltTargetTensionDisplayPVName
          ,DSI.DryerServoSpeedRatePV	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerServoSpeedRatePV') AS DryerServoSpeedRatePVName
          ,DSI.XrfServoSpeedRatePV	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfServoSpeedRatePV') AS XrfServoSpeedRatePVName
          ,DSI.OutfeedSpeedRatePV	, dbo.fnGetStringResource(@pProcessLanguage, 'OutfeedSpeedRatePV') AS OutfeedSpeedRatePVName
          ,DSI.EpcPatternDetectStartPositionPV	, dbo.fnGetStringResource(@pProcessLanguage, 'EpcPatternDetectStartPositionPV') AS EpcPatternDetectStartPositionPVName
          ,DSI.EpcPatternDetectEndPositionPV	, dbo.fnGetStringResource(@pProcessLanguage, 'EpcPatternDetectEndPositionPV') AS EpcPatternDetectEndPositionPVName
          ,DSI.JumborollPresureSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'JumborollPresureSetupPV') AS JumborollPresureSetupPVName
          ,DSI.ArchChamberExhaustPV	, dbo.fnGetStringResource(@pProcessLanguage, 'ArchChamberExhaustPV') AS ArchChamberExhaustPVName
          ,DSI.Dryer1ExhaustPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1ExhaustPV') AS Dryer1ExhaustPVName
          ,DSI.Dryer2ExhaustPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2ExhaustPV') AS Dryer2ExhaustPVName
          ,DSI.ArchChamberSupplyPV	, dbo.fnGetStringResource(@pProcessLanguage, 'ArchChamberSupplyPV') AS ArchChamberSupplyPVName
          ,DSI.Dryer1SupplyPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1SupplyPV') AS Dryer1SupplyPVName
          ,DSI.Dryer2SupplyPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2SupplyPV') AS Dryer2SupplyPVName
          ,DSI.Dryer3SupplyPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer3SupplyPV') AS Dryer3SupplyPVName
          ,DSI.Dryer4SupplyPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer4SupplyPV') AS Dryer4SupplyPVName
          ,DSI.DryerArchChamberHeaterSetupDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerArchChamberHeaterSetupDisplayPV') AS DryerArchChamberHeaterSetupDisplayPVName
          ,DSI.DryerArchChamberHeaterDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerArchChamberHeaterDisplayPV') AS DryerArchChamberHeaterDisplayPVName
          ,DSI.Dryer1HeaterSetupDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1HeaterSetupDisplayPV') AS Dryer1HeaterSetupDisplayPVName
          ,DSI.Dryer1HeaterDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer1HeaterDisplayPV') AS Dryer1HeaterDisplayPVName
          ,DSI.Dryer2HeaterSetupDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2HeaterSetupDisplayPV') AS Dryer2HeaterSetupDisplayPVName
          ,DSI.Dryer2HeaterDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer2HeaterDisplayPV') AS Dryer2HeaterDisplayPVName
          ,DSI.Dryer3HeaterSetupDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer3HeaterSetupDisplayPV') AS Dryer3HeaterSetupDisplayPVName
          ,DSI.Dryer3HeaterDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer3HeaterDisplayPV') AS Dryer3HeaterDisplayPVName
          ,DSI.Dryer4HeaterSetupDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer4HeaterSetupDisplayPV') AS Dryer4HeaterSetupDisplayPVName
          ,DSI.Dryer4HeaterDisplayPV	, dbo.fnGetStringResource(@pProcessLanguage, 'Dryer4HeaterDisplayPV') AS Dryer4HeaterDisplayPVName
          ,DSI.VisionChronicDefectsEquipStopPV	, dbo.fnGetStringResource(@pProcessLanguage, 'VisionChronicDefectsEquipStopPV') AS VisionChronicDefectsEquipStopPVName
          ,DSI.XrfChronicDefectsEquipStopPV	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfChronicDefectsEquipStopPV') AS XrfChronicDefectsEquipStopPVName
          ,DSI.NwfUnwinderFabricDiameterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUnwinderFabricDiameterPV') AS NwfUnwinderFabricDiameterPVName
          ,DSI.UnwinderFabricDiameterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'UnwinderFabricDiameterPV') AS UnwinderFabricDiameterPVName
          ,DSI.PfUnwinderFabricDiameterPV	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUnwinderFabricDiameterPV') AS PfUnwinderFabricDiameterPVName
          ,DSI.PeristalticPumpLevelSensorPV	, dbo.fnGetStringResource(@pProcessLanguage, 'PeristalticPumpLevelSensorPV') AS PeristalticPumpLevelSensorPVName
          ,DSI.RecipeSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'RecipeSetupPV') AS RecipeSetupPVName
          ,DSI.RecipeStringSetupPV	, dbo.fnGetStringResource(@pProcessLanguage, 'RecipeStringSetupPV') AS RecipeStringSetupPVName
          ,DSI.RecipeStringPV	, dbo.fnGetStringResource(@pProcessLanguage, 'RecipeStringPV') AS RecipeStringPVName
          ,DSI.CreateDateTime
	  FROM STB_DCSettingInfo DSI
	 ORDER BY DCSettingSerialNo DESC
END