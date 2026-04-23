
-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-05
-- Browsable : true
-- Group : 사출&프레스관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldMachineConditionSpec_iud]
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
  DECLARE @OldMoldNumber VARCHAR(50)
  DECLARE @MachineCode VARCHAR(20)
  DECLARE @ConditionColumnIndex INT
  DECLARE @MoldNumber VARCHAR(50)
  DECLARE @SpecValue NUMERIC(10,2)
  DECLARE @UpperLimit NUMERIC(10,2)
  DECLARE @LowerLimit NUMERIC(10,2)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldMachineConditionSpec',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldMachineConditionSpec AS TargetTable
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
							CASE
							    WHEN OldMoldNumber IS NULL THEN MoldNumber
							    ELSE OldMoldNumber
							END AS OldMoldNumber,
							MachineCode,
							ConditionColumnIndex,
							MoldNumber,
							SpecValue,
							UpperLimit,
							LowerLimit,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldConditionColumnIndex INT,
										OldMoldNumber VARCHAR(50),
										MachineCode VARCHAR(20),
										ConditionColumnIndex INT,
										MoldNumber VARCHAR(50),
										SpecValue NUMERIC(10,2),
										UpperLimit NUMERIC(10,2),
										LowerLimit NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.ConditionColumnIndex = SourceTable.ConditionColumnIndex AND
					TargetTable.MoldNumber = SourceTable.MoldNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					ConditionColumnIndex = ISNULL(SourceTable.ConditionColumnIndex,TargetTable.ConditionColumnIndex),
					MoldNumber = ISNULL(SourceTable.MoldNumber,TargetTable.MoldNumber),
					SpecValue = ISNULL(SourceTable.SpecValue,TargetTable.SpecValue),
					UpperLimit = ISNULL(SourceTable.UpperLimit,TargetTable.UpperLimit),
					LowerLimit = ISNULL(SourceTable.LowerLimit,TargetTable.LowerLimit),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						ConditionColumnIndex,
						MoldNumber,
						SpecValue,
						UpperLimit,
						LowerLimit,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.ConditionColumnIndex,
							SourceTable.MoldNumber,
							SourceTable.SpecValue,
							SourceTable.UpperLimit,
							SourceTable.LowerLimit,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldMachineConditionSpec AS TargetTable
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
							CASE
							    WHEN OldMoldNumber IS NULL THEN MoldNumber
							    ELSE OldMoldNumber
							END AS OldMoldNumber,
							MachineCode,
							ConditionColumnIndex,
							MoldNumber,
							SpecValue,
							UpperLimit,
							LowerLimit,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldConditionColumnIndex INT,
										OldMoldNumber VARCHAR(50),
										MachineCode VARCHAR(20),
										ConditionColumnIndex INT,
										MoldNumber VARCHAR(50),
										SpecValue NUMERIC(10,2),
										UpperLimit NUMERIC(10,2),
										LowerLimit NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.OldMachineCode AND
					TargetTable.ConditionColumnIndex = SourceTable.OldConditionColumnIndex AND
					TargetTable.MoldNumber = SourceTable.OldMoldNumber
				)

			WHEN MATCHED THEN
				UPDATE SET
					MachineCode = ISNULL(SourceTable.MachineCode,TargetTable.MachineCode),
					ConditionColumnIndex = ISNULL(SourceTable.ConditionColumnIndex,TargetTable.ConditionColumnIndex),
					MoldNumber = ISNULL(SourceTable.MoldNumber,TargetTable.MoldNumber),
					SpecValue = ISNULL(SourceTable.SpecValue,TargetTable.SpecValue),
					UpperLimit = ISNULL(SourceTable.UpperLimit,TargetTable.UpperLimit),
					LowerLimit = ISNULL(SourceTable.LowerLimit,TargetTable.LowerLimit),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MachineCode,
						ConditionColumnIndex,
						MoldNumber,
						SpecValue,
						UpperLimit,
						LowerLimit,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MachineCode,
							SourceTable.ConditionColumnIndex,
							SourceTable.MoldNumber,
							SourceTable.SpecValue,
							SourceTable.UpperLimit,
							SourceTable.LowerLimit,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldMachineConditionSpec AS TargetTable
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
							CASE
							    WHEN OldMoldNumber IS NULL THEN MoldNumber
							    ELSE OldMoldNumber
							END AS OldMoldNumber,
							MachineCode,
							ConditionColumnIndex,
							MoldNumber,
							SpecValue,
							UpperLimit,
							LowerLimit,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMachineCode VARCHAR(20),
										OldConditionColumnIndex INT,
										OldMoldNumber VARCHAR(50),
										MachineCode VARCHAR(20),
										ConditionColumnIndex INT,
										MoldNumber VARCHAR(50),
										SpecValue NUMERIC(10,2),
										UpperLimit NUMERIC(10,2),
										LowerLimit NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MachineCode = SourceTable.MachineCode AND
					TargetTable.ConditionColumnIndex = SourceTable.ConditionColumnIndex AND
					TargetTable.MoldNumber = SourceTable.MoldNumber
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
									OldMoldNumber,
									MachineCode,
									ConditionColumnIndex,
									MoldNumber,
									SpecValue,
									UpperLimit,
									LowerLimit,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldConditionColumnIndex INT,
											 OldMoldNumber VARCHAR(50),
											 MachineCode VARCHAR(20),
											 ConditionColumnIndex INT,
											 MoldNumber VARCHAR(50),
											 SpecValue NUMERIC(10,2),
											 UpperLimit NUMERIC(10,2),
											 LowerLimit NUMERIC(10,2),
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
									CASE 
										WHEN OldMoldNumber IS NULL THEN MoldNumber
										ELSE OldMoldNumber
									END AS OldMoldNumber,
									MachineCode,
									ConditionColumnIndex,
									MoldNumber,
									SpecValue,
									UpperLimit,
									LowerLimit,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldConditionColumnIndex INT,
											 OldMoldNumber VARCHAR(50),
											 MachineCode VARCHAR(20),
											 ConditionColumnIndex INT,
											 MoldNumber VARCHAR(50),
											 SpecValue NUMERIC(10,2),
											 UpperLimit NUMERIC(10,2),
											 LowerLimit NUMERIC(10,2),
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
									CASE 
										WHEN OldMoldNumber IS NULL THEN MoldNumber
										ELSE OldMoldNumber
									END AS OldMoldNumber,
									MachineCode,
									ConditionColumnIndex,
									MoldNumber,
									SpecValue,
									UpperLimit,
									LowerLimit,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMachineCode VARCHAR(20),
											 OldConditionColumnIndex INT,
											 OldMoldNumber VARCHAR(50),
											 MachineCode VARCHAR(20),
											 ConditionColumnIndex INT,
											 MoldNumber VARCHAR(50),
											 SpecValue NUMERIC(10,2),
											 UpperLimit NUMERIC(10,2),
											 LowerLimit NUMERIC(10,2),
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
								 @OldMoldNumber,
								 @MachineCode,
								 @ConditionColumnIndex,
								 @MoldNumber,
								 @SpecValue,
								 @UpperLimit,
								 @LowerLimit,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldMachineConditionSpec WHERE MachineCode = @MachineCode AND ConditionColumnIndex = @ConditionColumnIndex AND MoldNumber = @MoldNumber) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MachineCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MoldMachineConditionSpec',@MachineCode OUTPUT
                    END

                    INSERT INTO STB_MoldMachineConditionSpec
						(
						    MachineCode,
						    ConditionColumnIndex,
						    MoldNumber,
						    SpecValue,
						    UpperLimit,
						    LowerLimit,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MachineCode,
						    @ConditionColumnIndex,
						    @MoldNumber,
						    @SpecValue,
						    @UpperLimit,
						    @LowerLimit,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldMachineConditionSpec
						SET
						    MachineCode =   ISNULL(@MachineCode,MachineCode),
						    ConditionColumnIndex =   ISNULL(@ConditionColumnIndex,ConditionColumnIndex),
						    MoldNumber =   ISNULL(@MoldNumber,MoldNumber),
						    SpecValue =   ISNULL(@SpecValue,SpecValue),
						    UpperLimit =   ISNULL(@UpperLimit,UpperLimit),
						    LowerLimit =   ISNULL(@LowerLimit,LowerLimit),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MachineCode = @OldMachineCode AND
						    ConditionColumnIndex = @OldConditionColumnIndex AND
						    MoldNumber = @OldMoldNumber
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldMachineConditionSpec
						WHERE
						    MachineCode = @OldMachineCode AND
						    ConditionColumnIndex = @OldConditionColumnIndex AND
						    MoldNumber = @OldMoldNumber
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
