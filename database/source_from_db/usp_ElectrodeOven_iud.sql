
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-01-22
-- Browsable : true
-- Group : 생산관리
-- Description:	전극 건조로 정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ElectrodeOven_iud]
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
  DECLARE @OldSeq INT
  DECLARE @ProdCode VARCHAR(20)
  DECLARE @Seq INT
  DECLARE @DryingFurnaceName VARCHAR(20)
  DECLARE @DryingFurnaceTemp NUMERIC(20,5)
  DECLARE @DryingFurnaceAirUpperPart NUMERIC(20,5)
  DECLARE @DryingFurnaceAirLowerPart NUMERIC(20,5)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @TempUpperTolerance NUMERIC(20,5)
  DECLARE @TempLowerTolerance NUMERIC(20,5)
  DECLARE @AirUpperTolerance NUMERIC(20,5)
  DECLARE @AirLowerTolerance NUMERIC(20,5)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ElectrodeOven',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ElectrodeOven AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ProdCode,
							Seq,
							DryingFurnaceName,
							DryingFurnaceTemp,
							DryingFurnaceAirUpperPart,
							DryingFurnaceAirLowerPart,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TempUpperTolerance,
							TempLowerTolerance,
							AirUpperTolerance,
							AirLowerTolerance
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										OldSeq INT,
										ProdCode VARCHAR(20),
										Seq INT,
										DryingFurnaceName VARCHAR(20),
										DryingFurnaceTemp NUMERIC(20,5),
										DryingFurnaceAirUpperPart NUMERIC(20,5),
										DryingFurnaceAirLowerPart NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TempUpperTolerance NUMERIC(20,5),
										TempLowerTolerance NUMERIC(20,5),
										AirUpperTolerance NUMERIC(20,5),
										AirLowerTolerance NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode AND
					TargetTable.Seq = SourceTable.Seq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					DryingFurnaceName = ISNULL(SourceTable.DryingFurnaceName,TargetTable.DryingFurnaceName),
					DryingFurnaceTemp = ISNULL(SourceTable.DryingFurnaceTemp,TargetTable.DryingFurnaceTemp),
					DryingFurnaceAirUpperPart = ISNULL(SourceTable.DryingFurnaceAirUpperPart,TargetTable.DryingFurnaceAirUpperPart),
					DryingFurnaceAirLowerPart = ISNULL(SourceTable.DryingFurnaceAirLowerPart,TargetTable.DryingFurnaceAirLowerPart),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					TempUpperTolerance = ISNULL(SourceTable.TempUpperTolerance,TargetTable.TempUpperTolerance),
					TempLowerTolerance = ISNULL(SourceTable.TempLowerTolerance,TargetTable.TempLowerTolerance),
					AirUpperTolerance = ISNULL(SourceTable.AirUpperTolerance,TargetTable.AirUpperTolerance),
					AirLowerTolerance = ISNULL(SourceTable.AirLowerTolerance,TargetTable.AirLowerTolerance)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						Seq,
						DryingFurnaceName,
						DryingFurnaceTemp,
						DryingFurnaceAirUpperPart,
						DryingFurnaceAirLowerPart,
						CreateDateTime,
						CreateUserID,
						TempUpperTolerance,
						TempLowerTolerance,
						AirUpperTolerance,
						AirLowerTolerance
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.Seq,
							SourceTable.DryingFurnaceName,
							SourceTable.DryingFurnaceTemp,
							SourceTable.DryingFurnaceAirUpperPart,
							SourceTable.DryingFurnaceAirLowerPart,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.TempUpperTolerance,
							SourceTable.TempLowerTolerance,
							SourceTable.AirUpperTolerance,
							SourceTable.AirLowerTolerance
					);


			-- Process Update Table
            MERGE STB_ElectrodeOven AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ProdCode,
							Seq,
							DryingFurnaceName,
							DryingFurnaceTemp,
							DryingFurnaceAirUpperPart,
							DryingFurnaceAirLowerPart,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TempUpperTolerance,
							TempLowerTolerance,
							AirUpperTolerance,
							AirLowerTolerance
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										OldSeq INT,
										ProdCode VARCHAR(20),
										Seq INT,
										DryingFurnaceName VARCHAR(20),
										DryingFurnaceTemp NUMERIC(20,5),
										DryingFurnaceAirUpperPart NUMERIC(20,5),
										DryingFurnaceAirLowerPart NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TempUpperTolerance NUMERIC(20,5),
										TempLowerTolerance NUMERIC(20,5),
										AirUpperTolerance NUMERIC(20,5),
										AirLowerTolerance NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.OldProdCode AND
					TargetTable.Seq = SourceTable.OldSeq
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProdCode = ISNULL(SourceTable.ProdCode,TargetTable.ProdCode),
					Seq = ISNULL(SourceTable.Seq,TargetTable.Seq),
					DryingFurnaceName = ISNULL(SourceTable.DryingFurnaceName,TargetTable.DryingFurnaceName),
					DryingFurnaceTemp = ISNULL(SourceTable.DryingFurnaceTemp,TargetTable.DryingFurnaceTemp),
					DryingFurnaceAirUpperPart = ISNULL(SourceTable.DryingFurnaceAirUpperPart,TargetTable.DryingFurnaceAirUpperPart),
					DryingFurnaceAirLowerPart = ISNULL(SourceTable.DryingFurnaceAirLowerPart,TargetTable.DryingFurnaceAirLowerPart),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					TempUpperTolerance = ISNULL(SourceTable.TempUpperTolerance,TargetTable.TempUpperTolerance),
					TempLowerTolerance = ISNULL(SourceTable.TempLowerTolerance,TargetTable.TempLowerTolerance),
					AirUpperTolerance = ISNULL(SourceTable.AirUpperTolerance,TargetTable.AirUpperTolerance),
					AirLowerTolerance = ISNULL(SourceTable.AirLowerTolerance,TargetTable.AirLowerTolerance)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ProdCode,
						Seq,
						DryingFurnaceName,
						DryingFurnaceTemp,
						DryingFurnaceAirUpperPart,
						DryingFurnaceAirLowerPart,
						CreateDateTime,
						CreateUserID,
						TempUpperTolerance,
						TempLowerTolerance,
						AirUpperTolerance,
						AirLowerTolerance
					)
				VALUES
					(
							SourceTable.ProdCode,
							SourceTable.Seq,
							SourceTable.DryingFurnaceName,
							SourceTable.DryingFurnaceTemp,
							SourceTable.DryingFurnaceAirUpperPart,
							SourceTable.DryingFurnaceAirLowerPart,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.TempUpperTolerance,
							SourceTable.TempLowerTolerance,
							SourceTable.AirUpperTolerance,
							SourceTable.AirLowerTolerance
					);


			-- Process Delete Table
            MERGE STB_ElectrodeOven AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldProdCode IS NULL THEN ProdCode
							    ELSE OldProdCode
							END AS OldProdCode,
							CASE
							    WHEN OldSeq IS NULL THEN Seq
							    ELSE OldSeq
							END AS OldSeq,
							ProdCode,
							Seq,
							DryingFurnaceName,
							DryingFurnaceTemp,
							DryingFurnaceAirUpperPart,
							DryingFurnaceAirLowerPart,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							TempUpperTolerance,
							TempLowerTolerance,
							AirUpperTolerance,
							AirLowerTolerance
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldProdCode VARCHAR(20),
										OldSeq INT,
										ProdCode VARCHAR(20),
										Seq INT,
										DryingFurnaceName VARCHAR(20),
										DryingFurnaceTemp NUMERIC(20,5),
										DryingFurnaceAirUpperPart NUMERIC(20,5),
										DryingFurnaceAirLowerPart NUMERIC(20,5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										TempUpperTolerance NUMERIC(20,5),
										TempLowerTolerance NUMERIC(20,5),
										AirUpperTolerance NUMERIC(20,5),
										AirLowerTolerance NUMERIC(20,5)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ProdCode = SourceTable.ProdCode AND
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
									OldProdCode,
									OldSeq,
									ProdCode,
									Seq,
									DryingFurnaceName,
									DryingFurnaceTemp,
									DryingFurnaceAirUpperPart,
									DryingFurnaceAirLowerPart,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TempUpperTolerance,
									TempLowerTolerance,
									AirUpperTolerance,
									AirLowerTolerance
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 OldSeq INT,
											 ProdCode VARCHAR(20),
											 Seq INT,
											 DryingFurnaceName VARCHAR(20),
											 DryingFurnaceTemp NUMERIC(20,5),
											 DryingFurnaceAirUpperPart NUMERIC(20,5),
											 DryingFurnaceAirLowerPart NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TempUpperTolerance NUMERIC(20,5),
											 TempLowerTolerance NUMERIC(20,5),
											 AirUpperTolerance NUMERIC(20,5),
											 AirLowerTolerance NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ProdCode,
									Seq,
									DryingFurnaceName,
									DryingFurnaceTemp,
									DryingFurnaceAirUpperPart,
									DryingFurnaceAirLowerPart,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TempUpperTolerance,
									TempLowerTolerance,
									AirUpperTolerance,
									AirLowerTolerance
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 OldSeq INT,
											 ProdCode VARCHAR(20),
											 Seq INT,
											 DryingFurnaceName VARCHAR(20),
											 DryingFurnaceTemp NUMERIC(20,5),
											 DryingFurnaceAirUpperPart NUMERIC(20,5),
											 DryingFurnaceAirLowerPart NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TempUpperTolerance NUMERIC(20,5),
											 TempLowerTolerance NUMERIC(20,5),
											 AirUpperTolerance NUMERIC(20,5),
											 AirLowerTolerance NUMERIC(20,5)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldProdCode IS NULL THEN ProdCode
										ELSE OldProdCode
									END AS OldProdCode,
									CASE 
										WHEN OldSeq IS NULL THEN Seq
										ELSE OldSeq
									END AS OldSeq,
									ProdCode,
									Seq,
									DryingFurnaceName,
									DryingFurnaceTemp,
									DryingFurnaceAirUpperPart,
									DryingFurnaceAirLowerPart,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									TempUpperTolerance,
									TempLowerTolerance,
									AirUpperTolerance,
									AirLowerTolerance
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldProdCode VARCHAR(20),
											 OldSeq INT,
											 ProdCode VARCHAR(20),
											 Seq INT,
											 DryingFurnaceName VARCHAR(20),
											 DryingFurnaceTemp NUMERIC(20,5),
											 DryingFurnaceAirUpperPart NUMERIC(20,5),
											 DryingFurnaceAirLowerPart NUMERIC(20,5),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 TempUpperTolerance NUMERIC(20,5),
											 TempLowerTolerance NUMERIC(20,5),
											 AirUpperTolerance NUMERIC(20,5),
											 AirLowerTolerance NUMERIC(20,5)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldProdCode,
								 @OldSeq,
								 @ProdCode,
								 @Seq,
								 @DryingFurnaceName,
								 @DryingFurnaceTemp,
								 @DryingFurnaceAirUpperPart,
								 @DryingFurnaceAirLowerPart,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @TempUpperTolerance,
								 @TempLowerTolerance,
								 @AirUpperTolerance,
								 @AirLowerTolerance


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ElectrodeOven WHERE ProdCode = @ProdCode AND Seq = @Seq) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ProdCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ElectrodeOven',@ProdCode OUTPUT
                    END

                    INSERT INTO STB_ElectrodeOven
						(
						    ProdCode,
						    Seq,
						    DryingFurnaceName,
						    DryingFurnaceTemp,
						    DryingFurnaceAirUpperPart,
						    DryingFurnaceAirLowerPart,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    TempUpperTolerance,
						    TempLowerTolerance,
						    AirUpperTolerance,
						    AirLowerTolerance
						)
						VALUES
						(
						    @ProdCode,
						    @Seq,
						    @DryingFurnaceName,
						    @DryingFurnaceTemp,
						    @DryingFurnaceAirUpperPart,
						    @DryingFurnaceAirLowerPart,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @TempUpperTolerance,
						    @TempLowerTolerance,
						    @AirUpperTolerance,
						    @AirLowerTolerance
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ElectrodeOven
						SET
						    ProdCode =   ISNULL(@ProdCode,ProdCode),
						    Seq =   ISNULL(@Seq,Seq),
						    DryingFurnaceName =   ISNULL(@DryingFurnaceName,DryingFurnaceName),
						    DryingFurnaceTemp =   ISNULL(@DryingFurnaceTemp,DryingFurnaceTemp),
						    DryingFurnaceAirUpperPart =   ISNULL(@DryingFurnaceAirUpperPart,DryingFurnaceAirUpperPart),
						    DryingFurnaceAirLowerPart =   ISNULL(@DryingFurnaceAirLowerPart,DryingFurnaceAirLowerPart),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    TempUpperTolerance =   ISNULL(@TempUpperTolerance,TempUpperTolerance),
						    TempLowerTolerance =   ISNULL(@TempLowerTolerance,TempLowerTolerance),
						    AirUpperTolerance =   ISNULL(@AirUpperTolerance,AirUpperTolerance),
						    AirLowerTolerance =   ISNULL(@AirLowerTolerance,AirLowerTolerance)
						WHERE
						    ProdCode = @OldProdCode AND
						    Seq = @OldSeq
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ElectrodeOven
						WHERE
						    ProdCode = @OldProdCode AND
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
