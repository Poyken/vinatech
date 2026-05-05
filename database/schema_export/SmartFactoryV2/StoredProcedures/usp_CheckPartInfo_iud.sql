-- Procedure: usp_CheckPartInfo_iud

-- =============================================
-- Author:	    Anonymous()
-- Create date: 2019-09-05
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckPartInfo_iud]
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
  DECLARE @OldCheckPartNo VARCHAR(20)
  DECLARE @CheckPartNo VARCHAR(20)
  DECLARE @CheckPartName VARCHAR(100)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @DisplayIndex INT
  DECLARE @Remark NVARCHAR(100)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CheckPartInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CheckPartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckPartNo IS NULL THEN CheckPartNo
							    ELSE OldCheckPartNo
							END AS OldCheckPartNo,
							CheckPartNo,
							CheckPartName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							DisplayIndex,
							Remark
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCheckPartNo VARCHAR(20),
										CheckPartNo VARCHAR(20),
										CheckPartName VARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										DisplayIndex INT,
										Remark NVARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckPartNo = SourceTable.CheckPartNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CheckPartName = ISNULL(SourceTable.CheckPartName,TargetTable.CheckPartName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					DisplayIndex = ISNULL(SourceTable.DisplayIndex,TargetTable.DisplayIndex),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CheckPartNo,
						CheckPartName,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						DisplayIndex,
						Remark
					)
				VALUES
					(
							SourceTable.CheckPartNo,
							SourceTable.CheckPartName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.DisplayIndex,
							SourceTable.Remark
					);


			-- Process Update Table
            MERGE STB_CheckPartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckPartNo IS NULL THEN CheckPartNo
							    ELSE OldCheckPartNo
							END AS OldCheckPartNo,
							CheckPartNo,
							CheckPartName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							DisplayIndex,
							Remark
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCheckPartNo VARCHAR(20),
										CheckPartNo VARCHAR(20),
										CheckPartName VARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										DisplayIndex INT,
										Remark NVARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckPartNo = SourceTable.OldCheckPartNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CheckPartName = ISNULL(SourceTable.CheckPartName,TargetTable.CheckPartName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					DisplayIndex = ISNULL(SourceTable.DisplayIndex,TargetTable.DisplayIndex),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CheckPartNo,
						CheckPartName,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						DisplayIndex,
						Remark
					)
				VALUES
					(
							SourceTable.CheckPartNo,
							SourceTable.CheckPartName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.DisplayIndex,
							SourceTable.Remark
					);


			-- Process Delete Table
            MERGE STB_CheckPartInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckPartNo IS NULL THEN CheckPartNo
							    ELSE OldCheckPartNo
							END AS OldCheckPartNo,
							CheckPartNo,
							CheckPartName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							DisplayIndex,
							Remark
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCheckPartNo VARCHAR(20),
										CheckPartNo VARCHAR(20),
										CheckPartName VARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										DisplayIndex INT,
										Remark NVARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckPartNo = SourceTable.CheckPartNo
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
									OldCheckPartNo,
									CheckPartNo,
									CheckPartName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									DisplayIndex,
									Remark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCheckPartNo VARCHAR(20),
											 CheckPartNo VARCHAR(20),
											 CheckPartName VARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 DisplayIndex INT,
											 Remark NVARCHAR(100)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCheckPartNo IS NULL THEN CheckPartNo
										ELSE OldCheckPartNo
									END AS OldCheckPartNo,
									CheckPartNo,
									CheckPartName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									DisplayIndex,
									Remark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCheckPartNo VARCHAR(20),
											 CheckPartNo VARCHAR(20),
											 CheckPartName VARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 DisplayIndex INT,
											 Remark NVARCHAR(100)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCheckPartNo IS NULL THEN CheckPartNo
										ELSE OldCheckPartNo
									END AS OldCheckPartNo,
									CheckPartNo,
									CheckPartName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									DisplayIndex,
									Remark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCheckPartNo VARCHAR(20),
											 CheckPartNo VARCHAR(20),
											 CheckPartName VARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 DisplayIndex INT,
											 Remark NVARCHAR(100)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCheckPartNo,
								 @CheckPartNo,
								 @CheckPartName,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @DisplayIndex,
								 @Remark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CheckPartInfo WHERE CheckPartNo = @CheckPartNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CheckPartNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CheckPartInfo',@CheckPartNo OUTPUT
                    END

                    INSERT INTO STB_CheckPartInfo
						(
						    CheckPartNo,
						    CheckPartName,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
						    DisplayIndex,
							Remark
						)
						VALUES
						(
						    @CheckPartNo,
						    @CheckPartName,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
						    @DisplayIndex,
							@Remark
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CheckPartInfo
						SET
						    CheckPartName =   ISNULL(@CheckPartName,CheckPartName),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
						    DisplayIndex =   ISNULL(@DisplayIndex,DisplayIndex),
							Remark =   ISNULL(@Remark,Remark)
						WHERE
						    CheckPartNo = @OldCheckPartNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CheckPartInfo
						WHERE
						    CheckPartNo = @OldCheckPartNo
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

GO

