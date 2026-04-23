

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-06-17
-- Browsable : true
-- Group : 공통
-- Description:	이미지관리 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_StatusImageInfo_iud]
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
  DECLARE @OldImageType VARCHAR(20)
  DECLARE @OldImageValue VARCHAR(10)
  DECLARE @ImageType VARCHAR(20)
  DECLARE @ImageValue VARCHAR(10)
  DECLARE @ImageData VARBINARY(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_StatusImageInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_StatusImageInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldImageType IS NULL THEN ImageType
							    ELSE OldImageType
							END AS OldImageType,
							CASE
							    WHEN OldImageValue IS NULL THEN ImageValue
							    ELSE OldImageValue
							END AS OldImageValue,
							ImageType,
							ImageValue,
							dbo.fnBase64ToBinary(ImageData) as ImageData,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldImageType VARCHAR(20),
										OldImageValue VARCHAR(10),
										ImageType VARCHAR(20),
										ImageValue VARCHAR(10),
										ImageData NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ImageType = SourceTable.ImageType AND
					TargetTable.ImageValue = SourceTable.ImageValue
				)

			WHEN MATCHED THEN
				UPDATE SET
					ImageType = SourceTable.ImageType,
					ImageValue = SourceTable.ImageValue,
					ImageData = SourceTable.ImageData,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						ImageType,
						ImageValue,
						ImageData,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ImageType,
							SourceTable.ImageValue,
							SourceTable.ImageData,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_StatusImageInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldImageType IS NULL THEN ImageType
							    ELSE OldImageType
							END AS OldImageType,
							CASE
							    WHEN OldImageValue IS NULL THEN ImageValue
							    ELSE OldImageValue
							END AS OldImageValue,
							ImageType,
							ImageValue,
							dbo.fnBase64ToBinary(ImageData) as ImageData,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldImageType VARCHAR(20),
										OldImageValue VARCHAR(10),
										ImageType VARCHAR(20),
										ImageValue VARCHAR(10),
										ImageData NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ImageType = SourceTable.OldImageType AND
					TargetTable.ImageValue = SourceTable.OldImageValue
				)

			WHEN MATCHED THEN
				UPDATE SET
					ImageType = SourceTable.ImageType,
					ImageValue = SourceTable.ImageValue,
					ImageData = SourceTable.ImageData,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						ImageType,
						ImageValue,
						ImageData,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.ImageType,
							SourceTable.ImageValue,
							SourceTable.ImageData,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_StatusImageInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldImageType IS NULL THEN ImageType
							    ELSE OldImageType
							END AS OldImageType,
							CASE
							    WHEN OldImageValue IS NULL THEN ImageValue
							    ELSE OldImageValue
							END AS OldImageValue,
							ImageType,
							ImageValue,
							dbo.fnBase64ToBinary(ImageData) as ImageData,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldImageType VARCHAR(20),
										OldImageValue VARCHAR(10),
										ImageType VARCHAR(20),
										ImageValue VARCHAR(10),
										ImageData NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.ImageType = SourceTable.ImageType AND
					TargetTable.ImageValue = SourceTable.ImageValue
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
									OldImageType,
									OldImageValue,
									ImageType,
									ImageValue,
									dbo.fnBase64ToBinary(ImageData) as ImageData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldImageType VARCHAR(20),
											 OldImageValue VARCHAR(10),
											 ImageType VARCHAR(20),
											 ImageValue VARCHAR(10),
											 ImageData NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldImageType IS NULL THEN ImageType
										ELSE OldImageType
									END AS OldImageType,
									CASE 
										WHEN OldImageValue IS NULL THEN ImageValue
										ELSE OldImageValue
									END AS OldImageValue,
									ImageType,
									ImageValue,
									dbo.fnBase64ToBinary(ImageData) as ImageData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldImageType VARCHAR(20),
											 OldImageValue VARCHAR(10),
											 ImageType VARCHAR(20),
											 ImageValue VARCHAR(10),
											 ImageData NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldImageType IS NULL THEN ImageType
										ELSE OldImageType
									END AS OldImageType,
									CASE 
										WHEN OldImageValue IS NULL THEN ImageValue
										ELSE OldImageValue
									END AS OldImageValue,
									ImageType,
									ImageValue,
									dbo.fnBase64ToBinary(ImageData) as ImageData,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldImageType VARCHAR(20),
											 OldImageValue VARCHAR(10),
											 ImageType VARCHAR(20),
											 ImageValue VARCHAR(10),
											 ImageData NVARCHAR(MAX),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldImageType,
								 @OldImageValue,
								 @ImageType,
								 @ImageValue,
								 @ImageData,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_StatusImageInfo WHERE ImageType = @ImageType) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ImageType)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_StatusImageInfo',
																	@ImageType OUTPUT
                    END

                    INSERT INTO STB_StatusImageInfo
						(
						    ImageType,
						    ImageValue,
						    ImageData,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @ImageType,
						    @ImageValue,
						    @ImageData,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_StatusImageInfo
						SET
						    ImageType =   CASE
						                WHEN @ImageType IS NOT NULL THEN @ImageType
						                ELSE ImageType
						            END,
						    ImageValue =   CASE
						                WHEN @ImageValue IS NOT NULL THEN @ImageValue
						                ELSE ImageValue
						            END,
						    ImageData =   CASE
						                WHEN @ImageData IS NOT NULL THEN @ImageData
						                ELSE ImageData
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
						    ImageType = @OldImageType AND
						    ImageValue = @OldImageValue
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_StatusImageInfo
						WHERE
						    ImageType = @ImageType AND
						    ImageValue = @ImageValue
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


