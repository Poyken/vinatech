
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-17
-- Browsable : true
-- Group : 생산관리
-- Description:	전극혼합단계정
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeStep_iud]
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
  DECLARE @OldProdCode VARCHAR(20)
  DECLARE @Oldseq INT
  DECLARE @OldElectrodeStepCode VARCHAR(10)
  DECLARE @OldMaterialCode VARCHAR(20)
  DECLARE @ProdCode VARCHAR(20)
  DECLARE @seq INT
  DECLARE @ElectrodeStepCode VARCHAR(10)
  DECLARE @MaterialCode VARCHAR(20)
  DECLARE @StdMinVal NUMERIC(20,5)
  DECLARE @StdMaxVal NUMERIC(20,5)
  DECLARE @WorkTime NUMERIC(20,5)
  DECLARE @HighSpeedSpin NUMERIC(20,5)
  DECLARE @LowSpeedSpin NUMERIC(20,5)
  DECLARE @Remark VARCHAR(500)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeStep',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeStep AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN Oldseq IS NULL THEN seq
							    ELSE Oldseq
							END AS Oldseq,
							CASE
							    WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
							    ELSE OldElectrodeStepCode
							END AS OldElectrodeStepCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							ProdCode,
							seq,
							ElectrodeStepCode,
							MaterialCode,
							StdMinVal,
							StdMaxVal,
							WorkTime,
							HighSpeedSpin,
							LowSpeedSpin,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										Oldseq INT,
										OldElectrodeStepCode VARCHAR(10),
										OldMaterialCode VARCHAR(20),
										ProdCode VARCHAR(20),
										seq INT,
										ElectrodeStepCode VARCHAR(10),
										MaterialCode VARCHAR(20),
										StdMinVal NUMERIC(20,5),
										StdMaxVal NUMERIC(20,5),
										WorkTime NUMERIC(20,5),
										HighSpeedSpin NUMERIC(20,5),
										LowSpeedSpin NUMERIC(20,5),
										Remark VARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode AND
					TargetTable.seq = SourceTable.seq AND
					TargetTable.ElectrodeStepCode = SourceTable.ElectrodeStepCode AND
					TargetTable.MaterialCode = SourceTable.MaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					seq = ISNULL(SourceTable.seq,TargetTable.seq),
					ElectrodeStepCode = ISNULL(SourceTable.ElectrodeStepCode,TargetTable.ElectrodeStepCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					StdMinVal = ISNULL(SourceTable.StdMinVal,TargetTable.StdMinVal),
					StdMaxVal = ISNULL(SourceTable.StdMaxVal,TargetTable.StdMaxVal),
					WorkTime = ISNULL(SourceTable.WorkTime,TargetTable.WorkTime),
					HighSpeedSpin = ISNULL(SourceTable.HighSpeedSpin,TargetTable.HighSpeedSpin),
					LowSpeedSpin = ISNULL(SourceTable.LowSpeedSpin,TargetTable.LowSpeedSpin),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						seq,
						ElectrodeStepCode,
						MaterialCode,
						StdMinVal,
						StdMaxVal,
						WorkTime,
						HighSpeedSpin,
						LowSpeedSpin,
						Remark,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.seq,
							SourceTable.ElectrodeStepCode,
							SourceTable.MaterialCode,
							SourceTable.StdMinVal,
							SourceTable.StdMaxVal,
							SourceTable.WorkTime,
							SourceTable.HighSpeedSpin,
							SourceTable.LowSpeedSpin,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ElectrodeStep AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN Oldseq IS NULL THEN seq
							    ELSE Oldseq
							END AS Oldseq,
							CASE
							    WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
							    ELSE OldElectrodeStepCode
							END AS OldElectrodeStepCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							ProdCode,
							seq,
							ElectrodeStepCode,
							MaterialCode,
							StdMinVal,
							StdMaxVal,
							WorkTime,
							HighSpeedSpin,
							LowSpeedSpin,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										Oldseq INT,
										OldElectrodeStepCode VARCHAR(10),
										OldMaterialCode VARCHAR(20),
										ProdCode VARCHAR(20),
										seq INT,
										ElectrodeStepCode VARCHAR(10),
										MaterialCode VARCHAR(20),
										StdMinVal NUMERIC(20,5),
										StdMaxVal NUMERIC(20,5),
										WorkTime NUMERIC(20,5),
										HighSpeedSpin NUMERIC(20,5),
										LowSpeedSpin NUMERIC(20,5),
										Remark VARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.OldProdCode AND
					TargetTable.seq = SourceTable.Oldseq AND
					TargetTable.ElectrodeStepCode = SourceTable.OldElectrodeStepCode AND
					TargetTable.MaterialCode = SourceTable.OldMaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					seq = ISNULL(SourceTable.seq,TargetTable.seq),
					ElectrodeStepCode = ISNULL(SourceTable.ElectrodeStepCode,TargetTable.ElectrodeStepCode),
					MaterialCode = ISNULL(SourceTable.MaterialCode,TargetTable.MaterialCode),
					StdMinVal = ISNULL(SourceTable.StdMinVal,TargetTable.StdMinVal),
					StdMaxVal = ISNULL(SourceTable.StdMaxVal,TargetTable.StdMaxVal),
					WorkTime = ISNULL(SourceTable.WorkTime,TargetTable.WorkTime),
					HighSpeedSpin = ISNULL(SourceTable.HighSpeedSpin,TargetTable.HighSpeedSpin),
					LowSpeedSpin = ISNULL(SourceTable.LowSpeedSpin,TargetTable.LowSpeedSpin),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						seq,
						ElectrodeStepCode,
						MaterialCode,
						StdMinVal,
						StdMaxVal,
						WorkTime,
						HighSpeedSpin,
						LowSpeedSpin,
						Remark,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.seq,
							SourceTable.ElectrodeStepCode,
							SourceTable.MaterialCode,
							SourceTable.StdMinVal,
							SourceTable.StdMaxVal,
							SourceTable.WorkTime,
							SourceTable.HighSpeedSpin,
							SourceTable.LowSpeedSpin,
							SourceTable.Remark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ElectrodeStep AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN Oldseq IS NULL THEN seq
							    ELSE Oldseq
							END AS Oldseq,
							CASE
							    WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
							    ELSE OldElectrodeStepCode
							END AS OldElectrodeStepCode,
							CASE
							    WHEN OldMaterialCode IS NULL THEN MaterialCode
							    ELSE OldMaterialCode
							END AS OldMaterialCode,
							ProdCode,
							seq,
							ElectrodeStepCode,
							MaterialCode,
							StdMinVal,
							StdMaxVal,
							WorkTime,
							HighSpeedSpin,
							LowSpeedSpin,
							Remark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										Oldseq INT,
										OldElectrodeStepCode VARCHAR(10),
										OldMaterialCode VARCHAR(20),
										ProdCode VARCHAR(20),
										seq INT,
										ElectrodeStepCode VARCHAR(10),
										MaterialCode VARCHAR(20),
										StdMinVal NUMERIC(20,5),
										StdMaxVal NUMERIC(20,5),
										WorkTime NUMERIC(20,5),
										HighSpeedSpin NUMERIC(20,5),
										LowSpeedSpin NUMERIC(20,5),
										Remark VARCHAR(500),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode AND
					TargetTable.seq = SourceTable.seq AND
					TargetTable.ElectrodeStepCode = SourceTable.ElectrodeStepCode AND
					TargetTable.MaterialCode = SourceTable.MaterialCode
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
									OldProdCode,
									Oldseq,
									OldElectrodeStepCode,
									OldMaterialCode,
									ProdCode,
									seq,
									ElectrodeStepCode,
									MaterialCode,
									StdMinVal,
									StdMaxVal,
									WorkTime,
									HighSpeedSpin,
									LowSpeedSpin,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 Oldseq INT,
											 OldElectrodeStepCode VARCHAR(10),
											 OldMaterialCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 seq INT,
											 ElectrodeStepCode VARCHAR(10),
											 MaterialCode VARCHAR(20),
											 StdMinVal NUMERIC(20,5),
											 StdMaxVal NUMERIC(20,5),
											 WorkTime NUMERIC(20,5),
											 HighSpeedSpin NUMERIC(20,5),
											 LowSpeedSpin NUMERIC(20,5),
											 Remark VARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									CASE 
										WHEN Oldseq IS NULL THEN seq
										ELSE Oldseq
									END AS Oldseq,
									CASE 
										WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
										ELSE OldElectrodeStepCode
									END AS OldElectrodeStepCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									ProdCode,
									seq,
									ElectrodeStepCode,
									MaterialCode,
									StdMinVal,
									StdMaxVal,
									WorkTime,
									HighSpeedSpin,
									LowSpeedSpin,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 Oldseq INT,
											 OldElectrodeStepCode VARCHAR(10),
											 OldMaterialCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 seq INT,
											 ElectrodeStepCode VARCHAR(10),
											 MaterialCode VARCHAR(20),
											 StdMinVal NUMERIC(20,5),
											 StdMaxVal NUMERIC(20,5),
											 WorkTime NUMERIC(20,5),
											 HighSpeedSpin NUMERIC(20,5),
											 LowSpeedSpin NUMERIC(20,5),
											 Remark VARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									CASE 
										WHEN Oldseq IS NULL THEN seq
										ELSE Oldseq
									END AS Oldseq,
									CASE 
										WHEN OldElectrodeStepCode IS NULL THEN ElectrodeStepCode
										ELSE OldElectrodeStepCode
									END AS OldElectrodeStepCode,
									CASE 
										WHEN OldMaterialCode IS NULL THEN MaterialCode
										ELSE OldMaterialCode
									END AS OldMaterialCode,
									ProdCode,
									seq,
									ElectrodeStepCode,
									MaterialCode,
									StdMinVal,
									StdMaxVal,
									WorkTime,
									HighSpeedSpin,
									LowSpeedSpin,
									Remark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 Oldseq INT,
											 OldElectrodeStepCode VARCHAR(10),
											 OldMaterialCode VARCHAR(20),
											 ProdCode VARCHAR(20),
											 seq INT,
											 ElectrodeStepCode VARCHAR(10),
											 MaterialCode VARCHAR(20),
											 StdMinVal NUMERIC(20,5),
											 StdMaxVal NUMERIC(20,5),
											 WorkTime NUMERIC(20,5),
											 HighSpeedSpin NUMERIC(20,5),
											 LowSpeedSpin NUMERIC(20,5),
											 Remark VARCHAR(500),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldProdCode,
								 @Oldseq,
								 @OldElectrodeStepCode,
								 @OldMaterialCode,
								 @ProdCode,
								 @seq,
								 @ElectrodeStepCode,
								 @MaterialCode,
								 @StdMinVal,
								 @StdMaxVal,
								 @WorkTime,
								 @HighSpeedSpin,
								 @LowSpeedSpin,
								 @Remark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeStep WHERE ProdCode = @ProdCode AND seq = @seq AND ElectrodeStepCode = @ElectrodeStepCode AND MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProdCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeStep',@ProdCode OUTPUT
                    END

                    INSERT INTO STB_ElectrodeStep
						(
						    ProdCode,
						    seq,
						    ElectrodeStepCode,
						    MaterialCode,
						    StdMinVal,
						    StdMaxVal,
						    WorkTime,
						    HighSpeedSpin,
						    LowSpeedSpin,
						    Remark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ProdCode,
						    @seq,
						    @ElectrodeStepCode,
						    @MaterialCode,
						    @StdMinVal,
						    @StdMaxVal,
						    @WorkTime,
						    @HighSpeedSpin,
						    @LowSpeedSpin,
						    @Remark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeStep
						SET
						    ProdCode =   ISNULL(@ProdCode,ProdCode),
						    seq =   ISNULL(@seq,seq),
						    ElectrodeStepCode =   ISNULL(@ElectrodeStepCode,ElectrodeStepCode),
						    MaterialCode =   ISNULL(@MaterialCode,MaterialCode),
						    StdMinVal =   ISNULL(@StdMinVal,StdMinVal),
						    StdMaxVal =   ISNULL(@StdMaxVal,StdMaxVal),
						    WorkTime =   ISNULL(@WorkTime,WorkTime),
						    HighSpeedSpin =   ISNULL(@HighSpeedSpin,HighSpeedSpin),
						    LowSpeedSpin =   ISNULL(@LowSpeedSpin,LowSpeedSpin),
						    Remark =   ISNULL(@Remark,Remark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ProdCode = @OldProdCode AND
						    seq = @Oldseq AND
						    ElectrodeStepCode = @OldElectrodeStepCode AND
						    MaterialCode = @OldMaterialCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeStep
						WHERE
						    ProdCode = @OldProdCode AND
						    seq = @Oldseq AND
						    ElectrodeStepCode = @OldElectrodeStepCode AND
						    MaterialCode = @OldMaterialCode
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
