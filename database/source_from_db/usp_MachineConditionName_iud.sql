
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MachineConditionName_iud]
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
  DECLARE @OldConditionColumnIndex INT
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @ConditionColumnIndex INT
  DECLARE @ConditionName NVARCHAR(50)
  DECLARE @IsAlarm VARCHAR(1)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MachineConditionName',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MachineConditionName AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN OldConditionColumnIndex IS NULL THEN ConditionColumnIndex
							    ELSE OldConditionColumnIndex
							END AS OldConditionColumnIndex,
							MachineCode,
							ConditionColumnIndex,
							ConditionName,
							IsAlarm,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldConditionColumnIndex INT,
										MachineCode VARCHAR(20),
										ConditionColumnIndex INT,
										ConditionName NVARCHAR(50),
										IsAlarm VARCHAR(1),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.ConditionColumnIndex = SourceTable.ConditionColumnIndex
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					ConditionColumnIndex = ISNULL(SourceTable.ConditionColumnIndex,TargetTable.ConditionColumnIndex),
					ConditionName = ISNULL(SourceTable.ConditionName,TargetTable.ConditionName),
					IsAlarm = ISNULL(SourceTable.IsAlarm,TargetTable.IsAlarm),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						ConditionColumnIndex,
						ConditionName,
						IsAlarm,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.ConditionColumnIndex,
							SourceTable.ConditionName,
							SourceTable.IsAlarm,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MachineConditionName AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN OldConditionColumnIndex IS NULL THEN ConditionColumnIndex
							    ELSE OldConditionColumnIndex
							END AS OldConditionColumnIndex,
							MachineCode,
							ConditionColumnIndex,
							ConditionName,
							IsAlarm,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldConditionColumnIndex INT,
										MachineCode VARCHAR(20),
										ConditionColumnIndex INT,
										ConditionName NVARCHAR(50),
										IsAlarm VARCHAR(1),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.OldMachineCode AND
					TargetTable.ConditionColumnIndex = SourceTable.OldConditionColumnIndex
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					ConditionColumnIndex = ISNULL(SourceTable.ConditionColumnIndex,TargetTable.ConditionColumnIndex),
					ConditionName = ISNULL(SourceTable.ConditionName,TargetTable.ConditionName),
					IsAlarm = ISNULL(SourceTable.IsAlarm,TargetTable.IsAlarm),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						ConditionColumnIndex,
						ConditionName,
						IsAlarm,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.ConditionColumnIndex,
							SourceTable.ConditionName,
							SourceTable.IsAlarm,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MachineConditionName AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMachineCode IS NULL THEN MachineCode
							    ELSE OldMachineCode
							END AS OldMachineCode,
							CASE
							    WHEN OldConditionColumnIndex IS NULL THEN ConditionColumnIndex
							    ELSE OldConditionColumnIndex
							END AS OldConditionColumnIndex,
							MachineCode,
							ConditionColumnIndex,
							ConditionName,
							IsAlarm,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldConditionColumnIndex INT,
										MachineCode VARCHAR(20),
										ConditionColumnIndex INT,
										ConditionName NVARCHAR(50),
										IsAlarm VARCHAR(1),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.ConditionColumnIndex = SourceTable.ConditionColumnIndex
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
									OldConditionColumnIndex,
									MachineCode,
									ConditionColumnIndex,
									ConditionName,
									IsAlarm,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldConditionColumnIndex INT,
											 MachineCode VARCHAR(20),
											 ConditionColumnIndex INT,
											 ConditionName NVARCHAR(50),
											 IsAlarm VARCHAR(1),
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
									CASE 
										WHEN OldConditionColumnIndex IS NULL THEN ConditionColumnIndex
										ELSE OldConditionColumnIndex
									END AS OldConditionColumnIndex,
									MachineCode,
									ConditionColumnIndex,
									ConditionName,
									IsAlarm,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldConditionColumnIndex INT,
											 MachineCode VARCHAR(20),
											 ConditionColumnIndex INT,
											 ConditionName NVARCHAR(50),
											 IsAlarm VARCHAR(1),
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
									CASE 
										WHEN OldConditionColumnIndex IS NULL THEN ConditionColumnIndex
										ELSE OldConditionColumnIndex
									END AS OldConditionColumnIndex,
									MachineCode,
									ConditionColumnIndex,
									ConditionName,
									IsAlarm,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldConditionColumnIndex INT,
											 MachineCode VARCHAR(20),
											 ConditionColumnIndex INT,
											 ConditionName NVARCHAR(50),
											 IsAlarm VARCHAR(1),
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
								 @OldConditionColumnIndex,
								 @MachineCode,
								 @ConditionColumnIndex,
								 @ConditionName,
								 @IsAlarm,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MachineConditionName WHERE MachineCode = @MachineCode AND ConditionColumnIndex = @ConditionColumnIndex) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachineCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MachineConditionName',@MachineCode OUTPUT
                    END

                    INSERT INTO STB_MachineConditionName
						(
						    MachineCode,
						    ConditionColumnIndex,
						    ConditionName,
						    IsAlarm,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MachineCode,
						    @ConditionColumnIndex,
						    @ConditionName,
						    @IsAlarm,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MachineConditionName
						SET
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    ConditionColumnIndex =   ISNULL(@ConditionColumnIndex,ConditionColumnIndex),
						    ConditionName =   ISNULL(@ConditionName,ConditionName),
						    IsAlarm =   ISNULL(@IsAlarm,IsAlarm),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MachineCode = @OldMachineCode AND
						    ConditionColumnIndex = @OldConditionColumnIndex
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MachineConditionName
						WHERE
						    MachineCode = @OldMachineCode AND
						    ConditionColumnIndex = @OldConditionColumnIndex
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
