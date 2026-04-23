-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2023-05-02
-- Browsable : true
-- Group : 스마트팩토리
-- Description:	다이렉트코터 설정정보를 조회합니다.
-- Modified:
-- =============================================
CREATE PROC [dbo].[usp_DCSettingInfo_get]
	@pProcessUserID VARCHAR(20)
   ,@pProcessLanguage VARCHAR(20)
   ,@pFromDate DATE
   ,@pToDate DATE
AS
BEGIN
	Declare @FromDate DATETIME = CONVERT(CHAR(10), @pFromDate, 121) + ' 00:00:00'
	       ,@ToDate DATETIME = CONVERT(CHAR(10), @pToDate, 121) + ' 23:59:59'


		SELECT DSI.DCSettingSerialNo
              ,DSI.LotNo
              ,DSI.Barcode
              ,DSI.MachineID
              ,DSI.OperationSpeedSV
              ,DSI.AccelerationTimeSV
              ,DSI.DecelerationTimeSV
              ,DSI.StopTimeSV
              ,DSI.MainSectionInverterSV
              ,DSI.Dryer1BlowerInverterSV
              ,DSI.Dryer2BlowerInverterSV
              ,DSI.XrfBlowerInverterSV
              ,DSI.TurnbarLeftBlowerInverterSV
              ,DSI.TurnbarRightBlowerInverterSV
              ,DSI.DustCollector1InverterSV
              ,DSI.DustCollector2InverterSV
              ,DSI.DustCollector3InverterSV
              ,DSI.JumboConverterPresureSetupSV
              ,DSI.JumboConverterTiltSetupPresureDisplaySV
              ,DSI.WindingProductThicknessSetupSV
              ,DSI.NwfUwTensionSetupSV
              ,DSI.UwTensionSetupSV
              ,DSI.PfUwTensionSetupSV
              ,DSI.PfRwTensionSetupSV
              ,DSI.NwfRwTensionSetupSV
              ,DSI.OutfeedTensionSetupSV
              ,DSI.RewinderTensionSetupSV
              ,DSI.RewinderTensionTiltTargetTensionDisplaySV
              ,DSI.DryerServoSpeedRateSV
              ,DSI.XrfServoSpeedRateSV
              ,DSI.OutfeedSpeedRateSV
              ,DSI.EpcPatternDetectStartPositionSV
              ,DSI.EpcPatternDetectEndPositionSV
              ,DSI.JumborollPresureSetupSV
              ,DSI.ArchChamberExhaustSV
              ,DSI.Dryer1ExhaustSV
              ,DSI.Dryer2ExhaustSV
              ,DSI.ArchChamberSupplySV
              ,DSI.Dryer1SupplySV
              ,DSI.Dryer2SupplySV
              ,DSI.Dryer3SupplySV
              ,DSI.Dryer4SupplySV
              ,DSI.DryerArchChamberHeaterSetupDisplaySV
              ,DSI.DryerArchChamberHeaterDisplaySV
              ,DSI.Dryer1HeaterSetupDisplaySV
              ,DSI.Dryer1HeaterDisplaySV
              ,DSI.Dryer2HeaterSetupDisplaySV
              ,DSI.Dryer2HeaterDisplaySV
              ,DSI.Dryer3HeaterSetupDisplaySV
              ,DSI.Dryer3HeaterDisplaySV
              ,DSI.Dryer4HeaterSetupDisplaySV
              ,DSI.Dryer4HeaterDisplaySV
              ,DSI.VisionChronicDefectsEquipStopSV
              ,DSI.XrfChronicDefectsEquipStopSV
              ,DSI.NwfUnwinderFabricDiameterSV
              ,DSI.UnwinderFabricDiameterSV
              ,DSI.PfUnwinderFabricDiameterSV
              ,DSI.PeristalticPumpLevelSensorSV
              ,DSI.RecipeSetupSV
              ,DSI.RecipeStringSetupSV
              ,DSI.RecipeStringSV
              ,DSI.OperationSpeedPV
              ,DSI.AccelerationTimePV
              ,DSI.DecelerationTimePV
              ,DSI.StopTimePV
              ,DSI.MainSectionInverterPV
              ,DSI.Dryer1BlowerInverterPV
              ,DSI.Dryer2BlowerInverterPV
              ,DSI.XrfBlowerInverterPV
              ,DSI.TurnbarLeftBlowerInverterPV
              ,DSI.TurnbarRightBlowerInverterPV
              ,DSI.DustCollector1InverterPV
              ,DSI.DustCollector2InverterPV
              ,DSI.DustCollector3InverterPV
              ,DSI.JumboConverterPresureSetupPV
              ,DSI.JumboConverterTiltSetupPresureDisplayPV
              ,DSI.WindingProductThicknessSetupPV
              ,DSI.NwfUwTensionSetupPV
              ,DSI.UwTensionSetupPV
              ,DSI.PfUwTensionSetupPV
              ,DSI.PfRwTensionSetupPV
              ,DSI.NwfRwTensionSetupPV
              ,DSI.OutfeedTensionSetupPV
              ,DSI.RewinderTensionSetupPV
              ,DSI.RewinderTensionTiltTargetTensionDisplayPV
              ,DSI.DryerServoSpeedRatePV
              ,DSI.XrfServoSpeedRatePV
              ,DSI.OutfeedSpeedRatePV
              ,DSI.EpcPatternDetectStartPositionPV
              ,DSI.EpcPatternDetectEndPositionPV
              ,DSI.JumborollPresureSetupPV
              ,DSI.ArchChamberExhaustPV
              ,DSI.Dryer1ExhaustPV
              ,DSI.Dryer2ExhaustPV
              ,DSI.ArchChamberSupplyPV
              ,DSI.Dryer1SupplyPV
              ,DSI.Dryer2SupplyPV
              ,DSI.Dryer3SupplyPV
              ,DSI.Dryer4SupplyPV
              ,DSI.DryerArchChamberHeaterSetupDisplayPV
              ,DSI.DryerArchChamberHeaterDisplayPV
              ,DSI.Dryer1HeaterSetupDisplayPV
              ,DSI.Dryer1HeaterDisplayPV
              ,DSI.Dryer2HeaterSetupDisplayPV
              ,DSI.Dryer2HeaterDisplayPV
              ,DSI.Dryer3HeaterSetupDisplayPV
              ,DSI.Dryer3HeaterDisplayPV
              ,DSI.Dryer4HeaterSetupDisplayPV
              ,DSI.Dryer4HeaterDisplayPV
              ,DSI.VisionChronicDefectsEquipStopPV
              ,DSI.XrfChronicDefectsEquipStopPV
              ,DSI.NwfUnwinderFabricDiameterPV
              ,DSI.UnwinderFabricDiameterPV
              ,DSI.PfUnwinderFabricDiameterPV
              ,DSI.PeristalticPumpLevelSensorPV
              ,DSI.RecipeSetupPV
              ,DSI.RecipeStringSetupPV
              ,DSI.RecipeStringPV
              ,DSI.CreateDateTime
		  FROM STB_DCSettingInfo DSI
		  LEFT OUTER JOIN STB_InterfaceMachineInfo IMI
	       ON IMI.MachineID = DSI.MachineID
		 WHERE DSI.CreateDateTime BETWEEN @FromDate AND @ToDate
		 ORDER BY DCSettingSerialNo
END
