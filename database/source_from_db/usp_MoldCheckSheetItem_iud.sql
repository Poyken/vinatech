-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형체크시트항목기준 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldCheckSheetItem_iud]
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
  DECLARE @OldMoldCheckSheetCode VARCHAR(20)
  DECLARE @OldItemNo INT
  DECLARE @MoldCheckSheetCode VARCHAR(20)
  DECLARE @ItemNo INT
  DECLARE @DisplayIndex INT
  DECLARE @CheckPointNo VARCHAR(10)
  DECLARE @CheckPointText NVARCHAR(100)
  DECLARE @CheckSubNo VARCHAR(10)
  DECLARE @CheckItem NVARCHAR(200)
  DECLARE @CheckText NVARCHAR(MAX)
  DECLARE @CheckDesc NVARCHAR(MAX)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldCheckSheetItem',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldCheckSheetItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
							    ELSE XMLData.OldMoldCheckSheetCode
							END AS OldMoldCheckSheetCode,
							CASE
							    WHEN XMLData.OldItemNo IS NULL THEN XMLData.ItemNo
							    ELSE XMLData.OldItemNo
							END AS OldItemNo,
							XMLData.MoldCheckSheetCode,
							XMLData.ItemNo,
							XMLData.DisplayIndex,
							XMLData.CheckPointNo,
							XMLData.CheckPointText,
							XMLData.CheckSubNo,
							XMLData.CheckItem,
							XMLData.CheckText,
							XMLData.CheckDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldCheckSheetCode VARCHAR(20),
										OldItemNo INT,
										MoldCheckSheetCode VARCHAR(20),
										ItemNo INT,
										DisplayIndex INT,
										CheckPointNo VARCHAR(10),
										CheckPointText NVARCHAR(100),
										CheckSubNo VARCHAR(10),
										CheckItem NVARCHAR(200),
										CheckText NVARCHAR(MAX),
										CheckDesc NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckSheetCode = SourceTable.MoldCheckSheetCode AND
					TargetTable.ItemNo = SourceTable.ItemNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldCheckSheetCode = SourceTable.MoldCheckSheetCode,
					ItemNo = SourceTable.ItemNo,
					DisplayIndex = SourceTable.DisplayIndex,
					CheckPointNo = SourceTable.CheckPointNo,
					CheckPointText = SourceTable.CheckPointText,
					CheckSubNo = SourceTable.CheckSubNo,
					CheckItem = SourceTable.CheckItem,
					CheckText = SourceTable.CheckText,
					CheckDesc = SourceTable.CheckDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldCheckSheetCode,
						ItemNo,
						DisplayIndex,
						CheckPointNo,
						CheckPointText,
						CheckSubNo,
						CheckItem,
						CheckText,
						CheckDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldCheckSheetCode,
							SourceTable.ItemNo,
							SourceTable.DisplayIndex,
							SourceTable.CheckPointNo,
							SourceTable.CheckPointText,
							SourceTable.CheckSubNo,
							SourceTable.CheckItem,
							SourceTable.CheckText,
							SourceTable.CheckDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldCheckSheetItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
							    ELSE XMLData.OldMoldCheckSheetCode
							END AS OldMoldCheckSheetCode,
							CASE
							    WHEN XMLData.OldItemNo IS NULL THEN XMLData.ItemNo
							    ELSE XMLData.OldItemNo
							END AS OldItemNo,
							XMLData.MoldCheckSheetCode,
							XMLData.ItemNo,
							XMLData.DisplayIndex,
							XMLData.CheckPointNo,
							XMLData.CheckPointText,
							XMLData.CheckSubNo,
							XMLData.CheckItem,
							XMLData.CheckText,
							XMLData.CheckDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldCheckSheetCode VARCHAR(20),
										OldItemNo INT,
										MoldCheckSheetCode VARCHAR(20),
										ItemNo INT,
										DisplayIndex INT,
										CheckPointNo VARCHAR(10),
										CheckPointText NVARCHAR(100),
										CheckSubNo VARCHAR(10),
										CheckItem NVARCHAR(200),
										CheckText NVARCHAR(MAX),
										CheckDesc NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckSheetCode = SourceTable.OldMoldCheckSheetCode AND
					TargetTable.ItemNo = SourceTable.OldItemNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldCheckSheetCode = SourceTable.MoldCheckSheetCode,
					ItemNo = SourceTable.ItemNo,
					DisplayIndex = SourceTable.DisplayIndex,
					CheckPointNo = SourceTable.CheckPointNo,
					CheckPointText = SourceTable.CheckPointText,
					CheckSubNo = SourceTable.CheckSubNo,
					CheckItem = SourceTable.CheckItem,
					CheckText = SourceTable.CheckText,
					CheckDesc = SourceTable.CheckDesc,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldCheckSheetCode,
						ItemNo,
						DisplayIndex,
						CheckPointNo,
						CheckPointText,
						CheckSubNo,
						CheckItem,
						CheckText,
						CheckDesc,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldCheckSheetCode,
							SourceTable.ItemNo,
							SourceTable.DisplayIndex,
							SourceTable.CheckPointNo,
							SourceTable.CheckPointText,
							SourceTable.CheckSubNo,
							SourceTable.CheckItem,
							SourceTable.CheckText,
							SourceTable.CheckDesc,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldCheckSheetItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
							    ELSE XMLData.OldMoldCheckSheetCode
							END AS OldMoldCheckSheetCode,
							CASE
							    WHEN XMLData.OldItemNo IS NULL THEN XMLData.ItemNo
							    ELSE XMLData.OldItemNo
							END AS OldItemNo,
							XMLData.MoldCheckSheetCode,
							XMLData.ItemNo,
							XMLData.DisplayIndex,
							XMLData.CheckPointNo,
							XMLData.CheckPointText,
							XMLData.CheckSubNo,
							XMLData.CheckItem,
							XMLData.CheckText,
							XMLData.CheckDesc,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldCheckSheetCode VARCHAR(20),
										OldItemNo INT,
										MoldCheckSheetCode VARCHAR(20),
										ItemNo INT,
										DisplayIndex INT,
										CheckPointNo VARCHAR(10),
										CheckPointText NVARCHAR(100),
										CheckSubNo VARCHAR(10),
										CheckItem NVARCHAR(200),
										CheckText NVARCHAR(MAX),
										CheckDesc NVARCHAR(MAX),
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldCheckSheetCode = SourceTable.MoldCheckSheetCode AND
					TargetTable.ItemNo = SourceTable.ItemNo
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
									XMLData.OldMoldCheckSheetCode,
									XMLData.OldItemNo,
									XMLData.MoldCheckSheetCode,
									XMLData.ItemNo,
									XMLData.DisplayIndex,
									XMLData.CheckPointNo,
									XMLData.CheckPointText,
									XMLData.CheckSubNo,
									XMLData.CheckItem,
									XMLData.CheckText,
									XMLData.CheckDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldCheckSheetCode VARCHAR(20),
											 OldItemNo INT,
											 MoldCheckSheetCode VARCHAR(20),
											 ItemNo INT,
											 DisplayIndex INT,
											 CheckPointNo VARCHAR(10),
											 CheckPointText NVARCHAR(100),
											 CheckSubNo VARCHAR(10),
											 CheckItem NVARCHAR(200),
											 CheckText NVARCHAR(MAX),
											 CheckDesc NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
										ELSE XMLData.OldMoldCheckSheetCode
									END AS OldMoldCheckSheetCode,
									CASE 
										WHEN XMLData.OldItemNo IS NULL THEN XMLData.ItemNo
										ELSE XMLData.OldItemNo
									END AS OldItemNo,
									XMLData.MoldCheckSheetCode,
									XMLData.ItemNo,
									XMLData.DisplayIndex,
									XMLData.CheckPointNo,
									XMLData.CheckPointText,
									XMLData.CheckSubNo,
									XMLData.CheckItem,
									XMLData.CheckText,
									XMLData.CheckDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldCheckSheetCode VARCHAR(20),
											 OldItemNo INT,
											 MoldCheckSheetCode VARCHAR(20),
											 ItemNo INT,
											 DisplayIndex INT,
											 CheckPointNo VARCHAR(10),
											 CheckPointText NVARCHAR(100),
											 CheckSubNo VARCHAR(10),
											 CheckItem NVARCHAR(200),
											 CheckText NVARCHAR(MAX),
											 CheckDesc NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldCheckSheetCode IS NULL THEN XMLData.MoldCheckSheetCode
										ELSE XMLData.OldMoldCheckSheetCode
									END AS OldMoldCheckSheetCode,
									CASE 
										WHEN XMLData.OldItemNo IS NULL THEN XMLData.ItemNo
										ELSE XMLData.OldItemNo
									END AS OldItemNo,
									XMLData.MoldCheckSheetCode,
									XMLData.ItemNo,
									XMLData.DisplayIndex,
									XMLData.CheckPointNo,
									XMLData.CheckPointText,
									XMLData.CheckSubNo,
									XMLData.CheckItem,
									XMLData.CheckText,
									XMLData.CheckDesc,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldCheckSheetCode VARCHAR(20),
											 OldItemNo INT,
											 MoldCheckSheetCode VARCHAR(20),
											 ItemNo INT,
											 DisplayIndex INT,
											 CheckPointNo VARCHAR(10),
											 CheckPointText NVARCHAR(100),
											 CheckSubNo VARCHAR(10),
											 CheckItem NVARCHAR(200),
											 CheckText NVARCHAR(MAX),
											 CheckDesc NVARCHAR(MAX),
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldCheckSheetCode,
								 @OldItemNo,
								 @MoldCheckSheetCode,
								 @ItemNo,
								 @DisplayIndex,
								 @CheckPointNo,
								 @CheckPointText,
								 @CheckSubNo,
								 @CheckItem,
								 @CheckText,
								 @CheckDesc,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldCheckSheetItem WHERE MoldCheckSheetCode = @MoldCheckSheetCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldCheckSheetCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldCheckSheetItem',
																	@MoldCheckSheetCode OUTPUT
                    END

                    INSERT INTO STB_MoldCheckSheetItem
						(
						    MoldCheckSheetCode,
						    ItemNo,
						    DisplayIndex,
						    CheckPointNo,
						    CheckPointText,
						    CheckSubNo,
						    CheckItem,
						    CheckText,
						    CheckDesc,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldCheckSheetCode,
						    @ItemNo,
						    @DisplayIndex,
						    @CheckPointNo,
						    @CheckPointText,
						    @CheckSubNo,
						    @CheckItem,
						    @CheckText,
						    @CheckDesc,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldCheckSheetItem
						SET
						    MoldCheckSheetCode =   CASE
						                WHEN @MoldCheckSheetCode IS NOT NULL THEN @MoldCheckSheetCode
						                ELSE MoldCheckSheetCode
						            END,
						    ItemNo =   CASE
						                WHEN @ItemNo IS NOT NULL THEN @ItemNo
						                ELSE ItemNo
						            END,
						    DisplayIndex =   CASE
						                WHEN @DisplayIndex IS NOT NULL THEN @DisplayIndex
						                ELSE DisplayIndex
						            END,
						    CheckPointNo =   CASE
						                WHEN @CheckPointNo IS NOT NULL THEN @CheckPointNo
						                ELSE CheckPointNo
						            END,
						    CheckPointText =   CASE
						                WHEN @CheckPointText IS NOT NULL THEN @CheckPointText
						                ELSE CheckPointText
						            END,
						    CheckSubNo =   CASE
						                WHEN @CheckSubNo IS NOT NULL THEN @CheckSubNo
						                ELSE CheckSubNo
						            END,
						    CheckItem =   CASE
						                WHEN @CheckItem IS NOT NULL THEN @CheckItem
						                ELSE CheckItem
						            END,
						    CheckText =   CASE
						                WHEN @CheckText IS NOT NULL THEN @CheckText
						                ELSE CheckText
						            END,
						    CheckDesc =   CASE
						                WHEN @CheckDesc IS NOT NULL THEN @CheckDesc
						                ELSE CheckDesc
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
						    MoldCheckSheetCode = @OldMoldCheckSheetCode AND
						    ItemNo = @OldItemNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldCheckSheetItem
						WHERE
						    MoldCheckSheetCode = @MoldCheckSheetCode AND
						    ItemNo = @ItemNo
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



