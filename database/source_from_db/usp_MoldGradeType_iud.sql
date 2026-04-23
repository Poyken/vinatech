-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형등급타입정보 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldGradeType_iud]
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
  DECLARE @OldMoldGradeTypeCode VARCHAR(20)
  DECLARE @MoldGradeTypeCode VARCHAR(20)
  DECLARE @MoldGradeTypeName NVARCHAR(50)
  DECLARE @Level1Qty INT
  DECLARE @Level2Qty INT
  DECLARE @Level3Qty INT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldGradeType',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldGradeType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldGradeTypeCode IS NULL THEN XMLData.MoldGradeTypeCode
							    ELSE XMLData.OldMoldGradeTypeCode
							END AS OldMoldGradeTypeCode,
							XMLData.MoldGradeTypeCode,
							XMLData.MoldGradeTypeName,
							XMLData.Level1Qty,
							XMLData.Level2Qty,
							XMLData.Level3Qty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldGradeTypeCode VARCHAR(20),
										MoldGradeTypeCode VARCHAR(20),
										MoldGradeTypeName NVARCHAR(50),
										Level1Qty INT,
										Level2Qty INT,
										Level3Qty INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldGradeTypeCode = SourceTable.MoldGradeTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldGradeTypeCode = SourceTable.MoldGradeTypeCode,
					MoldGradeTypeName = SourceTable.MoldGradeTypeName,
					Level1Qty = SourceTable.Level1Qty,
					Level2Qty = SourceTable.Level2Qty,
					Level3Qty = SourceTable.Level3Qty,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldGradeTypeCode,
						MoldGradeTypeName,
						Level1Qty,
						Level2Qty,
						Level3Qty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldGradeTypeCode,
							SourceTable.MoldGradeTypeName,
							SourceTable.Level1Qty,
							SourceTable.Level2Qty,
							SourceTable.Level3Qty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldGradeType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldGradeTypeCode IS NULL THEN XMLData.MoldGradeTypeCode
							    ELSE XMLData.OldMoldGradeTypeCode
							END AS OldMoldGradeTypeCode,
							XMLData.MoldGradeTypeCode,
							XMLData.MoldGradeTypeName,
							XMLData.Level1Qty,
							XMLData.Level2Qty,
							XMLData.Level3Qty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldGradeTypeCode VARCHAR(20),
										MoldGradeTypeCode VARCHAR(20),
										MoldGradeTypeName NVARCHAR(50),
										Level1Qty INT,
										Level2Qty INT,
										Level3Qty INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldGradeTypeCode = SourceTable.OldMoldGradeTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldGradeTypeCode = SourceTable.MoldGradeTypeCode,
					MoldGradeTypeName = SourceTable.MoldGradeTypeName,
					Level1Qty = SourceTable.Level1Qty,
					Level2Qty = SourceTable.Level2Qty,
					Level3Qty = SourceTable.Level3Qty,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldGradeTypeCode,
						MoldGradeTypeName,
						Level1Qty,
						Level2Qty,
						Level3Qty,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldGradeTypeCode,
							SourceTable.MoldGradeTypeName,
							SourceTable.Level1Qty,
							SourceTable.Level2Qty,
							SourceTable.Level3Qty,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldGradeType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldGradeTypeCode IS NULL THEN XMLData.MoldGradeTypeCode
							    ELSE XMLData.OldMoldGradeTypeCode
							END AS OldMoldGradeTypeCode,
							XMLData.MoldGradeTypeCode,
							XMLData.MoldGradeTypeName,
							XMLData.Level1Qty,
							XMLData.Level2Qty,
							XMLData.Level3Qty,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldGradeTypeCode VARCHAR(20),
										MoldGradeTypeCode VARCHAR(20),
										MoldGradeTypeName NVARCHAR(50),
										Level1Qty INT,
										Level2Qty INT,
										Level3Qty INT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldGradeTypeCode = SourceTable.MoldGradeTypeCode
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
									XMLData.OldMoldGradeTypeCode,
									XMLData.MoldGradeTypeCode,
									XMLData.MoldGradeTypeName,
									XMLData.Level1Qty,
									XMLData.Level2Qty,
									XMLData.Level3Qty,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldGradeTypeCode VARCHAR(20),
											 MoldGradeTypeCode VARCHAR(20),
											 MoldGradeTypeName NVARCHAR(50),
											 Level1Qty INT,
											 Level2Qty INT,
											 Level3Qty INT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldGradeTypeCode IS NULL THEN XMLData.MoldGradeTypeCode
										ELSE XMLData.OldMoldGradeTypeCode
									END AS OldMoldGradeTypeCode,
									XMLData.MoldGradeTypeCode,
									XMLData.MoldGradeTypeName,
									XMLData.Level1Qty,
									XMLData.Level2Qty,
									XMLData.Level3Qty,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldGradeTypeCode VARCHAR(20),
											 MoldGradeTypeCode VARCHAR(20),
											 MoldGradeTypeName NVARCHAR(50),
											 Level1Qty INT,
											 Level2Qty INT,
											 Level3Qty INT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldGradeTypeCode IS NULL THEN XMLData.MoldGradeTypeCode
										ELSE XMLData.OldMoldGradeTypeCode
									END AS OldMoldGradeTypeCode,
									XMLData.MoldGradeTypeCode,
									XMLData.MoldGradeTypeName,
									XMLData.Level1Qty,
									XMLData.Level2Qty,
									XMLData.Level3Qty,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldGradeTypeCode VARCHAR(20),
											 MoldGradeTypeCode VARCHAR(20),
											 MoldGradeTypeName NVARCHAR(50),
											 Level1Qty INT,
											 Level2Qty INT,
											 Level3Qty INT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldGradeTypeCode,
								 @MoldGradeTypeCode,
								 @MoldGradeTypeName,
								 @Level1Qty,
								 @Level2Qty,
								 @Level3Qty,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldGradeType WHERE MoldGradeTypeCode = @MoldGradeTypeCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldGradeTypeCode)
					END

                    IF @IsAutoKey = 1 BEGIN

						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldGradeType',
																	@MoldGradeTypeCode OUTPUT
                    END

                    INSERT INTO STB_MoldGradeType
						(
						    MoldGradeTypeCode,
						    MoldGradeTypeName,
						    Level1Qty,
						    Level2Qty,
						    Level3Qty,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldGradeTypeCode,
						    @MoldGradeTypeName,
						    @Level1Qty,
						    @Level2Qty,
						    @Level3Qty,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldGradeType
						SET
						    MoldGradeTypeCode =   CASE
						                WHEN @MoldGradeTypeCode IS NOT NULL THEN @MoldGradeTypeCode
						                ELSE MoldGradeTypeCode
						            END,
						    MoldGradeTypeName =   CASE
						                WHEN @MoldGradeTypeName IS NOT NULL THEN @MoldGradeTypeName
						                ELSE MoldGradeTypeName
						            END,
						    Level1Qty =   CASE
						                WHEN @Level1Qty IS NOT NULL THEN @Level1Qty
						                ELSE Level1Qty
						            END,
						    Level2Qty =   CASE
						                WHEN @Level2Qty IS NOT NULL THEN @Level2Qty
						                ELSE Level2Qty
						            END,
						    Level3Qty =   CASE
						                WHEN @Level3Qty IS NOT NULL THEN @Level3Qty
						                ELSE Level3Qty
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
						    MoldGradeTypeCode = @OldMoldGradeTypeCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldGradeType
						WHERE
						    MoldGradeTypeCode = @MoldGradeTypeCode
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
