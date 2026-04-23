
-- =============================================
-- Author:KimGiGeun(ggkim@awoo.co.kr)
-- Create date: 2018-08-24
-- Browsable : true
-- Group : 모델사양정보
-- Description:	모델사양정보IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelSpec_iud]
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
  DECLARE @OldModelCode VARCHAR(50)
  DECLARE @OldSpecItemCode VARCHAR(20)
  DECLARE @ModelCode VARCHAR(50)
  DECLARE @SpecItemCode VARCHAR(20)
  DECLARE @SpecValue NVARCHAR(100)
  DECLARE @UpperSpec NVARCHAR(100)
  DECLARE @LowerSpec NVARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModelSpec',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ModelSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModelCode IS NULL THEN ModelCode
							    ELSE OldModelCode
							END AS OldModelCode,
							CASE
							    WHEN OldSpecItemCode IS NULL THEN SpecItemCode
							    ELSE OldSpecItemCode
							END AS OldSpecItemCode,
							ModelCode,
							SpecItemCode,
							SpecValue,
							UpperSpec,
							LowerSpec,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldModelCode VARCHAR(50),
										OldSpecItemCode VARCHAR(20),
										ModelCode VARCHAR(50),
										SpecItemCode VARCHAR(20),
										SpecValue NVARCHAR(100),
										UpperSpec NVARCHAR(100),
										LowerSpec NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModelCode = SourceTable.ModelCode AND
					TargetTable.SpecItemCode = SourceTable.SpecItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ModelCode = ISNULL(SourceTable.ModelCode,TargetTable.ModelCode),
					SpecItemCode = ISNULL(SourceTable.SpecItemCode,TargetTable.SpecItemCode),
					SpecValue = ISNULL(SourceTable.SpecValue,TargetTable.SpecValue),
					UpperSpec = ISNULL(SourceTable.UpperSpec,TargetTable.UpperSpec),
					LowerSpec = ISNULL(SourceTable.LowerSpec,TargetTable.LowerSpec),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ModelCode,
						SpecItemCode,
						SpecValue,
						UpperSpec,
						LowerSpec,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ModelCode,
							SourceTable.SpecItemCode,
							SourceTable.SpecValue,
							SourceTable.UpperSpec,
							SourceTable.LowerSpec,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ModelSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModelCode IS NULL THEN ModelCode
							    ELSE OldModelCode
							END AS OldModelCode,
							CASE
							    WHEN OldSpecItemCode IS NULL THEN SpecItemCode
							    ELSE OldSpecItemCode
							END AS OldSpecItemCode,
							ModelCode,
							SpecItemCode,
							SpecValue,
							UpperSpec,
							LowerSpec,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldModelCode VARCHAR(50),
										OldSpecItemCode VARCHAR(20),
										ModelCode VARCHAR(50),
										SpecItemCode VARCHAR(20),
										SpecValue NVARCHAR(100),
										UpperSpec NVARCHAR(100),
										LowerSpec NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModelCode = SourceTable.OldModelCode AND
					TargetTable.SpecItemCode = SourceTable.OldSpecItemCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ModelCode = ISNULL(SourceTable.ModelCode,TargetTable.ModelCode),
					SpecItemCode = ISNULL(SourceTable.SpecItemCode,TargetTable.SpecItemCode),
					SpecValue = ISNULL(SourceTable.SpecValue,TargetTable.SpecValue),
					UpperSpec = ISNULL(SourceTable.UpperSpec,TargetTable.UpperSpec),
					LowerSpec = ISNULL(SourceTable.LowerSpec,TargetTable.LowerSpec),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ModelCode,
						SpecItemCode,
						SpecValue,
						UpperSpec,
						LowerSpec,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ModelCode,
							SourceTable.SpecItemCode,
							SourceTable.SpecValue,
							SourceTable.UpperSpec,
							SourceTable.LowerSpec,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ModelSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModelCode IS NULL THEN ModelCode
							    ELSE OldModelCode
							END AS OldModelCode,
							CASE
							    WHEN OldSpecItemCode IS NULL THEN SpecItemCode
							    ELSE OldSpecItemCode
							END AS OldSpecItemCode,
							ModelCode,
							SpecItemCode,
							SpecValue,
							UpperSpec,
							LowerSpec,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldModelCode VARCHAR(50),
										OldSpecItemCode VARCHAR(20),
										ModelCode VARCHAR(50),
										SpecItemCode VARCHAR(20),
										SpecValue NVARCHAR(100),
										UpperSpec NVARCHAR(100),
										LowerSpec NVARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModelCode = SourceTable.ModelCode AND
					TargetTable.SpecItemCode = SourceTable.SpecItemCode
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
									OldModelCode,
									OldSpecItemCode,
									ModelCode,
									SpecItemCode,
									SpecValue,
									UpperSpec,
									LowerSpec,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldModelCode VARCHAR(50),
											 OldSpecItemCode VARCHAR(20),
											 ModelCode VARCHAR(50),
											 SpecItemCode VARCHAR(20),
											 SpecValue NVARCHAR(100),
											 UpperSpec NVARCHAR(100),
											 LowerSpec NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldModelCode IS NULL THEN ModelCode
										ELSE OldModelCode
									END AS OldModelCode,
									CASE 
										WHEN OldSpecItemCode IS NULL THEN SpecItemCode
										ELSE OldSpecItemCode
									END AS OldSpecItemCode,
									ModelCode,
									SpecItemCode,
									SpecValue,
									UpperSpec,
									LowerSpec,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldModelCode VARCHAR(50),
											 OldSpecItemCode VARCHAR(20),
											 ModelCode VARCHAR(50),
											 SpecItemCode VARCHAR(20),
											 SpecValue NVARCHAR(100),
											 UpperSpec NVARCHAR(100),
											 LowerSpec NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldModelCode IS NULL THEN ModelCode
										ELSE OldModelCode
									END AS OldModelCode,
									CASE 
										WHEN OldSpecItemCode IS NULL THEN SpecItemCode
										ELSE OldSpecItemCode
									END AS OldSpecItemCode,
									ModelCode,
									SpecItemCode,
									SpecValue,
									UpperSpec,
									LowerSpec,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldModelCode VARCHAR(50),
											 OldSpecItemCode VARCHAR(20),
											 ModelCode VARCHAR(50),
											 SpecItemCode VARCHAR(20),
											 SpecValue NVARCHAR(100),
											 UpperSpec NVARCHAR(100),
											 LowerSpec NVARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldModelCode,
								 @OldSpecItemCode,
								 @ModelCode,
								 @SpecItemCode,
								 @SpecValue,
								 @UpperSpec,
								 @LowerSpec,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ModelSpec WHERE ModelCode = @ModelCode AND SpecItemCode = @SpecItemCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ModelCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ModelSpec',@ModelCode OUTPUT
                    END

                    INSERT INTO STB_ModelSpec
						(
						    ModelCode,
						    SpecItemCode,
						    SpecValue,
						    UpperSpec,
						    LowerSpec,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ModelCode,
						    @SpecItemCode,
						    @SpecValue,
						    @UpperSpec,
						    @LowerSpec,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ModelSpec
						SET
						    ModelCode =   ISNULL(@ModelCode,ModelCode),
						    SpecItemCode =   ISNULL(@SpecItemCode,SpecItemCode),
						    SpecValue =   ISNULL(@SpecValue,SpecValue),
						    UpperSpec =   ISNULL(@UpperSpec,UpperSpec),
						    LowerSpec =   ISNULL(@LowerSpec,LowerSpec),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ModelCode = @OldModelCode AND
						    SpecItemCode = @OldSpecItemCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ModelSpec
						WHERE
						    ModelCode = @OldModelCode AND
						    SpecItemCode = @OldSpecItemCode
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
