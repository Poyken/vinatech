
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2020-03-04
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeWasteInfoNew_iud]
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
  DECLARE @OldElectrodeWasteNo VARCHAR(20)
  DECLARE @ElectrodeWasteNo VARCHAR(20)
  DECLARE @CompanyCode VARCHAR(20)
  DECLARE @WorkCenterCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @JobDate DATE
  DECLARE @CalendarCode VARCHAR(20)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @ElectrodeClassCode VARCHAR(20)
  DECLARE @CurrentCollectorClassCode VARCHAR(20)
  DECLARE @ElectrodeThickness VARCHAR(20)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @DefectWeight NUMERIC(20,3)
  DECLARE @Remark NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @Barcode VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeWasteInfoNew',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeWasteInfoNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
							    ELSE OldElectrodeWasteNo
							END AS OldElectrodeWasteNo,
							ElectrodeWasteNo,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							JobDate,
							CalendarCode,
							RouteCode,
							ElectrodeClassCode,
							CurrentCollectorClassCode,
							ElectrodeThickness,
							MachineCode,
							DefectCode,
							DefectWeight,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeWasteNo VARCHAR(20),
										ElectrodeWasteNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CalendarCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										CurrentCollectorClassCode VARCHAR(20),
										ElectrodeThickness VARCHAR(20),
										MachineCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectWeight NUMERIC(20,3),
										Remark NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWasteNo = SourceTable.ElectrodeWasteNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeWasteNo = ISNULL(SourceTable.ElectrodeWasteNo,TargetTable.ElectrodeWasteNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					CalendarCode = ISNULL(SourceTable.CalendarCode,TargetTable.CalendarCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					ElectrodeClassCode = ISNULL(SourceTable.ElectrodeClassCode,TargetTable.ElectrodeClassCode),
					CurrentCollectorClassCode = ISNULL(SourceTable.CurrentCollectorClassCode,TargetTable.CurrentCollectorClassCode),
					ElectrodeThickness = ISNULL(SourceTable.ElectrodeThickness,TargetTable.ElectrodeThickness),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectWeight = ISNULL(SourceTable.DefectWeight,TargetTable.DefectWeight),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeWasteNo,
						CompanyCode,
						WorkCenterCode,
						LineCode,
						JobDate,
						CalendarCode,
						RouteCode,
						ElectrodeClassCode,
						CurrentCollectorClassCode,
						ElectrodeThickness,
						MachineCode,
						DefectCode,
						DefectWeight,
						Remark,
						CreateDateTime,
						CreateUserID,
						Barcode
					)
				VALUES
					(
							SourceTable.ElectrodeWasteNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineCode,
							SourceTable.JobDate,
							SourceTable.CalendarCode,
							SourceTable.RouteCode,
							SourceTable.ElectrodeClassCode,
							SourceTable.CurrentCollectorClassCode,
							SourceTable.ElectrodeThickness,
							SourceTable.MachineCode,
							SourceTable.DefectCode,
							SourceTable.DefectWeight,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Barcode
					);


			-- Process Update Table
            MERGE STB_ElectrodeWasteInfoNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
							    ELSE OldElectrodeWasteNo
							END AS OldElectrodeWasteNo,
							ElectrodeWasteNo,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							JobDate,
							CalendarCode,
							RouteCode,
							ElectrodeClassCode,
							CurrentCollectorClassCode,
							ElectrodeThickness,
							MachineCode,
							DefectCode,
							DefectWeight,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeWasteNo VARCHAR(20),
										ElectrodeWasteNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CalendarCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										CurrentCollectorClassCode VARCHAR(20),
										ElectrodeThickness VARCHAR(20),
										MachineCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectWeight NUMERIC(20,3),
										Remark NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWasteNo = SourceTable.OldElectrodeWasteNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeWasteNo = ISNULL(SourceTable.ElectrodeWasteNo,TargetTable.ElectrodeWasteNo),
					CompanyCode = ISNULL(SourceTable.CompanyCode,TargetTable.CompanyCode),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					LineCode = ISNULL(SourceTable.LineCode,TargetTable.LineCode),
					JobDate = ISNULL(SourceTable.JobDate,TargetTable.JobDate),
					CalendarCode = ISNULL(SourceTable.CalendarCode,TargetTable.CalendarCode),
					RouteCode = ISNULL(SourceTable.RouteCode,TargetTable.RouteCode),
					ElectrodeClassCode = ISNULL(SourceTable.ElectrodeClassCode,TargetTable.ElectrodeClassCode),
					CurrentCollectorClassCode = ISNULL(SourceTable.CurrentCollectorClassCode,TargetTable.CurrentCollectorClassCode),
					ElectrodeThickness = ISNULL(SourceTable.ElectrodeThickness,TargetTable.ElectrodeThickness),
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					DefectWeight = ISNULL(SourceTable.DefectWeight,TargetTable.DefectWeight),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Barcode = ISNULL(SourceTable.Barcode,TargetTable.Barcode)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeWasteNo,
						CompanyCode,
						WorkCenterCode,
						LineCode,
						JobDate,
						CalendarCode,
						RouteCode,
						ElectrodeClassCode,
						CurrentCollectorClassCode,
						ElectrodeThickness,
						MachineCode,
						DefectCode,
						DefectWeight,
						Remark,
						CreateDateTime,
						CreateUserID,
						Barcode
					)
				VALUES
					(
							SourceTable.ElectrodeWasteNo,
							SourceTable.CompanyCode,
							SourceTable.WorkCenterCode,
							SourceTable.LineCode,
							SourceTable.JobDate,
							SourceTable.CalendarCode,
							SourceTable.RouteCode,
							SourceTable.ElectrodeClassCode,
							SourceTable.CurrentCollectorClassCode,
							SourceTable.ElectrodeThickness,
							SourceTable.MachineCode,
							SourceTable.DefectCode,
							SourceTable.DefectWeight,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Barcode
					);


			-- Process Delete Table
            MERGE STB_ElectrodeWasteInfoNew AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
							    ELSE OldElectrodeWasteNo
							END AS OldElectrodeWasteNo,
							ElectrodeWasteNo,
							CompanyCode,
							WorkCenterCode,
							LineCode,
							JobDate,
							CalendarCode,
							RouteCode,
							ElectrodeClassCode,
							CurrentCollectorClassCode,
							ElectrodeThickness,
							MachineCode,
							DefectCode,
							DefectWeight,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Barcode
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeWasteNo VARCHAR(20),
										ElectrodeWasteNo VARCHAR(20),
										CompanyCode VARCHAR(20),
										WorkCenterCode VARCHAR(20),
										LineCode VARCHAR(20),
										JobDate DATETIMEOFFSET,
										CalendarCode VARCHAR(20),
										RouteCode VARCHAR(20),
										ElectrodeClassCode VARCHAR(20),
										CurrentCollectorClassCode VARCHAR(20),
										ElectrodeThickness VARCHAR(20),
										MachineCode VARCHAR(20),
										DefectCode VARCHAR(20),
										DefectWeight NUMERIC(20,3),
										Remark NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Barcode VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeWasteNo = SourceTable.ElectrodeWasteNo
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
									OldElectrodeWasteNo,
									ElectrodeWasteNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									JobDate,
									CalendarCode,
									RouteCode,
									ElectrodeClassCode,
									CurrentCollectorClassCode,
									ElectrodeThickness,
									MachineCode,
									DefectCode,
									DefectWeight,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeWasteNo VARCHAR(20),
											 ElectrodeWasteNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CalendarCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 ElectrodeClassCode VARCHAR(20),
											 CurrentCollectorClassCode VARCHAR(20),
											 ElectrodeThickness VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectWeight NUMERIC(20,3),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
										ELSE OldElectrodeWasteNo
									END AS OldElectrodeWasteNo,
									ElectrodeWasteNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									JobDate,
									CalendarCode,
									RouteCode,
									ElectrodeClassCode,
									CurrentCollectorClassCode,
									ElectrodeThickness,
									MachineCode,
									DefectCode,
									DefectWeight,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeWasteNo VARCHAR(20),
											 ElectrodeWasteNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CalendarCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 ElectrodeClassCode VARCHAR(20),
											 CurrentCollectorClassCode VARCHAR(20),
											 ElectrodeThickness VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectWeight NUMERIC(20,3),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeWasteNo IS NULL THEN ElectrodeWasteNo
										ELSE OldElectrodeWasteNo
									END AS OldElectrodeWasteNo,
									ElectrodeWasteNo,
									CompanyCode,
									WorkCenterCode,
									LineCode,
									JobDate,
									CalendarCode,
									RouteCode,
									ElectrodeClassCode,
									CurrentCollectorClassCode,
									ElectrodeThickness,
									MachineCode,
									DefectCode,
									DefectWeight,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Barcode
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeWasteNo VARCHAR(20),
											 ElectrodeWasteNo VARCHAR(20),
											 CompanyCode VARCHAR(20),
											 WorkCenterCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 JobDate DATETIMEOFFSET,
											 CalendarCode VARCHAR(20),
											 RouteCode VARCHAR(20),
											 ElectrodeClassCode VARCHAR(20),
											 CurrentCollectorClassCode VARCHAR(20),
											 ElectrodeThickness VARCHAR(20),
											 MachineCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 DefectWeight NUMERIC(20,3),
											 Remark NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Barcode VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeWasteNo,
								 @ElectrodeWasteNo,
								 @CompanyCode,
								 @WorkCenterCode,
								 @LineCode,
								 @JobDate,
								 @CalendarCode,
								 @RouteCode,
								 @ElectrodeClassCode,
								 @CurrentCollectorClassCode,
								 @ElectrodeThickness,
								 @MachineCode,
								 @DefectCode,
								 @DefectWeight,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Barcode


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeWasteInfoNew WHERE ElectrodeWasteNo = @ElectrodeWasteNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeWasteNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeWasteInfoNew',@ElectrodeWasteNo OUTPUT
                    END

                    INSERT INTO STB_ElectrodeWasteInfoNew
						(
						    ElectrodeWasteNo,
						    CompanyCode,
						    WorkCenterCode,
						    LineCode,
						    JobDate,
						    CalendarCode,
						    RouteCode,
						    ElectrodeClassCode,
						    CurrentCollectorClassCode,
						    ElectrodeThickness,
						    MachineCode,
						    DefectCode,
						    DefectWeight,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    Barcode
						)
						VALUES
						(
						    @ElectrodeWasteNo,
						    @CompanyCode,
						    @WorkCenterCode,
						    @LineCode,
						    @JobDate,
						    @CalendarCode,
						    @RouteCode,
						    @ElectrodeClassCode,
						    @CurrentCollectorClassCode,
						    @ElectrodeThickness,
						    @MachineCode,
						    @DefectCode,
						    @DefectWeight,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @Barcode
						)


						-- Mr.Manh update 2026-04-01
						update STB_ElectrodeWasteInfoNew
						set ElectrodeThickness = SUBSTRING(ElectrodeThickness, 1, CHARINDEX('.', ElectrodeThickness) - 1)
						where ElectrodeThickness LIKE '%.00%'



				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeWasteInfoNew
						SET
						    ElectrodeWasteNo =   ISNULL(@ElectrodeWasteNo,ElectrodeWasteNo),
						    CompanyCode =   ISNULL(@CompanyCode,CompanyCode),
						    WorkCenterCode =   ISNULL(@WorkCenterCode,WorkCenterCode),
						    LineCode =   ISNULL(@LineCode,LineCode),
						    JobDate =   ISNULL(@JobDate,JobDate),
						    CalendarCode =   ISNULL(@CalendarCode,CalendarCode),
						    RouteCode =   ISNULL(@RouteCode,RouteCode),
						    ElectrodeClassCode =   ISNULL(@ElectrodeClassCode,ElectrodeClassCode),
						    CurrentCollectorClassCode =   ISNULL(@CurrentCollectorClassCode,CurrentCollectorClassCode),
						    ElectrodeThickness =   ISNULL(@ElectrodeThickness,ElectrodeThickness),
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    DefectCode =   ISNULL(@DefectCode,DefectCode),
						    DefectWeight =   ISNULL(@DefectWeight,DefectWeight),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    Barcode =   ISNULL(@Barcode,Barcode)
						WHERE
						    ElectrodeWasteNo = @OldElectrodeWasteNo

						-- Mr.Manh update 2026-04-01
						update STB_ElectrodeWasteInfoNew
						set ElectrodeThickness = SUBSTRING(ElectrodeThickness, 1, CHARINDEX('.', ElectrodeThickness) - 1)
						where ElectrodeThickness LIKE '%.00%'

                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeWasteInfoNew
						WHERE
						    ElectrodeWasteNo = @OldElectrodeWasteNo
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
