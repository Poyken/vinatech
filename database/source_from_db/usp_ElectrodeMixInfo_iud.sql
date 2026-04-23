
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리 > [B550] 전극측정결과 > 믹싱 첫번째 Tab화면  iud저장정보
-- Description:	전극믹싱정보
-- Modified: 2020.09.22 냉각수온도 추가 (안제헌)
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeMixInfo_iud]
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
  DECLARE @OldElectrodeLotNumber VARCHAR(20)
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @WorkDate DATETIME
  DECLARE @WorkerCode VARCHAR(20)
  DECLARE @Temperature NUMERIC(20,5)
  DECLARE @Humidity NUMERIC(20,5)
  DECLARE @ProductionQty NUMERIC(20,5)
  DECLARE @TankInsideTemp NUMERIC(20,5)
  DECLARE @ViscosityValue NUMERIC(20,5)
  DECLARE @SpecificGravityValue NUMERIC(20,5)
  DECLARE @MixingTemperature NUMERIC(20,5)
  DECLARE @SpecificComment VARCHAR(1000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  
  DECLARE @CoolantTemperature NUMERIC(20,5)    --추가

  	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeMixInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeMixInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							ElectrodeLotNumber,
							MachineCode,
							WorkDate,
							WorkerCode,
							Temperature,
							Humidity,
							ProductionQty,
							TankInsideTemp,
							ViscosityValue,
							SpecificGravityValue,
							MixingTemperature,
							SpecificComment,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							 CoolantTemperature                         --추가
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										ElectrodeLotNumber VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										Temperature NUMERIC(20,5),
										Humidity NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										TankInsideTemp NUMERIC(20,5),
										ViscosityValue NUMERIC(20,5),
										SpecificGravityValue NUMERIC(20,5),
										MixingTemperature NUMERIC(20,5),
										SpecificComment VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CoolantTemperature NUMERIC(20,5)  --추가
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					WorkDate = ISNULL(SourceTable.WorkDate,TargetTable.WorkDate),
					WorkerCode = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					Temperature = ISNULL(SourceTable.Temperature,TargetTable.Temperature),
					Humidity = ISNULL(SourceTable.Humidity,TargetTable.Humidity),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					TankInsideTemp = ISNULL(SourceTable.TankInsideTemp,TargetTable.TankInsideTemp),
					ViscosityValue = ISNULL(SourceTable.ViscosityValue,TargetTable.ViscosityValue),
					SpecificGravityValue = ISNULL(SourceTable.SpecificGravityValue,TargetTable.SpecificGravityValue),
					MixingTemperature = ISNULL(SourceTable.MixingTemperature,TargetTable.MixingTemperature),
					SpecificComment = ISNULL(SourceTable.SpecificComment,TargetTable.SpecificComment),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CoolantTemperature  = ISNULL(SourceTable.CoolantTemperature,TargetTable.CoolantTemperature)     --추가
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MachineCode,
						WorkDate,
						WorkerCode,
						Temperature,
						Humidity,
						ProductionQty,
						TankInsideTemp,
						ViscosityValue,
						SpecificGravityValue,
						MixingTemperature,
						SpecificComment,
						CreateDateTime,
						CreateUserID,
						CoolantTemperature
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MachineCode,
							SourceTable.WorkDate,
							SourceTable.WorkerCode,
							SourceTable.Temperature,
							SourceTable.Humidity,
							SourceTable.ProductionQty,
							SourceTable.TankInsideTemp,
							SourceTable.ViscosityValue,
							SourceTable.SpecificGravityValue,
							SourceTable.MixingTemperature,
							SourceTable.SpecificComment,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CoolantTemperature							
					);


			-- Process Update Table
            MERGE STB_ElectrodeMixInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							ElectrodeLotNumber,
							MachineCode,
							WorkDate,
							WorkerCode,
							Temperature,
							Humidity,
							ProductionQty,
							TankInsideTemp,
							ViscosityValue,
							SpecificGravityValue,
							MixingTemperature,
							SpecificComment,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CoolantTemperature
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										ElectrodeLotNumber VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										Temperature NUMERIC(20,5),
										Humidity NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										TankInsideTemp NUMERIC(20,5),
										ViscosityValue NUMERIC(20,5),
										SpecificGravityValue NUMERIC(20,5),
										MixingTemperature NUMERIC(20,5),
										SpecificComment VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CoolantTemperature NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					WorkDate = ISNULL(SourceTable.WorkDate,TargetTable.WorkDate),
					WorkerCode = ISNULL(SourceTable.WorkerCode,TargetTable.WorkerCode),
					Temperature = ISNULL(SourceTable.Temperature,TargetTable.Temperature),
					Humidity = ISNULL(SourceTable.Humidity,TargetTable.Humidity),
					ProductionQty = ISNULL(SourceTable.ProductionQty,TargetTable.ProductionQty),
					TankInsideTemp = ISNULL(SourceTable.TankInsideTemp,TargetTable.TankInsideTemp),
					ViscosityValue = ISNULL(SourceTable.ViscosityValue,TargetTable.ViscosityValue),
					SpecificGravityValue = ISNULL(SourceTable.SpecificGravityValue,TargetTable.SpecificGravityValue),
					MixingTemperature = ISNULL(SourceTable.MixingTemperature,TargetTable.MixingTemperature),
					SpecificComment = ISNULL(SourceTable.SpecificComment,TargetTable.SpecificComment),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					CoolantTemperature = ISNULL(SourceTable.CoolantTemperature,TargetTable.CoolantTemperature)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MachineCode,
						WorkDate,
						WorkerCode,
						Temperature,
						Humidity,
						ProductionQty,
						TankInsideTemp,
						ViscosityValue,
						SpecificGravityValue,
						MixingTemperature,
						SpecificComment,
						CreateDateTime,
						CreateUserID,
						CoolantTemperature
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MachineCode,
							SourceTable.WorkDate,
							SourceTable.WorkerCode,
							SourceTable.Temperature,
							SourceTable.Humidity,
							SourceTable.ProductionQty,
							SourceTable.TankInsideTemp,
							SourceTable.ViscosityValue,
							SourceTable.SpecificGravityValue,
							SourceTable.MixingTemperature,
							SourceTable.SpecificComment,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.CoolantTemperature
					);


			-- Process Delete Table
            MERGE STB_ElectrodeMixInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							ElectrodeLotNumber,
							MachineCode,
							WorkDate,
							WorkerCode,
							Temperature,
							Humidity,
							ProductionQty,
							TankInsideTemp,
							ViscosityValue,
							SpecificGravityValue,
							MixingTemperature,
							SpecificComment,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							CoolantTemperature
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										ElectrodeLotNumber VARCHAR(20),
										MachineCode VARCHAR(20),
										WorkDate DATETIMEOFFSET,
										WorkerCode VARCHAR(20),
										Temperature NUMERIC(20,5),
										Humidity NUMERIC(20,5),
										ProductionQty NUMERIC(20,5),
										TankInsideTemp NUMERIC(20,5),
										ViscosityValue NUMERIC(20,5),
										SpecificGravityValue NUMERIC(20,5),
										MixingTemperature NUMERIC(20,5),
										SpecificComment VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										CoolantTemperature NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber
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
									OldElectrodeLotNumber,
									ElectrodeLotNumber,
									MachineCode,
									WorkDate,
									WorkerCode,
									Temperature,
									Humidity,
									ProductionQty,
									TankInsideTemp,
									ViscosityValue,
									SpecificGravityValue,
									MixingTemperature,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CoolantTemperature
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 ElectrodeLotNumber VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 TankInsideTemp NUMERIC(20,5),
											 ViscosityValue NUMERIC(20,5),
											 SpecificGravityValue NUMERIC(20,5),
											 MixingTemperature NUMERIC(20,5),
											 SpecificComment VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CoolantTemperature NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
										ELSE OldElectrodeLotNumber
									END AS OldElectrodeLotNumber,
									ElectrodeLotNumber,
									MachineCode,
									WorkDate,
									WorkerCode,
									Temperature,
									Humidity,
									ProductionQty,
									TankInsideTemp,
									ViscosityValue,
									SpecificGravityValue,
									MixingTemperature,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CoolantTemperature
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 ElectrodeLotNumber VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 TankInsideTemp NUMERIC(20,5),
											 ViscosityValue NUMERIC(20,5),
											 SpecificGravityValue NUMERIC(20,5),
											 MixingTemperature NUMERIC(20,5),
											 SpecificComment VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CoolantTemperature NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
										ELSE OldElectrodeLotNumber
									END AS OldElectrodeLotNumber,
									ElectrodeLotNumber,
									MachineCode,
									WorkDate,
									WorkerCode,
									Temperature,
									Humidity,
									ProductionQty,
									TankInsideTemp,
									ViscosityValue,
									SpecificGravityValue,
									MixingTemperature,
									SpecificComment,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									CoolantTemperature
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 ElectrodeLotNumber VARCHAR(20),
											 MachineCode VARCHAR(20),
											 WorkDate DATETIMEOFFSET,
											 WorkerCode VARCHAR(20),
											 Temperature NUMERIC(20,5),
											 Humidity NUMERIC(20,5),
											 ProductionQty NUMERIC(20,5),
											 TankInsideTemp NUMERIC(20,5),
											 ViscosityValue NUMERIC(20,5),
											 SpecificGravityValue NUMERIC(20,5),
											 MixingTemperature NUMERIC(20,5),
											 SpecificComment VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 CoolantTemperature NUMERIC(20,5)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeLotNumber,
								 @ElectrodeLotNumber,
								 @MachineCode,
								 @WorkDate,
								 @WorkerCode,
								 @Temperature,
								 @Humidity,
								 @ProductionQty,
								 @TankInsideTemp,
								 @ViscosityValue,
								 @SpecificGravityValue,
								 @MixingTemperature,
								 @SpecificComment,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @CoolantTemperature

                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeMixInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeMixInfo',@ElectrodeLotNumber OUTPUT
                    END

                    INSERT INTO STB_ElectrodeMixInfo
						(
						    ElectrodeLotNumber,
						    MachineCode,
						    WorkDate,
						    WorkerCode,
						    Temperature,
						    Humidity,
						    ProductionQty,
						    TankInsideTemp,
						    ViscosityValue,
						    SpecificGravityValue,
						    MixingTemperature,
						    SpecificComment,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							CoolantTemperature
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @MachineCode,
						    @WorkDate,
						    @WorkerCode,
						    @Temperature,
						    @Humidity,
						    @ProductionQty,
						    @TankInsideTemp,
						    @ViscosityValue,
						    @SpecificGravityValue,
						    @MixingTemperature,
						    @SpecificComment,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@CoolantTemperature
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeMixInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    WorkDate =   ISNULL(@WorkDate,WorkDate),
						    WorkerCode =   ISNULL(@WorkerCode,WorkerCode),
						    Temperature =   ISNULL(@Temperature,Temperature),
						    Humidity =   ISNULL(@Humidity,Humidity),
						    ProductionQty =   ISNULL(@ProductionQty,ProductionQty),
						    TankInsideTemp =   ISNULL(@TankInsideTemp,TankInsideTemp),
						    ViscosityValue =   ISNULL(@ViscosityValue,ViscosityValue),
						    SpecificGravityValue =   ISNULL(@SpecificGravityValue,SpecificGravityValue),
						    MixingTemperature =   ISNULL(@MixingTemperature,MixingTemperature),
						    SpecificComment =   ISNULL(@SpecificComment,SpecificComment),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							CoolantTemperature = ISNULL(@CoolantTemperature,CoolantTemperature)
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeMixInfo
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber
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
