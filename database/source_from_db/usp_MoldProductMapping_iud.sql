-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-05-04
-- Browsable : true
-- Group : 품목정보
-- Description:	금형생산 상세정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldProductMapping_iud]
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
    DECLARE @MaxKeyField VARCHAR(20)

    -- Declare Columns Variable
  DECLARE @OldMoldNumber VARCHAR(50)
  DECLARE @OldMaterialCode VARCHAR(50)
  DECLARE @MoldNumber VARCHAR(50)
  DECLARE @MaterialCode VARCHAR(50)
  DECLARE @Cabity INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldProductMapping',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldProductMapping AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
							    ELSE XMLData.OldMoldNumber
							END AS OldMoldNumber,
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							XMLData.MoldNumber,
							XMLData.MaterialCode,
							XMLData.Cabity,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldNumber VARCHAR(50),
										OldMaterialCode VARCHAR(50),
										MoldNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										Cabity INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldNumber = SourceTable.MoldNumber AND
					TargetTable.MaterialCode = SourceTable.MaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldNumber = SourceTable.MoldNumber,
					MaterialCode = SourceTable.MaterialCode,
					Cabity = SourceTable.Cabity,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldNumber,
						MaterialCode,
						Cabity,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldNumber,
							SourceTable.MaterialCode,
							SourceTable.Cabity,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldProductMapping AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
							    ELSE XMLData.OldMoldNumber
							END AS OldMoldNumber,
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							XMLData.MoldNumber,
							XMLData.MaterialCode,
							XMLData.Cabity,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldNumber VARCHAR(50),
										OldMaterialCode VARCHAR(50),
										MoldNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										Cabity INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldNumber = SourceTable.OldMoldNumber AND
					TargetTable.MaterialCode = SourceTable.OldMaterialCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldNumber = SourceTable.MoldNumber,
					MaterialCode = SourceTable.MaterialCode,
					Cabity = SourceTable.Cabity,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldNumber,
						MaterialCode,
						Cabity,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldNumber,
							SourceTable.MaterialCode,
							SourceTable.Cabity,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldProductMapping AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
							    ELSE XMLData.OldMoldNumber
							END AS OldMoldNumber,
							CASE
							    WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
							    ELSE XMLData.OldMaterialCode
							END AS OldMaterialCode,
							XMLData.MoldNumber,
							XMLData.MaterialCode,
							XMLData.Cabity,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldNumber VARCHAR(50),
										OldMaterialCode VARCHAR(50),
										MoldNumber VARCHAR(50),
										MaterialCode VARCHAR(50),
										Cabity INT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldNumber = SourceTable.MoldNumber AND
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
									XMLData.OldMoldNumber,
									XMLData.OldMaterialCode,
									XMLData.MoldNumber,
									XMLData.MaterialCode,
									XMLData.Cabity,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldNumber VARCHAR(50),
											 OldMaterialCode VARCHAR(50),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 Cabity INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
										ELSE XMLData.OldMoldNumber
									END AS OldMoldNumber,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
										ELSE XMLData.OldMaterialCode
									END AS OldMaterialCode,
									XMLData.MoldNumber,
									XMLData.MaterialCode,
									XMLData.Cabity,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldNumber VARCHAR(50),
											 OldMaterialCode VARCHAR(50),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 Cabity INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldNumber IS NULL THEN XMLData.MoldNumber
										ELSE XMLData.OldMoldNumber
									END AS OldMoldNumber,
									CASE 
										WHEN XMLData.OldMaterialCode IS NULL THEN XMLData.MaterialCode
										ELSE XMLData.OldMaterialCode
									END AS OldMaterialCode,
									XMLData.MoldNumber,
									XMLData.MaterialCode,
									XMLData.Cabity,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldNumber VARCHAR(50),
											 OldMaterialCode VARCHAR(50),
											 MoldNumber VARCHAR(50),
											 MaterialCode VARCHAR(50),
											 Cabity INT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldNumber,
								 @OldMaterialCode,
								 @MoldNumber,
								 @MaterialCode,
								 @Cabity,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldProductMapping WHERE MoldNumber = @MoldNumber AND MaterialCode = @MaterialCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s, %s', 16, 1, @MoldNumber,@MaterialCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldProductMapping',
																	@MoldNumber OUTPUT
                    END

                    INSERT INTO STB_MoldProductMapping
						(
						    MoldNumber,
						    MaterialCode,
						    Cabity,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldNumber,
						    @MaterialCode,
						    @Cabity,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldProductMapping
						SET
						    MoldNumber =   CASE
						                WHEN @MoldNumber IS NOT NULL THEN @MoldNumber
						                ELSE MoldNumber
						            END,
						    MaterialCode =   CASE
						                WHEN @MaterialCode IS NOT NULL THEN @MaterialCode
						                ELSE MaterialCode
						            END,
						    Cabity =   CASE
						                WHEN @Cabity IS NOT NULL THEN @Cabity
						                ELSE Cabity
						            END,
						    CreateDateTime =   CASE
						                WHEN @CreateDateTime IS NOT NULL THEN @CreateDateTime
						                ELSE CreateDateTime
						            END,
						    CreateUserID =   CASE
						                WHEN @CreateUserID IS NOT NULL THEN @CreateUserID
						                ELSE CreateUserID
						            END,
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    MoldNumber = @OldMoldNumber AND
						    MaterialCode = @OldMaterialCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldProductMapping
						WHERE
						    MoldNumber = @MoldNumber AND
						    MaterialCode = @MaterialCode
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



