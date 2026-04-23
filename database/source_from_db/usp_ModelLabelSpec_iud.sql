

-- =============================================
-- Author:	    Jeon Gyeong Ho(khjun@awoo.co.kr)
-- Create date: 2018-09-20
-- Browsable : true
-- Group : 라벨관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_ModelLabelSpec_iud]
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
  DECLARE @OldLabelType NVARCHAR(30)
  DECLARE @OldLabelSpecCode VARCHAR(30)
  DECLARE @ModelCode VARCHAR(50)
  DECLARE @LabelType NVARCHAR(30)
  DECLARE @LabelSpecCode VARCHAR(30)
  DECLARE @LabelSpecValue NVARCHAR(200)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_ModelLabelSpec',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_ModelLabelSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModelCode IS NULL THEN ModelCode
							    ELSE OldModelCode
							END AS OldModelCode,
							CASE
							    WHEN OldLabelType IS NULL THEN LabelType
							    ELSE OldLabelType
							END AS OldLabelType,
							CASE
							    WHEN OldLabelSpecCode IS NULL THEN LabelSpecCode
							    ELSE OldLabelSpecCode
							END AS OldLabelSpecCode,
							ModelCode,
							LabelType,
							LabelSpecCode,
							LabelSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldModelCode VARCHAR(50),
										OldLabelType NVARCHAR(30),
										OldLabelSpecCode VARCHAR(30),
										ModelCode VARCHAR(50),
										LabelType NVARCHAR(30),
										LabelSpecCode VARCHAR(30),
										LabelSpecValue NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModelCode = SourceTable.ModelCode AND
					TargetTable.LabelType = SourceTable.LabelType AND
					TargetTable.LabelSpecCode = SourceTable.LabelSpecCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ModelCode = ISNULL(SourceTable.ModelCode,TargetTable.ModelCode),
					LabelType = ISNULL(SourceTable.LabelType,TargetTable.LabelType),
					LabelSpecCode = ISNULL(SourceTable.LabelSpecCode,TargetTable.LabelSpecCode),
					LabelSpecValue = ISNULL(SourceTable.LabelSpecValue,TargetTable.LabelSpecValue),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ModelCode,
						LabelType,
						LabelSpecCode,
						LabelSpecValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ModelCode,
							SourceTable.LabelType,
							SourceTable.LabelSpecCode,
							SourceTable.LabelSpecValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_ModelLabelSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModelCode IS NULL THEN ModelCode
							    ELSE OldModelCode
							END AS OldModelCode,
							CASE
							    WHEN OldLabelType IS NULL THEN LabelType
							    ELSE OldLabelType
							END AS OldLabelType,
							CASE
							    WHEN OldLabelSpecCode IS NULL THEN LabelSpecCode
							    ELSE OldLabelSpecCode
							END AS OldLabelSpecCode,
							ModelCode,
							LabelType,
							LabelSpecCode,
							LabelSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldModelCode VARCHAR(50),
										OldLabelType NVARCHAR(30),
										OldLabelSpecCode VARCHAR(30),
										ModelCode VARCHAR(50),
										LabelType NVARCHAR(30),
										LabelSpecCode VARCHAR(30),
										LabelSpecValue NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModelCode = SourceTable.OldModelCode AND
					TargetTable.LabelType = SourceTable.OldLabelType AND
					TargetTable.LabelSpecCode = SourceTable.OldLabelSpecCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					ModelCode = ISNULL(SourceTable.ModelCode,TargetTable.ModelCode),
					LabelType = ISNULL(SourceTable.LabelType,TargetTable.LabelType),
					LabelSpecCode = ISNULL(SourceTable.LabelSpecCode,TargetTable.LabelSpecCode),
					LabelSpecValue = ISNULL(SourceTable.LabelSpecValue,TargetTable.LabelSpecValue),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						ModelCode,
						LabelType,
						LabelSpecCode,
						LabelSpecValue,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ModelCode,
							SourceTable.LabelType,
							SourceTable.LabelSpecCode,
							SourceTable.LabelSpecValue,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_ModelLabelSpec AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldModelCode IS NULL THEN ModelCode
							    ELSE OldModelCode
							END AS OldModelCode,
							CASE
							    WHEN OldLabelType IS NULL THEN LabelType
							    ELSE OldLabelType
							END AS OldLabelType,
							CASE
							    WHEN OldLabelSpecCode IS NULL THEN LabelSpecCode
							    ELSE OldLabelSpecCode
							END AS OldLabelSpecCode,
							ModelCode,
							LabelType,
							LabelSpecCode,
							LabelSpecValue,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldModelCode VARCHAR(50),
										OldLabelType NVARCHAR(30),
										OldLabelSpecCode VARCHAR(30),
										ModelCode VARCHAR(50),
										LabelType NVARCHAR(30),
										LabelSpecCode VARCHAR(30),
										LabelSpecValue NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ModelCode = SourceTable.ModelCode AND
					TargetTable.LabelType = SourceTable.LabelType AND
					TargetTable.LabelSpecCode = SourceTable.LabelSpecCode
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
									OldLabelType,
									OldLabelSpecCode,
									ModelCode,
									LabelType,
									LabelSpecCode,
									LabelSpecValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldModelCode VARCHAR(50),
											 OldLabelType NVARCHAR(30),
											 OldLabelSpecCode VARCHAR(30),
											 ModelCode VARCHAR(50),
											 LabelType NVARCHAR(30),
											 LabelSpecCode VARCHAR(30),
											 LabelSpecValue NVARCHAR(200),
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
										WHEN OldLabelType IS NULL THEN LabelType
										ELSE OldLabelType
									END AS OldLabelType,
									CASE 
										WHEN OldLabelSpecCode IS NULL THEN LabelSpecCode
										ELSE OldLabelSpecCode
									END AS OldLabelSpecCode,
									ModelCode,
									LabelType,
									LabelSpecCode,
									LabelSpecValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldModelCode VARCHAR(50),
											 OldLabelType NVARCHAR(30),
											 OldLabelSpecCode VARCHAR(30),
											 ModelCode VARCHAR(50),
											 LabelType NVARCHAR(30),
											 LabelSpecCode VARCHAR(30),
											 LabelSpecValue NVARCHAR(200),
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
										WHEN OldLabelType IS NULL THEN LabelType
										ELSE OldLabelType
									END AS OldLabelType,
									CASE 
										WHEN OldLabelSpecCode IS NULL THEN LabelSpecCode
										ELSE OldLabelSpecCode
									END AS OldLabelSpecCode,
									ModelCode,
									LabelType,
									LabelSpecCode,
									LabelSpecValue,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldModelCode VARCHAR(50),
											 OldLabelType NVARCHAR(30),
											 OldLabelSpecCode VARCHAR(30),
											 ModelCode VARCHAR(50),
											 LabelType NVARCHAR(30),
											 LabelSpecCode VARCHAR(30),
											 LabelSpecValue NVARCHAR(200),
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
								 @OldLabelType,
								 @OldLabelSpecCode,
								 @ModelCode,
								 @LabelType,
								 @LabelSpecCode,
								 @LabelSpecValue,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_ModelLabelSpec WHERE ModelCode = @ModelCode AND LabelType = @LabelType AND LabelSpecCode = @LabelSpecCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ModelCode)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_ModelLabelSpec',@ModelCode OUTPUT
                    END

                    INSERT INTO STB_ModelLabelSpec
						(
						    ModelCode,
						    LabelType,
						    LabelSpecCode,
						    LabelSpecValue,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ModelCode,
						    @LabelType,
						    @LabelSpecCode,
						    @LabelSpecValue,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_ModelLabelSpec
						SET
						    ModelCode =   ISNULL(@ModelCode,ModelCode),
						    LabelType =   ISNULL(@LabelType,LabelType),
						    LabelSpecCode =   ISNULL(@LabelSpecCode,LabelSpecCode),
						    LabelSpecValue =   ISNULL(@LabelSpecValue,LabelSpecValue),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    ModelCode = @OldModelCode AND
						    LabelType = @OldLabelType AND
						    LabelSpecCode = @OldLabelSpecCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_ModelLabelSpec
						WHERE
						    ModelCode = @OldModelCode AND
						    LabelType = @OldLabelType AND
						    LabelSpecCode = @OldLabelSpecCode
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

