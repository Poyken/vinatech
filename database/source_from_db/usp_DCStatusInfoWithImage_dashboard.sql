 CREATE PROC [dbo].[usp_DCStatusInfoWithImage_dashboard]
	@pProcessLanguage VARCHAR(20)
 AS
 BEGIN
		   SELECT TOP 1
				   CASE WHEN OperationRun = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN OperationStop = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' 
						ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' 
				   END AS Operation
				  ,'운전' AS OperationName
				  ,CASE WHEN AlarmReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS AlarmReset	, dbo.fnGetStringResource(@pProcessLanguage, 'AlarmReset') AS AlarmResetName
				  ,CASE WHEN BuzzerReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BuzzerReset	, dbo.fnGetStringResource(@pProcessLanguage, 'BuzzerReset') AS BuzzerResetName
				  ,CASE WHEN TouchMode = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS TouchMode	, dbo.fnGetStringResource(@pProcessLanguage, 'TouchMode') AS TouchModeName
				  ,CASE WHEN GapMode = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS GapMode	, dbo.fnGetStringResource(@pProcessLanguage, 'GapMode') AS GapModeName
				  ,CASE WHEN TouchRollIn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS TouchRollIn	, dbo.fnGetStringResource(@pProcessLanguage, 'TouchRollIn') AS TouchRollInName
				  ,CASE WHEN TouchRollOut = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS TouchRollOut	, dbo.fnGetStringResource(@pProcessLanguage, 'TouchRollOut') AS TouchRollOutName
				  ,CASE WHEN WindingLengthReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS WindingLengthReset	, dbo.fnGetStringResource(@pProcessLanguage, 'WindingLengthReset') AS WindingLengthResetName
				  ,CASE WHEN NwfUwTopCoat = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfUwTopCoat	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUwTopCoat') AS NwfUwTopCoatName
				  ,CASE WHEN NwfUwDownCoat = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfUwDownCoat	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUwDownCoat') AS NwfUwDownCoatName
				  ,CASE WHEN UwTopCoat = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS UwTopCoat	, dbo.fnGetStringResource(@pProcessLanguage, 'UwTopCoat') AS UwTopCoatName
				  ,CASE WHEN UwDownCoat = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS UwDownCoat	, dbo.fnGetStringResource(@pProcessLanguage, 'UwDownCoat') AS UwDownCoatName
				  ,CASE WHEN PfUwTopCoat = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfUwTopCoat	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUwTopCoat') AS PfUwTopCoatName
				  ,CASE WHEN PfUwDownCoat = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfUwDownCoat	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUwDownCoat') AS PfUwDownCoatName
				  ,CASE WHEN PfRwUpperside = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfRwUpperside	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRwUpperside') AS PfRwUppersideName
				  ,CASE WHEN PfRwLowerside = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfRwLowerside	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRwLowerside') AS PfRwLowersideName
				  ,CASE WHEN NwfRwUppersize = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfRwUppersize	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRwUppersize') AS NwfRwUppersizeName
				  ,CASE WHEN NwfRwLowerside = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfRwLowerside	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRwLowerside') AS NwfRwLowersideName
				  ,CASE WHEN RwUpperside = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS RwUpperside	, dbo.fnGetStringResource(@pProcessLanguage, 'RwUpperside') AS RwUppersideName
				  ,CASE WHEN RwLowerside = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS RwLowerside	, dbo.fnGetStringResource(@pProcessLanguage, 'RwLowerside') AS RwLowersideName
				  ,CASE WHEN EmergencyStop = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS EmergencyStop	, dbo.fnGetStringResource(@pProcessLanguage, 'EmergencyStop') AS EmergencyStopName
				  ,CASE WHEN ServoAlarm = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS ServoAlarm	, dbo.fnGetStringResource(@pProcessLanguage, 'ServoAlarm') AS ServoAlarmName
				  ,CASE WHEN InverterAlarm = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS InverterAlarm	, dbo.fnGetStringResource(@pProcessLanguage, 'InverterAlarm') AS InverterAlarmName
				  ,CASE WHEN ChuckingAlarm = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS ChuckingAlarm	, dbo.fnGetStringResource(@pProcessLanguage, 'ChuckingAlarm') AS ChuckingAlarmName
				  ,CASE WHEN SupplyExhaustAbnormal = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS SupplyExhaustAbnormal	, dbo.fnGetStringResource(@pProcessLanguage, 'SupplyExhaustAbnormal') AS SupplyExhaustAbnormalName
				  ,CASE WHEN OverTempDetect = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OverTempDetect	, dbo.fnGetStringResource(@pProcessLanguage, 'OverTempDetect') AS OverTempDetectName
				  ,CASE WHEN GasAbnormal = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS GasAbnormal	, dbo.fnGetStringResource(@pProcessLanguage, 'GasAbnormal') AS GasAbnormalName
				  ,CASE WHEN FlameDetect = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS FlameDetect	, dbo.fnGetStringResource(@pProcessLanguage, 'FlameDetect') AS FlameDetectName
				  ,CASE WHEN LengthReached = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS LengthReached	, dbo.fnGetStringResource(@pProcessLanguage, 'LengthReached') AS LengthReachedName
				  
				  ,CASE WHEN SuctionRollServoOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN SuctionRollServoOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS SuctionRollServo	
				  ,'썩션롤서보' AS SuctionRollServoName
				  ,CASE WHEN DryerConveyorServoOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN DryerConveyorServoOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS DryerConveyorServo	
				  ,'건조기컨베이어서보' AS DryerConveyorServoName
				  ,CASE WHEN XrfConveyorServoOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN XrfConveyorServoOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS XrfConveyorServo	
				  ,'XRF컨베이어서보' AS XrfConveyorServoName
				  ,CASE WHEN OutfeedServoOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN OutfeedServoOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS OutfeedServo	
				  ,'아웃피드서보' AS OutfeedServoName
				  ,CASE WHEN TouchRollServoOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN TouchRollServoOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS TouchRollServo
				   ,'터치롤서보' AS TouchRollServoName
				  ,CASE WHEN NwfUwInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN NwfUwInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS NwfUwInverter	
				  ,'NWF UW 인버터' AS NwfUwInverterName
				  ,CASE WHEN UwInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN UwInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS UwInverter	
				  ,'UW 인버터' AS UwInverterName
				  ,CASE WHEN PfUwInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN PfUwInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS PfUwInverter	
				  ,'PF UW 인버터' AS PfUwInverterName
				  ,CASE WHEN PfRwInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN PfRwInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS PfRwInverter	
				  ,'PF RW 인버터' AS PfRwInverterName
				  ,CASE WHEN NwfRwInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN NwfRwInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png' END AS NwfRwInverter	
				  ,'NWF RW 인버터' AS NwfRwInverterName
				  ,CASE WHEN RwInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN RwInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS RwInverter	
				  ,'RW 인버터' AS RwInverterName
				  ,CASE WHEN MainSectionInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN MainSectionInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS MainSectionInverter	
				  ,'메인썩션인버터' AS MainSectionInverterName
				  ,CASE WHEN Dryer1BlowerInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer1BlowerInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer1BlowerInverter	
				  ,'건조기1블로워인버터' AS Dryer1BlowerInverterName
				  ,CASE WHEN Dryer2BlowerInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer2BlowerInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer2BlowerInverter	
				  ,'건조기2블로워인버터' AS Dryer2BlowerInverterName
				  ,CASE WHEN XrfBlowerInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN XrfBlowerInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS XrfBlowerInverter	
				  ,'XRF블로워인버터' AS XrfBlowerInverterName
				  ,CASE WHEN TurnbarLeftBlowerInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN TurnbarLeftBlowerInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS TurnbarLeftBlowerInverter	
				  ,'턴바왼쪽블로워인버터' AS TurnbarLeftBlowerInverterName
				  ,CASE WHEN TurnbarRightBlowerInverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN TurnbarRightBlowerInverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS TurnbarRightBlowerInverter	
				  ,'턴바오른쪽블로워인버터' AS TurnbarRightBlowerInverterName
				  ,CASE WHEN DustCollector1InverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN DustCollector1InverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS DustCollector1Inverter	
				  ,'집진기1인버터' AS DustCollector1InverterName
				  ,CASE WHEN DustCollector2InverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN DustCollector2InverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS DustCollector2Inverter	
				  ,'집진기2인버터' AS DustCollector2InverterName
				  ,CASE WHEN DustCollector3InverterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN DustCollector3InverterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS DustCollector3Inverter	
				  ,'집진기3인버터' AS DustCollector3InverterName
				  ,CASE WHEN Cleaner1On = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Cleaner1Off = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Cleaner1
				  ,'클리너1' AS Cleaner1Name
				  ,CASE WHEN Cleaner2On = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Cleaner2Off = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Cleaner2
				  ,'클리너2' AS Cleaner2Name
				  ,CASE WHEN Cleaner3On = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Cleaner3Off = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Cleaner3
				  ,'클리너3' AS Cleaner3Name

				  ,CASE WHEN AntistaticBarSimplexOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN AntistaticBarSimplexOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS AntistaticBarSimplex	
				  ,'제전바 단동' AS AntistaticBarSimplexName
				  ,CASE WHEN NwfUnwinderManual = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfUnwinderManual	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUnwinderManual') AS NwfUnwinderManualName
				  ,CASE WHEN NwfUnwinderAutomatic = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfUnwinderAutomatic	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUnwinderAutomatic') AS NwfUnwinderAutomaticName
				  ,CASE WHEN NwfUnwinderCenter = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfUnwinderCenter	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUnwinderCenter') AS NwfUnwinderCenterName
				  ,CASE WHEN NwfUnwinderLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfUnwinderLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUnwinderLimit') AS NwfUnwinderLimitName
				  ,CASE WHEN UnwinderManual = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS UnwinderManual	, dbo.fnGetStringResource(@pProcessLanguage, 'UnwinderManual') AS UnwinderManualName
				  ,CASE WHEN UnwinderAutomatic = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS UnwinderAutomatic	, dbo.fnGetStringResource(@pProcessLanguage, 'UnwinderAutomatic') AS UnwinderAutomaticName
				  ,CASE WHEN UnwinderCenter = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS UnwinderCenter	, dbo.fnGetStringResource(@pProcessLanguage, 'UnwinderCenter') AS UnwinderCenterName
				  ,CASE WHEN UnwinderLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS UnwinderLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'UnwinderLimit') AS UnwinderLimitName
				  ,CASE WHEN PfUnwinderManual = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfUnwinderManual	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUnwinderManual') AS PfUnwinderManualName
				  ,CASE WHEN PfUnwinderAutomatic = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfUnwinderAutomatic	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUnwinderAutomatic') AS PfUnwinderAutomaticName
				  ,CASE WHEN PfUnwinderCenter = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfUnwinderCenter	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUnwinderCenter') AS PfUnwinderCenterName
				  ,CASE WHEN PfUnwinderLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfUnwinderLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUnwinderLimit') AS PfUnwinderLimitName
				  ,CASE WHEN PfRewinderManual = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfRewinderManual	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRewinderManual') AS PfRewinderManualName
				  ,CASE WHEN PfRewinderAutomatic = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfRewinderAutomatic	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRewinderAutomatic') AS PfRewinderAutomaticName
				  ,CASE WHEN PfRewinderCenter = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfRewinderCenter	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRewinderCenter') AS PfRewinderCenterName
				  ,CASE WHEN PfRewinderLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfRewinderLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRewinderLimit') AS PfRewinderLimitName
				  ,CASE WHEN NwfRewinderManual = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfRewinderManual	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRewinderManual') AS NwfRewinderManualName
				  ,CASE WHEN NwfRewinderAutomatic = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfRewinderAutomatic	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRewinderAutomatic') AS NwfRewinderAutomaticName
				  ,CASE WHEN NwfRewinderCenter = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfRewinderCenter	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRewinderCenter') AS NwfRewinderCenterName
				  ,CASE WHEN NwfRewinderLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfRewinderLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRewinderLimit') AS NwfRewinderLimitName
				  ,CASE WHEN RewinderManual = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS RewinderManual	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderManual') AS RewinderManualName
				  ,CASE WHEN RewinderAutomatic = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS RewinderAutomatic	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderAutomatic') AS RewinderAutomaticName
				  ,CASE WHEN RewinderCenter = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS RewinderCenter	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderCenter') AS RewinderCenterName
				  ,CASE WHEN RewinderLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS RewinderLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderLimit') AS RewinderLimitName
				  ,CASE WHEN CoatingUnitEdge = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS CoatingUnitEdge	, dbo.fnGetStringResource(@pProcessLanguage, 'CoatingUnitEdge') AS CoatingUnitEdgeName
				  ,CASE WHEN CoatingUnitCam = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS CoatingUnitCam	, dbo.fnGetStringResource(@pProcessLanguage, 'CoatingUnitCam') AS CoatingUnitCamName

				  ,CASE WHEN NwfUwLengthSetupUseYn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfUwLengthSetupUseYn	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUwLengthSetupUseYn') AS NwfUwLengthSetupUseYnName
				  ,CASE WHEN NwfUwLengthReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfUwLengthReset	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfUwLengthReset') AS NwfUwLengthResetName
				  ,CASE WHEN UwLengthSetupUseYn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS UwLengthSetupUseYn	, dbo.fnGetStringResource(@pProcessLanguage, 'UwLengthSetupUseYn') AS UwLengthSetupUseYnName
				  ,CASE WHEN UwLengthReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS UwLengthReset	, dbo.fnGetStringResource(@pProcessLanguage, 'UwLengthReset') AS UwLengthResetName
				  ,CASE WHEN PfUwLengthSetupUseYn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfUwLengthSetupUseYn	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUwLengthSetupUseYn') AS PfUwLengthSetupUseYnName
				  ,CASE WHEN PfUwLengthReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfUwLengthReset	, dbo.fnGetStringResource(@pProcessLanguage, 'PfUwLengthReset') AS PfUwLengthResetName
				  ,CASE WHEN PfRwLengthSetupUseYn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfRwLengthSetupUseYn	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRwLengthSetupUseYn') AS PfRwLengthSetupUseYnName
				  ,CASE WHEN PfRwLengthReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PfRwLengthReset	, dbo.fnGetStringResource(@pProcessLanguage, 'PfRwLengthReset') AS PfRwLengthResetName
				  ,CASE WHEN NwfRwLengthSetupUseYn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfRwLengthSetupUseYn	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRwLengthSetupUseYn') AS NwfRwLengthSetupUseYnName
				  ,CASE WHEN NwfRwLengthReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS NwfRwLengthReset	, dbo.fnGetStringResource(@pProcessLanguage, 'NwfRwLengthReset') AS NwfRwLengthResetName
				  ,CASE WHEN RewinderLengthSetupUseYn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS RewinderLengthSetupUseYn	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderLengthSetupUseYn') AS RewinderLengthSetupUseYnName
				  ,CASE WHEN RewinderLengthReset = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS RewinderLengthReset	, dbo.fnGetStringResource(@pProcessLanguage, 'RewinderLengthReset') AS RewinderLengthResetName
				  
				  ,CASE WHEN ArchChamberExhaustOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN ArchChamberExhaustOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS ArchChamberExhaust	
				  ,'아치챔버배기' AS ArchChamberExhaustName
				  ,CASE WHEN Dryer1ExhaustOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer1ExhaustOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer1Exhaust	
				  ,'건조기1배기' AS Dryer1ExhaustName
				  ,CASE WHEN Dryer2ExhaustOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer2ExhaustOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer2Exhaust	
				  ,'건조기2배기' AS Dryer2ExhaustName
				  ,CASE WHEN ArchChamberSupplyOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN ArchChamberSupplyOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS ArchChamberSupply	
				  ,'아치챔버급기' AS ArchChamberSupplyName
				  ,CASE WHEN Dryer1SupplyOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer1SupplyOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer1Supply	
				  ,'건조기1급기' AS Dryer1SupplyName
				  ,CASE WHEN Dryer2SupplyOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer2SupplyOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer2Supply	
				  ,'건조기2급기' AS Dryer2SupplyName
				  ,CASE WHEN Dryer3SupplyOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer3SupplyOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer3Supply	
				  ,'건조기3급기' AS Dryer3SupplyName
				  ,CASE WHEN Dryer4SupplyOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer4SupplyOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer4Supply	
				  ,'건조기4급기' AS Dryer4SupplyName
				  ,CASE WHEN Dryer1HeaterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer1HeaterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer1Heater	
				  ,'건조기1히터' AS Dryer1HeaterName
				  ,CASE WHEN Dryer2_1HeaterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer2_1HeaterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer2_1Heater	
				  ,'건조기2-1히터' AS Dryer2_1HeaterName
				  ,CASE WHEN Dryer2_2HeaterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer2_2HeaterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer2_2Heater	
				  ,'건조기2-2히터' AS Dryer2_2HeaterName
				  ,CASE WHEN Dryer2_3HeaterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer2_3HeaterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer2_3Heater	
				  ,'건조기2-3히터' AS Dryer2_3HeaterName
				  ,CASE WHEN Dryer2_4HeaterOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN Dryer2_4HeaterOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS Dryer2_4Heater	
				  ,'건조기2-4히터' AS Dryer2_4HeaterName
				  
				  ,CASE WHEN BothUp = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BothUp	, dbo.fnGetStringResource(@pProcessLanguage, 'BothUp') AS BothUpName
				  ,CASE WHEN BothDown = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BothDown	, dbo.fnGetStringResource(@pProcessLanguage, 'BothDown') AS BothDownName
				  ,CASE WHEN OperationsideUp = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OperationsideUp	, dbo.fnGetStringResource(@pProcessLanguage, 'OperationsideUp') AS OperationsideUpName
				  ,CASE WHEN OperationsideDown = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OperationsideDown	, dbo.fnGetStringResource(@pProcessLanguage, 'OperationsideDown') AS OperationsideDownName
				  ,CASE WHEN DrivesideUp = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS DrivesideUp	, dbo.fnGetStringResource(@pProcessLanguage, 'DrivesideUp') AS DrivesideUpName
				  ,CASE WHEN DrivesideDown = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS DrivesideDown	, dbo.fnGetStringResource(@pProcessLanguage, 'DrivesideDown') AS DrivesideDownName
				  ,CASE WHEN OperationServoNormal = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OperationServoNormal	, dbo.fnGetStringResource(@pProcessLanguage, 'OperationServoNormal') AS OperationServoNormalName
				  -- 4page end
				  ,CASE WHEN DriveServoNormal = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS DriveServoNormal	, dbo.fnGetStringResource(@pProcessLanguage, 'DriveServoNormal') AS DriveServoNormalName
				  ,CASE WHEN OperationsideServoUpperLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OperationsideServoUpperLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'OperationsideServoUpperLimit') AS OperationsideServoUpperLimitName
				  ,CASE WHEN OperationsideServoLowerLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OperationsideServoLowerLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'OperationsideServoLowerLimit') AS OperationsideServoLowerLimitName
				  ,CASE WHEN DrivesideServoUpperLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS DrivesideServoUpperLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'DrivesideServoUpperLimit') AS DrivesideServoUpperLimitName
				  ,CASE WHEN DrivesideServoLowerLimit = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS DrivesideServoLowerLimit	, dbo.fnGetStringResource(@pProcessLanguage, 'DrivesideServoLowerLimit') AS DrivesideServoLowerLimitName
				  ,CASE WHEN SlotDieIn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS SlotDieIn	, dbo.fnGetStringResource(@pProcessLanguage, 'SlotDieIn') AS SlotDieInName
				  ,CASE WHEN SlotDieOut = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS SlotDieOut	, dbo.fnGetStringResource(@pProcessLanguage, 'SlotDieOut') AS SlotDieOutName
				  
				  ,CASE WHEN Niproll1Close = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS Niproll1Close	, dbo.fnGetStringResource(@pProcessLanguage, 'Niproll1Close') AS Niproll1CloseName
				  ,CASE WHEN Niproll1Open = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS Niproll1Open	, dbo.fnGetStringResource(@pProcessLanguage, 'Niproll1Open') AS Niproll1OpenName
				  ,CASE WHEN Niproll2Close = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS Niproll2Close	, dbo.fnGetStringResource(@pProcessLanguage, 'Niproll2Close') AS Niproll2CloseName
				  ,CASE WHEN Niproll2Open = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS Niproll2Open	, dbo.fnGetStringResource(@pProcessLanguage, 'Niproll2Open') AS Niproll2OpenName
				  ,CASE WHEN Niproll3Close = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS Niproll3Close	, dbo.fnGetStringResource(@pProcessLanguage, 'Niproll3Close') AS Niproll3CloseName
				  ,CASE WHEN Niproll3Open = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS Niproll3Open	, dbo.fnGetStringResource(@pProcessLanguage, 'Niproll3Open') AS Niproll3OpenName
				  ,CASE WHEN PinchrollClose = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PinchrollClose	, dbo.fnGetStringResource(@pProcessLanguage, 'PinchrollClose') AS PinchrollCloseName
				  ,CASE WHEN PinchrollOpen = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS PinchrollOpen	, dbo.fnGetStringResource(@pProcessLanguage, 'PinchrollOpen') AS PinchrollOpenName
				  
				  ,CASE WHEN FFUOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN FFUOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS FFU	
				  ,'FFU' AS FFUName
				  ,CASE WHEN BoothLampOn = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN BoothLampOff = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS BoothLamp	
				  ,'BOOTH LAMP' AS BoothLampName
				  
				  ,CASE WHEN SuctionrollJogReverse = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS SuctionrollJogReverse	, dbo.fnGetStringResource(@pProcessLanguage, 'SuctionrollJogReverse') AS SuctionrollJogReverseName
				  ,CASE WHEN SuctionrollJogStop = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS SuctionrollJogStop	, dbo.fnGetStringResource(@pProcessLanguage, 'SuctionrollJogStop') AS SuctionrollJogStopName
				  ,CASE WHEN SuctionrollJogForward = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS SuctionrollJogForward	, dbo.fnGetStringResource(@pProcessLanguage, 'SuctionrollJogForward') AS SuctionrollJogForwardName
				  ,CASE WHEN DryerConveyorJogReverse = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS DryerConveyorJogReverse	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerConveyorJogReverse') AS DryerConveyorJogReverseName
				  ,CASE WHEN DryerConveyorJogStop = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS DryerConveyorJogStop	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerConveyorJogStop') AS DryerConveyorJogStopName
				  ,CASE WHEN DryerConveyorJogForward = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS DryerConveyorJogForward	, dbo.fnGetStringResource(@pProcessLanguage, 'DryerConveyorJogForward') AS DryerConveyorJogForwardName
				  ,CASE WHEN XrfConveyorJogReverse = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS XrfConveyorJogReverse	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfConveyorJogReverse') AS XrfConveyorJogReverseName
				  ,CASE WHEN XrfConveyorJogStop = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS XrfConveyorJogStop	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfConveyorJogStop') AS XrfConveyorJogStopName
				  ,CASE WHEN XrfConveyorJogForward = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS XrfConveyorJogForward	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfConveyorJogForward') AS XrfConveyorJogForwardName
				  ,CASE WHEN OutfeedJogReverse = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OutfeedJogReverse	, dbo.fnGetStringResource(@pProcessLanguage, 'OutfeedJogReverse') AS OutfeedJogReverseName
				  ,CASE WHEN OutfeedJogStop = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OutfeedJogStop	, dbo.fnGetStringResource(@pProcessLanguage, 'OutfeedJogStop') AS OutfeedJogStopName
				  ,CASE WHEN OutfeedJogForward = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS OutfeedJogForward	, dbo.fnGetStringResource(@pProcessLanguage, 'OutfeedJogForward') AS OutfeedJogForwardName
				  ,CASE WHEN VisionSimplex = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS VisionSimplex	, dbo.fnGetStringResource(@pProcessLanguage, 'VisionSimplex') AS VisionSimplexName
				  ,CASE WHEN VisionDuplex = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS VisionDuplex	, dbo.fnGetStringResource(@pProcessLanguage, 'VisionDuplex') AS VisionDuplexName
				  
				  ,CASE WHEN VisionSimplexRun = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN VisionSimplexStop = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS VisionSimplex
				  ,'비전단동' AS VisionSimplexName
				  
				  ,CASE WHEN VisionSimplexRunLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN VisionSimplexStopLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS VisionSimplexLP	
				  ,'비전단동LP' AS VisionSimplexLPName
				  ,CASE WHEN VisionPlcClockLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS VisionPlcClockLP	, dbo.fnGetStringResource(@pProcessLanguage, 'VisionPlcClockLP') AS VisionPlcClockLPName
				  ,CASE WHEN VisionPlcReadyLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS VisionPlcReadyLP	, dbo.fnGetStringResource(@pProcessLanguage, 'VisionPlcReadyLP') AS VisionPlcReadyLPName
				  ,CASE WHEN VisionPlcGoodLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS VisionPlcGoodLP	, dbo.fnGetStringResource(@pProcessLanguage, 'VisionPlcGoodLP') AS VisionPlcGoodLPName
				  ,CASE WHEN VisionPlcDefectLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS VisionPlcDefectLP	, dbo.fnGetStringResource(@pProcessLanguage, 'VisionPlcDefectLP') AS VisionPlcDefectLPName
				  ,CASE WHEN XrfSimplex = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS XrfSimplex	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfSimplex') AS XrfSimplexName
				  ,CASE WHEN XrfDuplex = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS XrfDuplex	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfDuplex') AS XrfDuplexName
				  ,CASE WHEN XrfSimplexRun = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN XrfSimplexStop = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS XrfSimplex	
				  ,'XRF 단동' AS XrfSimplexName
				  ,CASE WHEN XrfSimplexRunLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' 
				        WHEN XrfSimplexStopLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/gray.png'  END AS XrfSimplexLP	
				  ,'XRF 단동LP' AS XrfSimplexLPName
				  ,CASE WHEN XrfPlcReadyLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS XrfPlcReadyLP	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfPlcReadyLP') AS XrfPlcReadyLPName
				  ,CASE WHEN XrfPlcGoodLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS XrfPlcGoodLP	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfPlcGoodLP') AS XrfPlcGoodLPName
				  ,CASE WHEN XrfPlcDefectLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS XrfPlcDefectLP	, dbo.fnGetStringResource(@pProcessLanguage, 'XrfPlcDefectLP') AS XrfPlcDefectLPName
				  ,CASE WHEN BarcodeSimplex = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BarcodeSimplex	, dbo.fnGetStringResource(@pProcessLanguage, 'BarcodeSimplex') AS BarcodeSimplexName
				  ,CASE WHEN BarcodeDuplex = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BarcodeDuplex	, dbo.fnGetStringResource(@pProcessLanguage, 'BarcodeDuplex') AS BarcodeDuplexName
				  ,CASE WHEN BarcodeSimplexRun = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BarcodeSimplexRun	, dbo.fnGetStringResource(@pProcessLanguage, 'BarcodeSimplexRun') AS BarcodeSimplexRunName
				  ,CASE WHEN BarcodeSimplexRunLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BarcodeSimplexRunLP	, dbo.fnGetStringResource(@pProcessLanguage, 'BarcodeSimplexRunLP') AS BarcodeSimplexRunLPName
				  ,CASE WHEN BarcodePlcReadyLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BarcodePlcReadyLP	, dbo.fnGetStringResource(@pProcessLanguage, 'BarcodePlcReadyLP') AS BarcodePlcReadyLPName
				  ,CASE WHEN BarcodePlcErrorLP = CONVERT(BIT, 1) THEN 'http://mes.hycap.co.kr:9952/images/dcDashboard/green.png' ELSE 'http://mes.hycap.co.kr:9952/images/dcDashboard/red.png' END AS BarcodePlcErrorLP	, dbo.fnGetStringResource(@pProcessLanguage, 'BarcodePlcErrorLP') AS BarcodePlcErrorLPName

			  FROM STB_DCStatusInfo DCSI
			 ORDER BY DCSI.DCStatusSerialNo DESC
 END