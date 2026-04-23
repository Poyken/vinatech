
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-10-21
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_WasteUnitPrice_iud]
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
  DECLARE @OldLineCode VARCHAR(20)
  DECLARE @OldVolt NUMERIC(2,1)
  DECLARE @OldFarad NUMERIC(5,1)
  DECLARE @OldSize VARCHAR(10)
  DECLARE @OldRouteCode VARCHAR(20)
  DECLARE @LineCode VARCHAR(20)
  DECLARE @Volt NUMERIC(2,1)
  DECLARE @Farad NUMERIC(5,1)
  DECLARE @Size VARCHAR(10)
  DECLARE @RouteCode VARCHAR(20)
  DECLARE @ProcessUnitPriceKG NUMERIC(10,2)
  DECLARE @ProcessUnitPriceEA NUMERIC(10,2)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_WasteUnitPrice',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_WasteUnitPrice AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							CASE
							    WHEN OldVolt IS NULL THEN Volt
							    ELSE OldVolt
							END AS OldVolt,
							CASE
							    WHEN OldFarad IS NULL THEN Farad
							    ELSE OldFarad
							END AS OldFarad,
							CASE
							    WHEN OldSize IS NULL THEN Size
							    ELSE OldSize
							END AS OldSize,
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							LineCode,
							Volt,
							Farad,
							Size,
							RouteCode,
							ProcessUnitPriceKG,
							ProcessUnitPriceEA,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										OldVolt NUMERIC(2,1),
										OldFarad NUMERIC(5,1),
										OldSize VARCHAR(10),
										OldRouteCode VARCHAR(20),
										LineCode VARCHAR(20),
										Volt NUMERIC(2,1),
										Farad NUMERIC(5,1),
										Size VARCHAR(10),
										RouteCode VARCHAR(20),
										ProcessUnitPriceKG NUMERIC(10,2),
										ProcessUnitPriceEA NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.LineCode AND
					TargetTable.Volt = SourceTable.Volt AND
					TargetTable.Farad = SourceTable.Farad AND
					TargetTable.Size = SourceTable.Size AND
					TargetTable.RouteCode = SourceTable.RouteCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProcessUnitPriceKG = ISNULL(SourceTable.ProcessUnitPriceKG,TargetTable.ProcessUnitPriceKG),
					ProcessUnitPriceEA = ISNULL(SourceTable.ProcessUnitPriceEA,TargetTable.ProcessUnitPriceEA),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						LineCode,
						Volt,
						Farad,
						Size,
						RouteCode,
						ProcessUnitPriceKG,
						ProcessUnitPriceEA,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LineCode,
							SourceTable.Volt,
							SourceTable.Farad,
							SourceTable.Size,
							SourceTable.RouteCode,
							SourceTable.ProcessUnitPriceKG,
							SourceTable.ProcessUnitPriceEA,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_WasteUnitPrice AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							CASE
							    WHEN OldVolt IS NULL THEN Volt
							    ELSE OldVolt
							END AS OldVolt,
							CASE
							    WHEN OldFarad IS NULL THEN Farad
							    ELSE OldFarad
							END AS OldFarad,
							CASE
							    WHEN OldSize IS NULL THEN Size
							    ELSE OldSize
							END AS OldSize,
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							LineCode,
							Volt,
							Farad,
							Size,
							RouteCode,
							ProcessUnitPriceKG,
							ProcessUnitPriceEA,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										OldVolt NUMERIC(2,1),
										OldFarad NUMERIC(5,1),
										OldSize VARCHAR(10),
										OldRouteCode VARCHAR(20),
										LineCode VARCHAR(20),
										Volt NUMERIC(2,1),
										Farad NUMERIC(5,1),
										Size VARCHAR(10),
										RouteCode VARCHAR(20),
										ProcessUnitPriceKG NUMERIC(10,2),
										ProcessUnitPriceEA NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.OldLineCode AND
					TargetTable.Volt = SourceTable.OldVolt AND
					TargetTable.Farad = SourceTable.OldFarad AND
					TargetTable.Size = SourceTable.OldSize AND
					TargetTable.RouteCode = SourceTable.OldRouteCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ProcessUnitPriceKG = ISNULL(SourceTable.ProcessUnitPriceKG,TargetTable.ProcessUnitPriceKG),
					ProcessUnitPriceEA = ISNULL(SourceTable.ProcessUnitPriceEA,TargetTable.ProcessUnitPriceEA),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						LineCode,
						Volt,
						Farad,
						Size,
						RouteCode,
						ProcessUnitPriceKG,
						ProcessUnitPriceEA,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LineCode,
							SourceTable.Volt,
							SourceTable.Farad,
							SourceTable.Size,
							SourceTable.RouteCode,
							SourceTable.ProcessUnitPriceKG,
							SourceTable.ProcessUnitPriceEA,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_WasteUnitPrice AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLineCode IS NULL THEN LineCode
							    ELSE OldLineCode
							END AS OldLineCode,
							CASE
							    WHEN OldVolt IS NULL THEN Volt
							    ELSE OldVolt
							END AS OldVolt,
							CASE
							    WHEN OldFarad IS NULL THEN Farad
							    ELSE OldFarad
							END AS OldFarad,
							CASE
							    WHEN OldSize IS NULL THEN Size
							    ELSE OldSize
							END AS OldSize,
							CASE
							    WHEN OldRouteCode IS NULL THEN RouteCode
							    ELSE OldRouteCode
							END AS OldRouteCode,
							LineCode,
							Volt,
							Farad,
							Size,
							RouteCode,
							ProcessUnitPriceKG,
							ProcessUnitPriceEA,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLineCode VARCHAR(20),
										OldVolt NUMERIC(2,1),
										OldFarad NUMERIC(5,1),
										OldSize VARCHAR(10),
										OldRouteCode VARCHAR(20),
										LineCode VARCHAR(20),
										Volt NUMERIC(2,1),
										Farad NUMERIC(5,1),
										Size VARCHAR(10),
										RouteCode VARCHAR(20),
										ProcessUnitPriceKG NUMERIC(10,2),
										ProcessUnitPriceEA NUMERIC(10,2),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LineCode = SourceTable.LineCode AND
					TargetTable.Volt = SourceTable.Volt AND
					TargetTable.Farad = SourceTable.Farad AND
					TargetTable.Size = SourceTable.Size AND
					TargetTable.RouteCode = SourceTable.RouteCode
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
									OldLineCode,
									OldVolt,
									OldFarad,
									OldSize,
									OldRouteCode,
									LineCode,
									Volt,
									Farad,
									Size,
									RouteCode,
									ProcessUnitPriceKG,
									ProcessUnitPriceEA,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 OldVolt NUMERIC(2,1),
											 OldFarad NUMERIC(5,1),
											 OldSize VARCHAR(10),
											 OldRouteCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 Volt NUMERIC(2,1),
											 Farad NUMERIC(5,1),
											 Size VARCHAR(10),
											 RouteCode VARCHAR(20),
											 ProcessUnitPriceKG NUMERIC(10,2),
											 ProcessUnitPriceEA NUMERIC(10,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldLineCode IS NULL THEN LineCode
										ELSE OldLineCode
									END AS OldLineCode,
									CASE 
										WHEN OldVolt IS NULL THEN Volt
										ELSE OldVolt
									END AS OldVolt,
									CASE 
										WHEN OldFarad IS NULL THEN Farad
										ELSE OldFarad
									END AS OldFarad,
									CASE 
										WHEN OldSize IS NULL THEN Size
										ELSE OldSize
									END AS OldSize,
									CASE 
										WHEN OldRouteCode IS NULL THEN RouteCode
										ELSE OldRouteCode
									END AS OldRouteCode,
									LineCode,
									Volt,
									Farad,
									Size,
									RouteCode,
									ProcessUnitPriceKG,
									ProcessUnitPriceEA,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 OldVolt NUMERIC(2,1),
											 OldFarad NUMERIC(5,1),
											 OldSize VARCHAR(10),
											 OldRouteCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 Volt NUMERIC(2,1),
											 Farad NUMERIC(5,1),
											 Size VARCHAR(10),
											 RouteCode VARCHAR(20),
											 ProcessUnitPriceKG NUMERIC(10,2),
											 ProcessUnitPriceEA NUMERIC(10,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldLineCode IS NULL THEN LineCode
										ELSE OldLineCode
									END AS OldLineCode,
									CASE 
										WHEN OldVolt IS NULL THEN Volt
										ELSE OldVolt
									END AS OldVolt,
									CASE 
										WHEN OldFarad IS NULL THEN Farad
										ELSE OldFarad
									END AS OldFarad,
									CASE 
										WHEN OldSize IS NULL THEN Size
										ELSE OldSize
									END AS OldSize,
									CASE 
										WHEN OldRouteCode IS NULL THEN RouteCode
										ELSE OldRouteCode
									END AS OldRouteCode,
									LineCode,
									Volt,
									Farad,
									Size,
									RouteCode,
									ProcessUnitPriceKG,
									ProcessUnitPriceEA,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLineCode VARCHAR(20),
											 OldVolt NUMERIC(2,1),
											 OldFarad NUMERIC(5,1),
											 OldSize VARCHAR(10),
											 OldRouteCode VARCHAR(20),
											 LineCode VARCHAR(20),
											 Volt NUMERIC(2,1),
											 Farad NUMERIC(5,1),
											 Size VARCHAR(10),
											 RouteCode VARCHAR(20),
											 ProcessUnitPriceKG NUMERIC(10,2),
											 ProcessUnitPriceEA NUMERIC(10,2),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLineCode,
								 @OldVolt,
								 @OldFarad,
								 @OldSize,
								 @OldRouteCode,
								 @LineCode,
								 @Volt,
								 @Farad,
								 @Size,
								 @RouteCode,
								 @ProcessUnitPriceKG,
								 @ProcessUnitPriceEA,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_WasteUnitPrice WHERE LineCode = @LineCode AND Volt = @Volt AND Farad = @Farad AND Size = @Size AND RouteCode = @RouteCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @LineCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_WasteUnitPrice',@LineCode OUTPUT
                    END

                    INSERT INTO STB_WasteUnitPrice
						(
						    LineCode,
						    Volt,
						    Farad,
						    Size,
						    RouteCode,
						    ProcessUnitPriceKG,
						    ProcessUnitPriceEA,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LineCode,
						    @Volt,
						    @Farad,
						    @Size,
						    @RouteCode,
						    @ProcessUnitPriceKG,
						    @ProcessUnitPriceEA,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_WasteUnitPrice
						SET
						    ProcessUnitPriceKG =   ISNULL(@ProcessUnitPriceKG,ProcessUnitPriceKG),
						    ProcessUnitPriceEA =   ISNULL(@ProcessUnitPriceEA,ProcessUnitPriceEA),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    LineCode = @OldLineCode AND
						    Volt = @OldVolt AND
						    Farad = @OldFarad AND
						    Size = @OldSize AND
						    RouteCode = @OldRouteCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_WasteUnitPrice
						WHERE
						    LineCode = @OldLineCode AND
						    Volt = @OldVolt AND
						    Farad = @OldFarad AND
						    Size = @OldSize AND
						    RouteCode = @OldRouteCode
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
