-- =============================================
-- Author:	    Anonymous()
-- Create date: 2016-02-15
-- Browsable : true
-- Group : 품질관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_QcInspectionGroup_iud]
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
  DECLARE @OldQcInspectionGroupCode VARCHAR(20)
  DECLARE @QcInspectionGroupCode VARCHAR(20)
  DECLARE @QcInspectionGroupName NVARCHAR(50)
  DECLARE @QcInspectionGroupDesc NVARCHAR(200)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_QcInspectionGroup',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_QcInspectionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
							    ELSE XMLData.OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionGroupName,
							XMLData.QcInspectionGroupDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldQcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionGroupCode = SourceTable.QcInspectionGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					QcInspectionGroupCode = SourceTable.QcInspectionGroupCode,
					QcInspectionGroupName = SourceTable.QcInspectionGroupName,
					QcInspectionGroupDesc = SourceTable.QcInspectionGroupDesc,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						QcInspectionGroupCode,
						QcInspectionGroupName,
						QcInspectionGroupDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionGroupName,
							SourceTable.QcInspectionGroupDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_QcInspectionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
							    ELSE XMLData.OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionGroupName,
							XMLData.QcInspectionGroupDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldQcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionGroupCode = SourceTable.OldQcInspectionGroupCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					QcInspectionGroupCode = SourceTable.QcInspectionGroupCode,
					QcInspectionGroupName = SourceTable.QcInspectionGroupName,
					QcInspectionGroupDesc = SourceTable.QcInspectionGroupDesc,
					IsUsed = SourceTable.IsUsed,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						QcInspectionGroupCode,
						QcInspectionGroupName,
						QcInspectionGroupDesc,
						IsUsed,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.QcInspectionGroupCode,
							SourceTable.QcInspectionGroupName,
							SourceTable.QcInspectionGroupDesc,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_QcInspectionGroup AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
							    ELSE XMLData.OldQcInspectionGroupCode
							END AS OldQcInspectionGroupCode,
							XMLData.QcInspectionGroupCode,
							XMLData.QcInspectionGroupName,
							XMLData.QcInspectionGroupDesc,
							XMLData.IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldQcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupCode VARCHAR(20),
										QcInspectionGroupName NVARCHAR(50),
										QcInspectionGroupDesc NVARCHAR(200),
										IsUsed BIT,
										CreateDateTime DATETIME,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIME,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.QcInspectionGroupCode = SourceTable.QcInspectionGroupCode
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
									XMLData.OldQcInspectionGroupCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionGroupName,
									XMLData.QcInspectionGroupDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldQcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
										ELSE XMLData.OldQcInspectionGroupCode
									END AS OldQcInspectionGroupCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionGroupName,
									XMLData.QcInspectionGroupDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldQcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldQcInspectionGroupCode IS NULL THEN XMLData.QcInspectionGroupCode
										ELSE XMLData.OldQcInspectionGroupCode
									END AS OldQcInspectionGroupCode,
									XMLData.QcInspectionGroupCode,
									XMLData.QcInspectionGroupName,
									XMLData.QcInspectionGroupDesc,
									XMLData.IsUsed,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldQcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupCode VARCHAR(20),
											 QcInspectionGroupName NVARCHAR(50),
											 QcInspectionGroupDesc NVARCHAR(200),
											 IsUsed BIT,
											 CreateDateTime DATETIME,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIME,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldQcInspectionGroupCode,
								 @QcInspectionGroupCode,
								 @QcInspectionGroupName,
								 @QcInspectionGroupDesc,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_QcInspectionGroup WHERE QcInspectionGroupCode = @QcInspectionGroupCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @QcInspectionGroupCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QcInspectionGroup', @QcInspectionGroupCode OUTPUT
                    END

                    INSERT INTO STB_QcInspectionGroup
						(
						    QcInspectionGroupCode,
						    QcInspectionGroupName,
						    QcInspectionGroupDesc,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @QcInspectionGroupCode,
						    @QcInspectionGroupName,
						    @QcInspectionGroupDesc,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_QcInspectionGroup
						SET
						    QcInspectionGroupCode =   CASE
						                WHEN @QcInspectionGroupCode IS NOT NULL THEN @QcInspectionGroupCode
						                ELSE QcInspectionGroupCode
						            END,
						    QcInspectionGroupName =   CASE
						                WHEN @QcInspectionGroupName IS NOT NULL THEN @QcInspectionGroupName
						                ELSE QcInspectionGroupName
						            END,
						    QcInspectionGroupDesc =   CASE
						                WHEN @QcInspectionGroupDesc IS NOT NULL THEN @QcInspectionGroupDesc
						                ELSE QcInspectionGroupDesc
						            END,
						    IsUsed =   CASE
						                WHEN @IsUsed IS NOT NULL THEN @IsUsed
						                ELSE IsUsed
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
						    QcInspectionGroupCode = @OldQcInspectionGroupCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_QcInspectionGroup
						WHERE
						    QcInspectionGroupCode = @QcInspectionGroupCode
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

