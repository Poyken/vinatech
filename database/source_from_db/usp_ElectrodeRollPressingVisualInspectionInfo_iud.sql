
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-25
-- Browsable : true
-- Group : 생산관리
-- Description:	전극롤프레스외관검사정보
-- Modified: Mr.Tung on 31-July-2021
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeRollPressingVisualInspectionInfo_iud]
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
  DECLARE @OldMeasureTimeCode VARCHAR(1)
  DECLARE @OldSeq INT
  DECLARE @ElectrodeLotNumber VARCHAR(20)
  DECLARE @MeasureTimeCode VARCHAR(1)
  DECLARE @Seq INT
  DECLARE @LeftValue NUMERIC(20,5)
  DECLARE @MiddleValue NUMERIC(20,5)
  DECLARE @RightValue NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeRollPressingVisualInspectionInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeRollPressingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldMeasureTimeCode VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										MeasureTimeCode VARCHAR(20),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.MeasureTimeCode = SourceTable.MeasureTimeCode AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					MeasureTimeCode = ISNULL(SourceTable.MeasureTimeCode,TargetTable.MeasureTimeCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					LeftValue = ISNULL(SourceTable.LeftValue,TargetTable.LeftValue),
					MiddleValue = ISNULL(SourceTable.MiddleValue,TargetTable.MiddleValue),
					RightValue = ISNULL(SourceTable.RightValue,TargetTable.RightValue),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MeasureTimeCode,
						Seq,
						LeftValue,
						MiddleValue,
						RightValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MeasureTimeCode,
							SourceTable.Seq,
							SourceTable.LeftValue,
							SourceTable.MiddleValue,
							SourceTable.RightValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeRollPressingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldMeasureTimeCode VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										MeasureTimeCode VARCHAR(20),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.OldElectrodeLotNumber AND
					TargetTable.MeasureTimeCode = SourceTable.OldMeasureTimeCode AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ElectrodeLotNumber = ISNULL(SourceTable.ElectrodeLotNumber,TargetTable.ElectrodeLotNumber),
					MeasureTimeCode = ISNULL(SourceTable.MeasureTimeCode,TargetTable.MeasureTimeCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					LeftValue = ISNULL(SourceTable.LeftValue,TargetTable.LeftValue),
					MiddleValue = ISNULL(SourceTable.MiddleValue,TargetTable.MiddleValue),
					RightValue = ISNULL(SourceTable.RightValue,TargetTable.RightValue),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ElectrodeLotNumber,
						MeasureTimeCode,
						Seq,
						LeftValue,
						MiddleValue,
						RightValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ElectrodeLotNumber,
							SourceTable.MeasureTimeCode,
							SourceTable.Seq,
							SourceTable.LeftValue,
							SourceTable.MiddleValue,
							SourceTable.RightValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeRollPressingVisualInspectionInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
							    ELSE OldElectrodeLotNumber
							END AS OldElectrodeLotNumber,
							CASE
							    WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
							    ELSE OldMeasureTimeCode
							END AS OldMeasureTimeCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ElectrodeLotNumber,
							MeasureTimeCode,
							Seq,
							LeftValue,
							MiddleValue,
							RightValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldElectrodeLotNumber VARCHAR(20),
										OldMeasureTimeCode VARCHAR(20),
										OldSeq INT,
										ElectrodeLotNumber VARCHAR(20),
										MeasureTimeCode VARCHAR(20),
										Seq INT,
										LeftValue NUMERIC(20,5),
										MiddleValue NUMERIC(20,5),
										RightValue NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ElectrodeLotNumber = SourceTable.ElectrodeLotNumber AND
					TargetTable.MeasureTimeCode = SourceTable.MeasureTimeCode AND
					TargetTable.Seq = SourceTable.Seq
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
									OldMeasureTimeCode,
									OldSeq,
									ElectrodeLotNumber,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldMeasureTimeCode VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 MeasureTimeCode VARCHAR(20),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
										ELSE OldElectrodeLotNumber
									END AS OldElectrodeLotNumber,
									CASE 
										WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
										ELSE OldMeasureTimeCode
									END AS OldMeasureTimeCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldMeasureTimeCode VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 MeasureTimeCode VARCHAR(20),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldElectrodeLotNumber IS NULL THEN ElectrodeLotNumber
										ELSE OldElectrodeLotNumber
									END AS OldElectrodeLotNumber,
									CASE 
										WHEN OldMeasureTimeCode IS NULL THEN MeasureTimeCode
										ELSE OldMeasureTimeCode
									END AS OldMeasureTimeCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ElectrodeLotNumber,
									MeasureTimeCode,
									Seq,
									LeftValue,
									MiddleValue,
									RightValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldElectrodeLotNumber VARCHAR(20),
											 OldMeasureTimeCode VARCHAR(20),
											 OldSeq INT,
											 ElectrodeLotNumber VARCHAR(20),
											 MeasureTimeCode VARCHAR(20),
											 Seq INT,
											 LeftValue NUMERIC(20,5),
											 MiddleValue NUMERIC(20,5),
											 RightValue NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldElectrodeLotNumber,
								 @OldMeasureTimeCode,
								 @OldSeq,
								 @ElectrodeLotNumber,
								 @MeasureTimeCode,
								 @Seq,
								 @LeftValue,
								 @MiddleValue,
								 @RightValue,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END

				if(@MeasureTimeCode='AUTO') continue;  --add by Mr.Tung on 31-July-2021

                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeRollPressingVisualInspectionInfo WHERE ElectrodeLotNumber = @ElectrodeLotNumber AND MeasureTimeCode = @MeasureTimeCode AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ElectrodeLotNumber)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeRollPressingVisualInspectionInfo',@ElectrodeLotNumber OUTPUT
                    END

                    INSERT INTO STB_ElectrodeRollPressingVisualInspectionInfo
						(
						    ElectrodeLotNumber,
						    MeasureTimeCode,
						    Seq,
						    LeftValue,
						    MiddleValue,
						    RightValue,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ElectrodeLotNumber,
						    @MeasureTimeCode,
						    @Seq,
						    @LeftValue,
						    @MiddleValue,
						    @RightValue,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeRollPressingVisualInspectionInfo
						SET
						    ElectrodeLotNumber =   ISNULL(@ElectrodeLotNumber,ElectrodeLotNumber),
						    MeasureTimeCode =   ISNULL(@MeasureTimeCode,MeasureTimeCode),
						    Seq =   ISNULL(@Seq,Seq),
						    LeftValue =   ISNULL(@LeftValue,LeftValue),
						    MiddleValue =   ISNULL(@MiddleValue,MiddleValue),
						    RightValue =   ISNULL(@RightValue,RightValue),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    MeasureTimeCode = @OldMeasureTimeCode AND
						    Seq = @OldSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeRollPressingVisualInspectionInfo
						WHERE
						    ElectrodeLotNumber = @OldElectrodeLotNumber AND
						    MeasureTimeCode = @OldMeasureTimeCode AND
						    Seq = @OldSeq
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
