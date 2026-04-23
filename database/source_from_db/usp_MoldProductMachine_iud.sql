
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스 관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldProductMachine_iud]
	@pProcessUserID VARCHAR(20),
	@pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
	@pXml NVARCHAR(MAX) = null
AS
BEGIN
	SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName
    DECLARE @InsertTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_INSERT'
    DECLARE @UpdateTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_UPDATE'
    DECLARE @DeleteTableName VARCHAR(100) = '/DataSet/' + @ProcessViewName + '_DELETE'
    DECLARE @ERROR_MSG NVARCHAR(MAX)
    DECLARE @IUD_FLAG VARCHAR(10)
    DECLARE @IsAutoKey BIT
    DECLARE @IsLoopIUD BIT
    DECLARE @PrefixString VARCHAR(20)
    DECLARE @SerialLen INT

    -- Declare Columns Variable
  DECLARE @OldMachineCode VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @MachineName VARCHAR(50)
  DECLARE @DisplayIndex INT
  DECLARE @InjectType VARCHAR(20)
  DECLARE @Capa VARCHAR(20)
  DECLARE @MonitoringGroup VARCHAR(20)
  DECLARE @ErpMachineCode VARCHAR(20)
  DECLARE @IsTemperatureControl BIT
  DECLARE @IsCommunication BIT
  DECLARE @MachineDesc1 VARCHAR(200)
  DECLARE @MachineDesc2 VARCHAR(200)
  DECLARE @MachineDesc3 VARCHAR(200)
  DECLARE @MachineDesc4 VARCHAR(200)
  DECLARE @MachineDesc5 VARCHAR(200)
  DECLARE @MoldProdNo VARCHAR(50)
  DECLARE @RunMode VARCHAR(1)
  DECLARE @IsMachineAlarm BIT
  DECLARE @IsMoldTempControl BIT
  DECLARE @MoldTemp1 NUMERIC(10,2)
  DECLARE @MoldTemp2 NUMERIC(10,2)
  DECLARE @MoldTemp3 NUMERIC(10,2)
  DECLARE @MoldTemp4 NUMERIC(10,2)
  DECLARE @MoldTemp5 NUMERIC(10,2)
  DECLARE @MoldTemp6 NUMERIC(10,2)
  DECLARE @IsMoldTempAlarm1 BIT
  DECLARE @IsMoldTempAlarm2 BIT
  DECLARE @IsMoldTempAlarm3 BIT
  DECLARE @IsMoldTempAlarm4 BIT
  DECLARE @IsMoldTempAlarm5 BIT
  DECLARE @IsMoldTempAlarm6 BIT
  DECLARE @MoldTemperatureSet1 NUMERIC(10,2)
  DECLARE @MoldTemperatureSet2 NUMERIC(10,2)
  DECLARE @MoldTemperatureSet3 NUMERIC(10,2)
  DECLARE @MoldTemperatureSet4 NUMERIC(10,2)
  DECLARE @MoldTemperatureSet5 NUMERIC(10,2)
  DECLARE @MoldTemperatureSet6 NUMERIC(10,2)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldProductMachine',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldProductMachine AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							MachineCode,
							WorkCenterCode,
							LineCode,
							RouteCode,
							MachineName,
							DisplayIndex,
							ISNULL(InjectType,'') AS InjectType,
							Capa,
							MonitoringGroup,
							ErpMachineCode,
							IsTemperatureControl,
							IsCommunication,
							MachineDesc1,
							MachineDesc2,
							MachineDesc3,
							MachineDesc4,
							MachineDesc5,
							MoldProdNo,
							RunMode,
							IsMachineAlarm,
							IsMoldTempControl,
							MoldTemp1,
							MoldTemp2,
							MoldTemp3,
							MoldTemp4,
							MoldTemp5,
							MoldTemp6,
							IsMoldTempAlarm1,
							IsMoldTempAlarm2,
							IsMoldTempAlarm3,
							IsMoldTempAlarm4,
							IsMoldTempAlarm5,
							IsMoldTempAlarm6,
							MoldTemperatureSet1,
							MoldTemperatureSet2,
							MoldTemperatureSet3,
							MoldTemperatureSet4,
							MoldTemperatureSet5,
							MoldTemperatureSet6,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										RouteCode VARCHAR(20),
										MachineName VARCHAR(50),
										DisplayIndex INT,
										InjectType VARCHAR(20),
										Capa VARCHAR(20),
										MonitoringGroup VARCHAR(20),
										ErpMachineCode VARCHAR(20),
										IsTemperatureControl BIT,
										IsCommunication BIT,
										MachineDesc1 VARCHAR(200),
										MachineDesc2 VARCHAR(200),
										MachineDesc3 VARCHAR(200),
										MachineDesc4 VARCHAR(200),
										MachineDesc5 VARCHAR(200),
										MoldProdNo VARCHAR(50),
										RunMode VARCHAR(1),
										IsMachineAlarm BIT,
										IsMoldTempControl BIT,
										MoldTemp1 NUMERIC(10,2),
										MoldTemp2 NUMERIC(10,2),
										MoldTemp3 NUMERIC(10,2),
										MoldTemp4 NUMERIC(10,2),
										MoldTemp5 NUMERIC(10,2),
										MoldTemp6 NUMERIC(10,2),
										IsMoldTempAlarm1 BIT,
										IsMoldTempAlarm2 BIT,
										IsMoldTempAlarm3 BIT,
										IsMoldTempAlarm4 BIT,
										IsMoldTempAlarm5 BIT,
										IsMoldTempAlarm6 BIT,
										MoldTemperatureSet1 NUMERIC(10,2),
										MoldTemperatureSet2 NUMERIC(10,2),
										MoldTemperatureSet3 NUMERIC(10,2),
										MoldTemperatureSet4 NUMERIC(10,2),
										MoldTemperatureSet5 NUMERIC(10,2),
										MoldTemperatureSet6 NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					MachineName = ISNULL(SourceTable.MachineName,TargetTable.MachineName),
					DisplayIndex = ISNULL(SourceTable.DisplayIndex,TargetTable.DisplayIndex),
					InjectType = ISNULL(SourceTable.InjectType,TargetTable.InjectType),
					Capa = ISNULL(SourceTable.Capa,TargetTable.Capa),
					MonitoringGroup = ISNULL(SourceTable.MonitoringGroup,TargetTable.MonitoringGroup),
					ErpMachineCode = ISNULL(SourceTable.ErpMachineCode,TargetTable.ErpMachineCode),
					IsTemperatureControl = ISNULL(SourceTable.IsTemperatureControl,TargetTable.IsTemperatureControl),
					IsCommunication = ISNULL(SourceTable.IsCommunication,TargetTable.IsCommunication),
					MachineDesc1 = ISNULL(SourceTable.MachineDesc1,TargetTable.MachineDesc1),
					MachineDesc2 = ISNULL(SourceTable.MachineDesc2,TargetTable.MachineDesc2),
					MachineDesc3 = ISNULL(SourceTable.MachineDesc3,TargetTable.MachineDesc3),
					MachineDesc4 = ISNULL(SourceTable.MachineDesc4,TargetTable.MachineDesc4),
					MachineDesc5 = ISNULL(SourceTable.MachineDesc5,TargetTable.MachineDesc5),
					MoldProdNo = ISNULL(SourceTable.MoldProdNo,TargetTable.MoldProdNo),
					RunMode = ISNULL(SourceTable.RunMode,TargetTable.RunMode),
					IsMachineAlarm = ISNULL(SourceTable.IsMachineAlarm,TargetTable.IsMachineAlarm),
					IsMoldTempControl = ISNULL(SourceTable.IsMoldTempControl,TargetTable.IsMoldTempControl),
					MoldTemp1 = ISNULL(SourceTable.MoldTemp1,TargetTable.MoldTemp1),
					MoldTemp2 = ISNULL(SourceTable.MoldTemp2,TargetTable.MoldTemp2),
					MoldTemp3 = ISNULL(SourceTable.MoldTemp3,TargetTable.MoldTemp3),
					MoldTemp4 = ISNULL(SourceTable.MoldTemp4,TargetTable.MoldTemp4),
					MoldTemp5 = ISNULL(SourceTable.MoldTemp5,TargetTable.MoldTemp5),
					MoldTemp6 = ISNULL(SourceTable.MoldTemp6,TargetTable.MoldTemp6),
					IsMoldTempAlarm1 = ISNULL(SourceTable.IsMoldTempAlarm1,TargetTable.IsMoldTempAlarm1),
					IsMoldTempAlarm2 = ISNULL(SourceTable.IsMoldTempAlarm2,TargetTable.IsMoldTempAlarm2),
					IsMoldTempAlarm3 = ISNULL(SourceTable.IsMoldTempAlarm3,TargetTable.IsMoldTempAlarm3),
					IsMoldTempAlarm4 = ISNULL(SourceTable.IsMoldTempAlarm4,TargetTable.IsMoldTempAlarm4),
					IsMoldTempAlarm5 = ISNULL(SourceTable.IsMoldTempAlarm5,TargetTable.IsMoldTempAlarm5),
					IsMoldTempAlarm6 = ISNULL(SourceTable.IsMoldTempAlarm6,TargetTable.IsMoldTempAlarm6),
					MoldTemperatureSet1 = ISNULL(SourceTable.MoldTemperatureSet1,TargetTable.MoldTemperatureSet1),
					MoldTemperatureSet2 = ISNULL(SourceTable.MoldTemperatureSet2,TargetTable.MoldTemperatureSet2),
					MoldTemperatureSet3 = ISNULL(SourceTable.MoldTemperatureSet3,TargetTable.MoldTemperatureSet3),
					MoldTemperatureSet4 = ISNULL(SourceTable.MoldTemperatureSet4,TargetTable.MoldTemperatureSet4),
					MoldTemperatureSet5 = ISNULL(SourceTable.MoldTemperatureSet5,TargetTable.MoldTemperatureSet5),
					MoldTemperatureSet6 = ISNULL(SourceTable.MoldTemperatureSet6,TargetTable.MoldTemperatureSet6),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						WorkCenterCode,
						LineCode,
						RouteCode,
						MachineName,
						DisplayIndex,
						InjectType,
						Capa,
						MonitoringGroup,
						ErpMachineCode,
						IsTemperatureControl,
						IsCommunication,
						MachineDesc1,
						MachineDesc2,
						MachineDesc3,
						MachineDesc4,
						MachineDesc5,
						MoldProdNo,
						RunMode,
						IsMachineAlarm,
						IsMoldTempControl,
						MoldTemp1,
						MoldTemp2,
						MoldTemp3,
						MoldTemp4,
						MoldTemp5,
						MoldTemp6,
						IsMoldTempAlarm1,
						IsMoldTempAlarm2,
						IsMoldTempAlarm3,
						IsMoldTempAlarm4,
						IsMoldTempAlarm5,
						IsMoldTempAlarm6,
						MoldTemperatureSet1,
						MoldTemperatureSet2,
						MoldTemperatureSet3,
						MoldTemperatureSet4,
						MoldTemperatureSet5,
						MoldTemperatureSet6,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineCode,
							SourceTable.RouteCode,
							SourceTable.MachineName,
							SourceTable.DisplayIndex,
							SourceTable.InjectType,
							SourceTable.Capa,
							SourceTable.MonitoringGroup,
							SourceTable.ErpMachineCode,
							SourceTable.IsTemperatureControl,
							SourceTable.IsCommunication,
							SourceTable.MachineDesc1,
							SourceTable.MachineDesc2,
							SourceTable.MachineDesc3,
							SourceTable.MachineDesc4,
							SourceTable.MachineDesc5,
							SourceTable.MoldProdNo,
							SourceTable.RunMode,
							SourceTable.IsMachineAlarm,
							SourceTable.IsMoldTempControl,
							SourceTable.MoldTemp1,
							SourceTable.MoldTemp2,
							SourceTable.MoldTemp3,
							SourceTable.MoldTemp4,
							SourceTable.MoldTemp5,
							SourceTable.MoldTemp6,
							SourceTable.IsMoldTempAlarm1,
							SourceTable.IsMoldTempAlarm2,
							SourceTable.IsMoldTempAlarm3,
							SourceTable.IsMoldTempAlarm4,
							SourceTable.IsMoldTempAlarm5,
							SourceTable.IsMoldTempAlarm6,
							SourceTable.MoldTemperatureSet1,
							SourceTable.MoldTemperatureSet2,
							SourceTable.MoldTemperatureSet3,
							SourceTable.MoldTemperatureSet4,
							SourceTable.MoldTemperatureSet5,
							SourceTable.MoldTemperatureSet6,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldProductMachine AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							MachineCode,
							WorkCenterCode,
							LineCode,
							RouteCode,
							MachineName,
							DisplayIndex,
							ISNULL(InjectType,'') AS InjectType,
							Capa,
							MonitoringGroup,
							ErpMachineCode,
							IsTemperatureControl,
							IsCommunication,
							MachineDesc1,
							MachineDesc2,
							MachineDesc3,
							MachineDesc4,
							MachineDesc5,
							MoldProdNo,
							RunMode,
							IsMachineAlarm,
							IsMoldTempControl,
							MoldTemp1,
							MoldTemp2,
							MoldTemp3,
							MoldTemp4,
							MoldTemp5,
							MoldTemp6,
							IsMoldTempAlarm1,
							IsMoldTempAlarm2,
							IsMoldTempAlarm3,
							IsMoldTempAlarm4,
							IsMoldTempAlarm5,
							IsMoldTempAlarm6,
							MoldTemperatureSet1,
							MoldTemperatureSet2,
							MoldTemperatureSet3,
							MoldTemperatureSet4,
							MoldTemperatureSet5,
							MoldTemperatureSet6,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										RouteCode VARCHAR(20),
										MachineName VARCHAR(50),
										DisplayIndex INT,
										InjectType VARCHAR(20),
										Capa VARCHAR(20),
										MonitoringGroup VARCHAR(20),
										ErpMachineCode VARCHAR(20),
										IsTemperatureControl BIT,
										IsCommunication BIT,
										MachineDesc1 VARCHAR(200),
										MachineDesc2 VARCHAR(200),
										MachineDesc3 VARCHAR(200),
										MachineDesc4 VARCHAR(200),
										MachineDesc5 VARCHAR(200),
										MoldProdNo VARCHAR(50),
										RunMode VARCHAR(1),
										IsMachineAlarm BIT,
										IsMoldTempControl BIT,
										MoldTemp1 NUMERIC(10,2),
										MoldTemp2 NUMERIC(10,2),
										MoldTemp3 NUMERIC(10,2),
										MoldTemp4 NUMERIC(10,2),
										MoldTemp5 NUMERIC(10,2),
										MoldTemp6 NUMERIC(10,2),
										IsMoldTempAlarm1 BIT,
										IsMoldTempAlarm2 BIT,
										IsMoldTempAlarm3 BIT,
										IsMoldTempAlarm4 BIT,
										IsMoldTempAlarm5 BIT,
										IsMoldTempAlarm6 BIT,
										MoldTemperatureSet1 NUMERIC(10,2),
										MoldTemperatureSet2 NUMERIC(10,2),
										MoldTemperatureSet3 NUMERIC(10,2),
										MoldTemperatureSet4 NUMERIC(10,2),
										MoldTemperatureSet5 NUMERIC(10,2),
										MoldTemperatureSet6 NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.OldMachineCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					MachineName = ISNULL(SourceTable.MachineName,TargetTable.MachineName),
					DisplayIndex = ISNULL(SourceTable.DisplayIndex,TargetTable.DisplayIndex),
					InjectType = ISNULL(SourceTable.InjectType,TargetTable.InjectType),
					Capa = ISNULL(SourceTable.Capa,TargetTable.Capa),
					MonitoringGroup = ISNULL(SourceTable.MonitoringGroup,TargetTable.MonitoringGroup),
					ErpMachineCode = ISNULL(SourceTable.ErpMachineCode,TargetTable.ErpMachineCode),
					IsTemperatureControl = ISNULL(SourceTable.IsTemperatureControl,TargetTable.IsTemperatureControl),
					IsCommunication = ISNULL(SourceTable.IsCommunication,TargetTable.IsCommunication),
					MachineDesc1 = ISNULL(SourceTable.MachineDesc1,TargetTable.MachineDesc1),
					MachineDesc2 = ISNULL(SourceTable.MachineDesc2,TargetTable.MachineDesc2),
					MachineDesc3 = ISNULL(SourceTable.MachineDesc3,TargetTable.MachineDesc3),
					MachineDesc4 = ISNULL(SourceTable.MachineDesc4,TargetTable.MachineDesc4),
					MachineDesc5 = ISNULL(SourceTable.MachineDesc5,TargetTable.MachineDesc5),
					MoldProdNo = ISNULL(SourceTable.MoldProdNo,TargetTable.MoldProdNo),
					RunMode = ISNULL(SourceTable.RunMode,TargetTable.RunMode),
					IsMachineAlarm = ISNULL(SourceTable.IsMachineAlarm,TargetTable.IsMachineAlarm),
					IsMoldTempControl = ISNULL(SourceTable.IsMoldTempControl,TargetTable.IsMoldTempControl),
					MoldTemp1 = ISNULL(SourceTable.MoldTemp1,TargetTable.MoldTemp1),
					MoldTemp2 = ISNULL(SourceTable.MoldTemp2,TargetTable.MoldTemp2),
					MoldTemp3 = ISNULL(SourceTable.MoldTemp3,TargetTable.MoldTemp3),
					MoldTemp4 = ISNULL(SourceTable.MoldTemp4,TargetTable.MoldTemp4),
					MoldTemp5 = ISNULL(SourceTable.MoldTemp5,TargetTable.MoldTemp5),
					MoldTemp6 = ISNULL(SourceTable.MoldTemp6,TargetTable.MoldTemp6),
					IsMoldTempAlarm1 = ISNULL(SourceTable.IsMoldTempAlarm1,TargetTable.IsMoldTempAlarm1),
					IsMoldTempAlarm2 = ISNULL(SourceTable.IsMoldTempAlarm2,TargetTable.IsMoldTempAlarm2),
					IsMoldTempAlarm3 = ISNULL(SourceTable.IsMoldTempAlarm3,TargetTable.IsMoldTempAlarm3),
					IsMoldTempAlarm4 = ISNULL(SourceTable.IsMoldTempAlarm4,TargetTable.IsMoldTempAlarm4),
					IsMoldTempAlarm5 = ISNULL(SourceTable.IsMoldTempAlarm5,TargetTable.IsMoldTempAlarm5),
					IsMoldTempAlarm6 = ISNULL(SourceTable.IsMoldTempAlarm6,TargetTable.IsMoldTempAlarm6),
					MoldTemperatureSet1 = ISNULL(SourceTable.MoldTemperatureSet1,TargetTable.MoldTemperatureSet1),
					MoldTemperatureSet2 = ISNULL(SourceTable.MoldTemperatureSet2,TargetTable.MoldTemperatureSet2),
					MoldTemperatureSet3 = ISNULL(SourceTable.MoldTemperatureSet3,TargetTable.MoldTemperatureSet3),
					MoldTemperatureSet4 = ISNULL(SourceTable.MoldTemperatureSet4,TargetTable.MoldTemperatureSet4),
					MoldTemperatureSet5 = ISNULL(SourceTable.MoldTemperatureSet5,TargetTable.MoldTemperatureSet5),
					MoldTemperatureSet6 = ISNULL(SourceTable.MoldTemperatureSet6,TargetTable.MoldTemperatureSet6),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						WorkCenterCode,
						LineCode,
						RouteCode,
						MachineName,
						DisplayIndex,
						InjectType,
						Capa,
						MonitoringGroup,
						ErpMachineCode,
						IsTemperatureControl,
						IsCommunication,
						MachineDesc1,
						MachineDesc2,
						MachineDesc3,
						MachineDesc4,
						MachineDesc5,
						MoldProdNo,
						RunMode,
						IsMachineAlarm,
						IsMoldTempControl,
						MoldTemp1,
						MoldTemp2,
						MoldTemp3,
						MoldTemp4,
						MoldTemp5,
						MoldTemp6,
						IsMoldTempAlarm1,
						IsMoldTempAlarm2,
						IsMoldTempAlarm3,
						IsMoldTempAlarm4,
						IsMoldTempAlarm5,
						IsMoldTempAlarm6,
						MoldTemperatureSet1,
						MoldTemperatureSet2,
						MoldTemperatureSet3,
						MoldTemperatureSet4,
						MoldTemperatureSet5,
						MoldTemperatureSet6,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineCode,
							SourceTable.RouteCode,
							SourceTable.MachineName,
							SourceTable.DisplayIndex,
							SourceTable.InjectType,
							SourceTable.Capa,
							SourceTable.MonitoringGroup,
							SourceTable.ErpMachineCode,
							SourceTable.IsTemperatureControl,
							SourceTable.IsCommunication,
							SourceTable.MachineDesc1,
							SourceTable.MachineDesc2,
							SourceTable.MachineDesc3,
							SourceTable.MachineDesc4,
							SourceTable.MachineDesc5,
							SourceTable.MoldProdNo,
							SourceTable.RunMode,
							SourceTable.IsMachineAlarm,
							SourceTable.IsMoldTempControl,
							SourceTable.MoldTemp1,
							SourceTable.MoldTemp2,
							SourceTable.MoldTemp3,
							SourceTable.MoldTemp4,
							SourceTable.MoldTemp5,
							SourceTable.MoldTemp6,
							SourceTable.IsMoldTempAlarm1,
							SourceTable.IsMoldTempAlarm2,
							SourceTable.IsMoldTempAlarm3,
							SourceTable.IsMoldTempAlarm4,
							SourceTable.IsMoldTempAlarm5,
							SourceTable.IsMoldTempAlarm6,
							SourceTable.MoldTemperatureSet1,
							SourceTable.MoldTemperatureSet2,
							SourceTable.MoldTemperatureSet3,
							SourceTable.MoldTemperatureSet4,
							SourceTable.MoldTemperatureSet5,
							SourceTable.MoldTemperatureSet6,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldProductMachine AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							MachineCode,
							WorkCenterCode,
							LineCode,
							RouteCode,
							MachineName,
							DisplayIndex,
							InjectType,
							Capa,
							MonitoringGroup,
							ErpMachineCode,
							IsTemperatureControl,
							IsCommunication,
							MachineDesc1,
							MachineDesc2,
							MachineDesc3,
							MachineDesc4,
							MachineDesc5,
							MoldProdNo,
							RunMode,
							IsMachineAlarm,
							IsMoldTempControl,
							MoldTemp1,
							MoldTemp2,
							MoldTemp3,
							MoldTemp4,
							MoldTemp5,
							MoldTemp6,
							IsMoldTempAlarm1,
							IsMoldTempAlarm2,
							IsMoldTempAlarm3,
							IsMoldTempAlarm4,
							IsMoldTempAlarm5,
							IsMoldTempAlarm6,
							MoldTemperatureSet1,
							MoldTemperatureSet2,
							MoldTemperatureSet3,
							MoldTemperatureSet4,
							MoldTemperatureSet5,
							MoldTemperatureSet6,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										RouteCode VARCHAR(20),
										MachineName VARCHAR(50),
										DisplayIndex INT,
										InjectType VARCHAR(20),
										Capa VARCHAR(20),
										MonitoringGroup VARCHAR(20),
										ErpMachineCode VARCHAR(20),
										IsTemperatureControl BIT,
										IsCommunication BIT,
										MachineDesc1 VARCHAR(200),
										MachineDesc2 VARCHAR(200),
										MachineDesc3 VARCHAR(200),
										MachineDesc4 VARCHAR(200),
										MachineDesc5 VARCHAR(200),
										MoldProdNo VARCHAR(50),
										RunMode VARCHAR(1),
										IsMachineAlarm BIT,
										IsMoldTempControl BIT,
										MoldTemp1 NUMERIC(10,2),
										MoldTemp2 NUMERIC(10,2),
										MoldTemp3 NUMERIC(10,2),
										MoldTemp4 NUMERIC(10,2),
										MoldTemp5 NUMERIC(10,2),
										MoldTemp6 NUMERIC(10,2),
										IsMoldTempAlarm1 BIT,
										IsMoldTempAlarm2 BIT,
										IsMoldTempAlarm3 BIT,
										IsMoldTempAlarm4 BIT,
										IsMoldTempAlarm5 BIT,
										IsMoldTempAlarm6 BIT,
										MoldTemperatureSet1 NUMERIC(10,2),
										MoldTemperatureSet2 NUMERIC(10,2),
										MoldTemperatureSet3 NUMERIC(10,2),
										MoldTemperatureSet4 NUMERIC(10,2),
										MoldTemperatureSet5 NUMERIC(10,2),
										MoldTemperatureSet6 NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode
				)

			WHEN MATCHED THEN
				DELETE;

        END TRY
	    BEGIN CATCH
            SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
	    END CATCH
		
	    EXEC sp_xml_removedocument @idoc

    END ELSE BEGIN
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
                SELECT
                        'INSERT' AS IUD_FLAG,
									OldMachineCode,
									MachineCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									MachineName,
									DisplayIndex,
									InjectType,
									Capa,
									MonitoringGroup,
									ErpMachineCode,
									IsTemperatureControl,
									IsCommunication,
									MachineDesc1,
									MachineDesc2,
									MachineDesc3,
									MachineDesc4,
									MachineDesc5,
									MoldProdNo,
									RunMode,
									IsMachineAlarm,
									IsMoldTempControl,
									MoldTemp1,
									MoldTemp2,
									MoldTemp3,
									MoldTemp4,
									MoldTemp5,
									MoldTemp6,
									IsMoldTempAlarm1,
									IsMoldTempAlarm2,
									IsMoldTempAlarm3,
									IsMoldTempAlarm4,
									IsMoldTempAlarm5,
									IsMoldTempAlarm6,
									MoldTemperatureSet1,
									MoldTemperatureSet2,
									MoldTemperatureSet3,
									MoldTemperatureSet4,
									MoldTemperatureSet5,
									MoldTemperatureSet6,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 MachineName VARCHAR(50),
											 DisplayIndex INT,
											 InjectType VARCHAR(20),
											 Capa VARCHAR(20),
											 MonitoringGroup VARCHAR(20),
											 ErpMachineCode VARCHAR(20),
											 IsTemperatureControl BIT,
											 IsCommunication BIT,
											 MachineDesc1 VARCHAR(200),
											 MachineDesc2 VARCHAR(200),
											 MachineDesc3 VARCHAR(200),
											 MachineDesc4 VARCHAR(200),
											 MachineDesc5 VARCHAR(200),
											 MoldProdNo VARCHAR(50),
											 RunMode VARCHAR(1),
											 IsMachineAlarm BIT,
											 IsMoldTempControl BIT,
											 MoldTemp1 NUMERIC(10,2),
											 MoldTemp2 NUMERIC(10,2),
											 MoldTemp3 NUMERIC(10,2),
											 MoldTemp4 NUMERIC(10,2),
											 MoldTemp5 NUMERIC(10,2),
											 MoldTemp6 NUMERIC(10,2),
											 IsMoldTempAlarm1 BIT,
											 IsMoldTempAlarm2 BIT,
											 IsMoldTempAlarm3 BIT,
											 IsMoldTempAlarm4 BIT,
											 IsMoldTempAlarm5 BIT,
											 IsMoldTempAlarm6 BIT,
											 MoldTemperatureSet1 NUMERIC(10,2),
											 MoldTemperatureSet2 NUMERIC(10,2),
											 MoldTemperatureSet3 NUMERIC(10,2),
											 MoldTemperatureSet4 NUMERIC(10,2),
											 MoldTemperatureSet5 NUMERIC(10,2),
											 MoldTemperatureSet6 NUMERIC(10,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMachineCode IS NULL THEN MachineCode
										ELSE OldMachineCode
									END AS OldMachineCode,
									MachineCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									MachineName,
									DisplayIndex,
									InjectType,
									Capa,
									MonitoringGroup,
									ErpMachineCode,
									IsTemperatureControl,
									IsCommunication,
									MachineDesc1,
									MachineDesc2,
									MachineDesc3,
									MachineDesc4,
									MachineDesc5,
									MoldProdNo,
									RunMode,
									IsMachineAlarm,
									IsMoldTempControl,
									MoldTemp1,
									MoldTemp2,
									MoldTemp3,
									MoldTemp4,
									MoldTemp5,
									MoldTemp6,
									IsMoldTempAlarm1,
									IsMoldTempAlarm2,
									IsMoldTempAlarm3,
									IsMoldTempAlarm4,
									IsMoldTempAlarm5,
									IsMoldTempAlarm6,
									MoldTemperatureSet1,
									MoldTemperatureSet2,
									MoldTemperatureSet3,
									MoldTemperatureSet4,
									MoldTemperatureSet5,
									MoldTemperatureSet6,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 MachineName VARCHAR(50),
											 DisplayIndex INT,
											 InjectType VARCHAR(20),
											 Capa VARCHAR(20),
											 MonitoringGroup VARCHAR(20),
											 ErpMachineCode VARCHAR(20),
											 IsTemperatureControl BIT,
											 IsCommunication BIT,
											 MachineDesc1 VARCHAR(200),
											 MachineDesc2 VARCHAR(200),
											 MachineDesc3 VARCHAR(200),
											 MachineDesc4 VARCHAR(200),
											 MachineDesc5 VARCHAR(200),
											 MoldProdNo VARCHAR(50),
											 RunMode VARCHAR(1),
											 IsMachineAlarm BIT,
											 IsMoldTempControl BIT,
											 MoldTemp1 NUMERIC(10,2),
											 MoldTemp2 NUMERIC(10,2),
											 MoldTemp3 NUMERIC(10,2),
											 MoldTemp4 NUMERIC(10,2),
											 MoldTemp5 NUMERIC(10,2),
											 MoldTemp6 NUMERIC(10,2),
											 IsMoldTempAlarm1 BIT,
											 IsMoldTempAlarm2 BIT,
											 IsMoldTempAlarm3 BIT,
											 IsMoldTempAlarm4 BIT,
											 IsMoldTempAlarm5 BIT,
											 IsMoldTempAlarm6 BIT,
											 MoldTemperatureSet1 NUMERIC(10,2),
											 MoldTemperatureSet2 NUMERIC(10,2),
											 MoldTemperatureSet3 NUMERIC(10,2),
											 MoldTemperatureSet4 NUMERIC(10,2),
											 MoldTemperatureSet5 NUMERIC(10,2),
											 MoldTemperatureSet6 NUMERIC(10,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMachineCode IS NULL THEN MachineCode
										ELSE OldMachineCode
									END AS OldMachineCode,
									MachineCode,
									WorkCenterCode,
									LineCode,
									RouteCode,
									MachineName,
									DisplayIndex,
									InjectType,
									Capa,
									MonitoringGroup,
									ErpMachineCode,
									IsTemperatureControl,
									IsCommunication,
									MachineDesc1,
									MachineDesc2,
									MachineDesc3,
									MachineDesc4,
									MachineDesc5,
									MoldProdNo,
									RunMode,
									IsMachineAlarm,
									IsMoldTempControl,
									MoldTemp1,
									MoldTemp2,
									MoldTemp3,
									MoldTemp4,
									MoldTemp5,
									MoldTemp6,
									IsMoldTempAlarm1,
									IsMoldTempAlarm2,
									IsMoldTempAlarm3,
									IsMoldTempAlarm4,
									IsMoldTempAlarm5,
									IsMoldTempAlarm6,
									MoldTemperatureSet1,
									MoldTemperatureSet2,
									MoldTemperatureSet3,
									MoldTemperatureSet4,
									MoldTemperatureSet5,
									MoldTemperatureSet6,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 MachineName VARCHAR(50),
											 DisplayIndex INT,
											 InjectType VARCHAR(20),
											 Capa VARCHAR(20),
											 MonitoringGroup VARCHAR(20),
											 ErpMachineCode VARCHAR(20),
											 IsTemperatureControl BIT,
											 IsCommunication BIT,
											 MachineDesc1 VARCHAR(200),
											 MachineDesc2 VARCHAR(200),
											 MachineDesc3 VARCHAR(200),
											 MachineDesc4 VARCHAR(200),
											 MachineDesc5 VARCHAR(200),
											 MoldProdNo VARCHAR(50),
											 RunMode VARCHAR(1),
											 IsMachineAlarm BIT,
											 IsMoldTempControl BIT,
											 MoldTemp1 NUMERIC(10,2),
											 MoldTemp2 NUMERIC(10,2),
											 MoldTemp3 NUMERIC(10,2),
											 MoldTemp4 NUMERIC(10,2),
											 MoldTemp5 NUMERIC(10,2),
											 MoldTemp6 NUMERIC(10,2),
											 IsMoldTempAlarm1 BIT,
											 IsMoldTempAlarm2 BIT,
											 IsMoldTempAlarm3 BIT,
											 IsMoldTempAlarm4 BIT,
											 IsMoldTempAlarm5 BIT,
											 IsMoldTempAlarm6 BIT,
											 MoldTemperatureSet1 NUMERIC(10,2),
											 MoldTemperatureSet2 NUMERIC(10,2),
											 MoldTemperatureSet3 NUMERIC(10,2),
											 MoldTemperatureSet4 NUMERIC(10,2),
											 MoldTemperatureSet5 NUMERIC(10,2),
											 MoldTemperatureSet6 NUMERIC(10,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMachineCode,
								 @MachineCode,
								 @WorkCenterCode,
								 @LineCode,
								 @RouteCode,
								 @MachineName,
								 @DisplayIndex,
								 @InjectType,
								 @Capa,
								 @MonitoringGroup,
								 @ErpMachineCode,
								 @IsTemperatureControl,
								 @IsCommunication,
								 @MachineDesc1,
								 @MachineDesc2,
								 @MachineDesc3,
								 @MachineDesc4,
								 @MachineDesc5,
								 @MoldProdNo,
								 @RunMode,
								 @IsMachineAlarm,
								 @IsMoldTempControl,
								 @MoldTemp1,
								 @MoldTemp2,
								 @MoldTemp3,
								 @MoldTemp4,
								 @MoldTemp5,
								 @MoldTemp6,
								 @IsMoldTempAlarm1,
								 @IsMoldTempAlarm2,
								 @IsMoldTempAlarm3,
								 @IsMoldTempAlarm4,
								 @IsMoldTempAlarm5,
								 @IsMoldTempAlarm6,
								 @MoldTemperatureSet1,
								 @MoldTemperatureSet2,
								 @MoldTemperatureSet3,
								 @MoldTemperatureSet4,
								 @MoldTemperatureSet5,
								 @MoldTemperatureSet6,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldProductMachine WHERE MachineCode = @MachineCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachineCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MoldProductMachine',@MachineCode OUTPUT
                    END

                    INSERT INTO STB_MoldProductMachine
						(
						    MachineCode,
						    WorkCenterCode,
						    LineCode,
						    RouteCode,
						    MachineName,
						    DisplayIndex,
						    InjectType,
						    Capa,
						    MonitoringGroup,
						    ErpMachineCode,
						    IsTemperatureControl,
						    IsCommunication,
						    MachineDesc1,
						    MachineDesc2,
						    MachineDesc3,
						    MachineDesc4,
						    MachineDesc5,
						    MoldProdNo,
						    RunMode,
						    IsMachineAlarm,
						    IsMoldTempControl,
						    MoldTemp1,
						    MoldTemp2,
						    MoldTemp3,
						    MoldTemp4,
						    MoldTemp5,
						    MoldTemp6,
						    IsMoldTempAlarm1,
						    IsMoldTempAlarm2,
						    IsMoldTempAlarm3,
						    IsMoldTempAlarm4,
						    IsMoldTempAlarm5,
						    IsMoldTempAlarm6,
						    MoldTemperatureSet1,
						    MoldTemperatureSet2,
						    MoldTemperatureSet3,
						    MoldTemperatureSet4,
						    MoldTemperatureSet5,
						    MoldTemperatureSet6,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MachineCode,
						    @WorkCenterCode,
						    @LineCode,
						    @RouteCode,
						    @MachineName,
						    @DisplayIndex,
						    @InjectType,
						    @Capa,
						    @MonitoringGroup,
						    @ErpMachineCode,
						    @IsTemperatureControl,
						    @IsCommunication,
						    @MachineDesc1,
						    @MachineDesc2,
						    @MachineDesc3,
						    @MachineDesc4,
						    @MachineDesc5,
						    @MoldProdNo,
						    @RunMode,
						    @IsMachineAlarm,
						    @IsMoldTempControl,
						    @MoldTemp1,
						    @MoldTemp2,
						    @MoldTemp3,
						    @MoldTemp4,
						    @MoldTemp5,
						    @MoldTemp6,
						    @IsMoldTempAlarm1,
						    @IsMoldTempAlarm2,
						    @IsMoldTempAlarm3,
						    @IsMoldTempAlarm4,
						    @IsMoldTempAlarm5,
						    @IsMoldTempAlarm6,
						    @MoldTemperatureSet1,
						    @MoldTemperatureSet2,
						    @MoldTemperatureSet3,
						    @MoldTemperatureSet4,
						    @MoldTemperatureSet5,
						    @MoldTemperatureSet6,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldProductMachine
						SET
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    MachineName =   ISNULL(@MachineName,MachineName),
						    DisplayIndex =   ISNULL(@DisplayIndex,DisplayIndex),
						    InjectType =   ISNULL(@InjectType,InjectType),
						    Capa =   ISNULL(@Capa,Capa),
						    MonitoringGroup =   ISNULL(@MonitoringGroup,MonitoringGroup),
						    ErpMachineCode =   ISNULL(@ErpMachineCode,ErpMachineCode),
						    IsTemperatureControl =   ISNULL(@IsTemperatureControl,IsTemperatureControl),
						    IsCommunication =   ISNULL(@IsCommunication,IsCommunication),
						    MachineDesc1 =   ISNULL(@MachineDesc1,MachineDesc1),
						    MachineDesc2 =   ISNULL(@MachineDesc2,MachineDesc2),
						    MachineDesc3 =   ISNULL(@MachineDesc3,MachineDesc3),
						    MachineDesc4 =   ISNULL(@MachineDesc4,MachineDesc4),
						    MachineDesc5 =   ISNULL(@MachineDesc5,MachineDesc5),
						    MoldProdNo =   ISNULL(@MoldProdNo,MoldProdNo),
						    RunMode =   ISNULL(@RunMode,RunMode),
						    IsMachineAlarm =   ISNULL(@IsMachineAlarm,IsMachineAlarm),
						    IsMoldTempControl =   ISNULL(@IsMoldTempControl,IsMoldTempControl),
						    MoldTemp1 =   ISNULL(@MoldTemp1,MoldTemp1),
						    MoldTemp2 =   ISNULL(@MoldTemp2,MoldTemp2),
						    MoldTemp3 =   ISNULL(@MoldTemp3,MoldTemp3),
						    MoldTemp4 =   ISNULL(@MoldTemp4,MoldTemp4),
						    MoldTemp5 =   ISNULL(@MoldTemp5,MoldTemp5),
						    MoldTemp6 =   ISNULL(@MoldTemp6,MoldTemp6),
						    IsMoldTempAlarm1 =   ISNULL(@IsMoldTempAlarm1,IsMoldTempAlarm1),
						    IsMoldTempAlarm2 =   ISNULL(@IsMoldTempAlarm2,IsMoldTempAlarm2),
						    IsMoldTempAlarm3 =   ISNULL(@IsMoldTempAlarm3,IsMoldTempAlarm3),
						    IsMoldTempAlarm4 =   ISNULL(@IsMoldTempAlarm4,IsMoldTempAlarm4),
						    IsMoldTempAlarm5 =   ISNULL(@IsMoldTempAlarm5,IsMoldTempAlarm5),
						    IsMoldTempAlarm6 =   ISNULL(@IsMoldTempAlarm6,IsMoldTempAlarm6),
						    MoldTemperatureSet1 =   ISNULL(@MoldTemperatureSet1,MoldTemperatureSet1),
						    MoldTemperatureSet2 =   ISNULL(@MoldTemperatureSet2,MoldTemperatureSet2),
						    MoldTemperatureSet3 =   ISNULL(@MoldTemperatureSet3,MoldTemperatureSet3),
						    MoldTemperatureSet4 =   ISNULL(@MoldTemperatureSet4,MoldTemperatureSet4),
						    MoldTemperatureSet5 =   ISNULL(@MoldTemperatureSet5,MoldTemperatureSet5),
						    MoldTemperatureSet6 =   ISNULL(@MoldTemperatureSet6,MoldTemperatureSet6),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MachineCode = @OldMachineCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldProductMachine
						WHERE
						    MachineCode = @OldMachineCode
                END
            END
        END TRY
		BEGIN CATCH
			SET @ERROR_MSG = ERROR_MESSAGE()
			RAISERROR( @ERROR_MSG ,16, 1)
		END CATCH
			
		CLOSE SourceData;
		DEALLOCATE SourceData;
			
		EXEC sp_xml_removedocument @idoc	
    END
END