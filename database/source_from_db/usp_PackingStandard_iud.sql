
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2020-11-02
-- Browsable : true
-- Group : 공통관리>포장기준정보
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE dbo.usp_PackingStandard_iud
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
  DECLARE @OldMaterialTypeCode VARCHAR(20)
  DECLARE @OldSize VARCHAR(10)
  DECLARE @MaterialTypeCode VARCHAR(20)
  DECLARE @Size VARCHAR(10)
  DECLARE @Voltage NUMERIC(20,5)
  DECLARE @Farad NUMERIC(20,5)
  DECLARE @VinylBagQty INT
  DECLARE @InnerBoxQty INT
  DECLARE @OutBoxQty INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_PackingStandard',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_PackingStandard AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
							    ELSE OldMaterialTypeCode
							END AS OldMaterialTypeCode,
							CASE
							    WHEN OldSize IS NULL THEN Size
							    ELSE OldSize
							END AS OldSize,
							MaterialTypeCode,
							Size,
							Voltage,
							Farad,
							VinylBagQty,
							InnerBoxQty,
							OutBoxQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMaterialTypeCode VARCHAR(20),
										OldSize VARCHAR(10),
										MaterialTypeCode VARCHAR(20),
										Size VARCHAR(10),
										Voltage NUMERIC(20,5),
										Farad NUMERIC(20,5),
										VinylBagQty INT,
										InnerBoxQty INT,
										OutBoxQty INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialTypeCode = SourceTable.MaterialTypeCode AND
					TargetTable.Size = SourceTable.Size
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialTypeCode = ISNULL(SourceTable.MaterialTypeCode,TargetTable.MaterialTypeCode),
					Size = ISNULL(SourceTable.Size,TargetTable.Size),
					Voltage = ISNULL(SourceTable.Voltage,TargetTable.Voltage),
					Farad = ISNULL(SourceTable.Farad,TargetTable.Farad),
					VinylBagQty = ISNULL(SourceTable.VinylBagQty,TargetTable.VinylBagQty),
					InnerBoxQty = ISNULL(SourceTable.InnerBoxQty,TargetTable.InnerBoxQty),
					OutBoxQty = ISNULL(SourceTable.OutBoxQty,TargetTable.OutBoxQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialTypeCode,
						Size,
						Voltage,
						Farad,
						VinylBagQty,
						InnerBoxQty,
						OutBoxQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialTypeCode,
							SourceTable.Size,
							SourceTable.Voltage,
							SourceTable.Farad,
							SourceTable.VinylBagQty,
							SourceTable.InnerBoxQty,
							SourceTable.OutBoxQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_PackingStandard AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
							    ELSE OldMaterialTypeCode
							END AS OldMaterialTypeCode,
							CASE
							    WHEN OldSize IS NULL THEN Size
							    ELSE OldSize
							END AS OldSize,
							MaterialTypeCode,
							Size,
							Voltage,
							Farad,
							VinylBagQty,
							InnerBoxQty,
							OutBoxQty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMaterialTypeCode VARCHAR(20),
										OldSize VARCHAR(10),
										MaterialTypeCode VARCHAR(20),
										Size VARCHAR(10),
										Voltage NUMERIC(20,5),
										Farad NUMERIC(20,5),
										VinylBagQty INT,
										InnerBoxQty INT,
										OutBoxQty INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialTypeCode = SourceTable.OldMaterialTypeCode AND
					TargetTable.Size = SourceTable.OldSize
				)

			WHEN MATCHED THEN
				UPDATE SET
					MaterialTypeCode = ISNULL(SourceTable.MaterialTypeCode,TargetTable.MaterialTypeCode),
					Size = ISNULL(SourceTable.Size,TargetTable.Size),
					Voltage = ISNULL(SourceTable.Voltage,TargetTable.Voltage),
					Farad = ISNULL(SourceTable.Farad,TargetTable.Farad),
					VinylBagQty = ISNULL(SourceTable.VinylBagQty,TargetTable.VinylBagQty),
					InnerBoxQty = ISNULL(SourceTable.InnerBoxQty,TargetTable.InnerBoxQty),
					OutBoxQty = ISNULL(SourceTable.OutBoxQty,TargetTable.OutBoxQty),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						MaterialTypeCode,
						Size,
						Voltage,
						Farad,
						VinylBagQty,
						InnerBoxQty,
						OutBoxQty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MaterialTypeCode,
							SourceTable.Size,
							SourceTable.Voltage,
							SourceTable.Farad,
							SourceTable.VinylBagQty,
							SourceTable.InnerBoxQty,
							SourceTable.OutBoxQty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_PackingStandard AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
							    ELSE OldMaterialTypeCode
							END AS OldMaterialTypeCode,
							CASE
							    WHEN OldSize IS NULL THEN Size
							    ELSE OldSize
							END AS OldSize,
							MaterialTypeCode,
							Size
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMaterialTypeCode VARCHAR(20),
										OldSize VARCHAR(10),
										MaterialTypeCode VARCHAR(20),
										Size VARCHAR(10)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.MaterialTypeCode = SourceTable.MaterialTypeCode AND
					TargetTable.Size = SourceTable.Size
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
									OldMaterialTypeCode,
									OldSize,
									MaterialTypeCode,
									Size,
									Voltage,
									Farad,
									VinylBagQty,
									InnerBoxQty,
									OutBoxQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMaterialTypeCode VARCHAR(20),
											 OldSize VARCHAR(10),
											 MaterialTypeCode VARCHAR(20),
											 Size VARCHAR(10),
											 Voltage NUMERIC(20,5),
											 Farad NUMERIC(20,5),
											 VinylBagQty INT,
											 InnerBoxQty INT,
											 OutBoxQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
										ELSE OldMaterialTypeCode
									END AS OldMaterialTypeCode,
									CASE 
										WHEN OldSize IS NULL THEN Size
										ELSE OldSize
									END AS OldSize,
									MaterialTypeCode,
									Size,
									Voltage,
									Farad,
									VinylBagQty,
									InnerBoxQty,
									OutBoxQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMaterialTypeCode VARCHAR(20),
											 OldSize VARCHAR(10),
											 MaterialTypeCode VARCHAR(20),
											 Size VARCHAR(10),
											 Voltage NUMERIC(20,5),
											 Farad NUMERIC(20,5),
											 VinylBagQty INT,
											 InnerBoxQty INT,
											 OutBoxQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldMaterialTypeCode IS NULL THEN MaterialTypeCode
										ELSE OldMaterialTypeCode
									END AS OldMaterialTypeCode,
									CASE 
										WHEN OldSize IS NULL THEN Size
										ELSE OldSize
									END AS OldSize,
									MaterialTypeCode,
									Size,
									Voltage,
									Farad,
									VinylBagQty,
									InnerBoxQty,
									OutBoxQty,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMaterialTypeCode VARCHAR(20),
											 OldSize VARCHAR(10),
											 MaterialTypeCode VARCHAR(20),
											 Size VARCHAR(10),
											 Voltage NUMERIC(20,5),
											 Farad NUMERIC(20,5),
											 VinylBagQty INT,
											 InnerBoxQty INT,
											 OutBoxQty INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMaterialTypeCode,
								 @OldSize,
								 @MaterialTypeCode,
								 @Size,
								 @Voltage,
								 @Farad,
								 @VinylBagQty,
								 @InnerBoxQty,
								 @OutBoxQty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_PackingStandard WHERE MaterialTypeCode = @MaterialTypeCode AND Size = @Size) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialTypeCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_PackingStandard',@MaterialTypeCode OUTPUT
                    END

                    INSERT INTO STB_PackingStandard
						(
						    MaterialTypeCode,
						    Size,
						    Voltage,
						    Farad,
						    VinylBagQty,
						    InnerBoxQty,
						    OutBoxQty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MaterialTypeCode,
						    @Size,
						    @Voltage,
						    @Farad,
						    @VinylBagQty,
						    @InnerBoxQty,
						    @OutBoxQty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_PackingStandard
						SET
						    MaterialTypeCode =   ISNULL(@MaterialTypeCode,MaterialTypeCode),
						    Size =   ISNULL(@Size,Size),
						    Voltage =   ISNULL(@Voltage,Voltage),
						    Farad =   ISNULL(@Farad,Farad),
						    VinylBagQty =   ISNULL(@VinylBagQty,VinylBagQty),
						    InnerBoxQty =   ISNULL(@InnerBoxQty,InnerBoxQty),
						    OutBoxQty =   ISNULL(@OutBoxQty,OutBoxQty),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MaterialTypeCode = @OldMaterialTypeCode AND
						    Size = @OldSize
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_PackingStandard
						WHERE
						    MaterialTypeCode = @OldMaterialTypeCode AND
						    Size = @OldSize
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
