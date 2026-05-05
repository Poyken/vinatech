-- Procedure: usp_CheckClassInfo_iud
-- =============================================
-- Author: Jackaroe(yjyu@vina.co.kr)
-- Create date: 2019-07-26
-- Browsable : true
-- Group : 생산관리
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_CheckClassInfo_iud]
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
  DECLARE @OldCheckClassNo VARCHAR(20)
  DECLARE @CheckClassNo VARCHAR(20)
  DECLARE @CheckClassName VARCHAR(100)
  DECLARE @IsUsed BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
  DECLARE @Remark NVARCHAR(100)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_CheckClassInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_CheckClassInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckClassNo IS NULL THEN CheckClassNo
							    ELSE OldCheckClassNo
							END AS OldCheckClassNo,
							CheckClassNo,
							CheckClassName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Remark
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCheckClassNo VARCHAR(20),
										CheckClassNo VARCHAR(20),
										CheckClassName VARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Remark NVARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckClassNo = SourceTable.CheckClassNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CheckClassName = ISNULL(SourceTable.CheckClassName,TargetTable.CheckClassName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CheckClassNo,
						CheckClassName,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						Remark
					)
				VALUES
					(
							SourceTable.CheckClassNo,
							SourceTable.CheckClassName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Remark
					);


			-- Process Update Table
            MERGE STB_CheckClassInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckClassNo IS NULL THEN CheckClassNo
							    ELSE OldCheckClassNo
							END AS OldCheckClassNo,
							CheckClassNo,
							CheckClassName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							Remark
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCheckClassNo VARCHAR(20),
										CheckClassNo VARCHAR(20),
										CheckClassName VARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										Remark NVARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckClassNo = SourceTable.OldCheckClassNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CheckClassName = ISNULL(SourceTable.CheckClassName,TargetTable.CheckClassName),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					Remark = ISNULL(SourceTable.Remark,TargetTable.Remark)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CheckClassNo,
						CheckClassName,
						IsUsed,
						CreateDateTime,
						CreateUserID,
						Remark
					)
				VALUES
					(
							SourceTable.CheckClassNo,
							SourceTable.CheckClassName,
							SourceTable.IsUsed,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.Remark
					);


			-- Process Delete Table
            MERGE STB_CheckClassInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCheckClassNo IS NULL THEN CheckClassNo
							    ELSE OldCheckClassNo
							END AS OldCheckClassNo,
							CheckClassNo,
							CheckClassName,
							IsUsed,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCheckClassNo VARCHAR(20),
										CheckClassNo VARCHAR(20),
										CheckClassName VARCHAR(100),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CheckClassNo = SourceTable.CheckClassNo
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
									OldCheckClassNo,
									CheckClassNo,
									CheckClassName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCheckClassNo VARCHAR(20),
											 CheckClassNo VARCHAR(20),
											 CheckClassName VARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(100)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCheckClassNo IS NULL THEN CheckClassNo
										ELSE OldCheckClassNo
									END AS OldCheckClassNo,
									CheckClassNo,
									CheckClassName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCheckClassNo VARCHAR(20),
											 CheckClassNo VARCHAR(20),
											 CheckClassName VARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(100)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCheckClassNo IS NULL THEN CheckClassNo
										ELSE OldCheckClassNo
									END AS OldCheckClassNo,
									CheckClassNo,
									CheckClassName,
									IsUsed,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									Remark
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCheckClassNo VARCHAR(20),
											 CheckClassNo VARCHAR(20),
											 CheckClassName VARCHAR(100),
											 IsUsed BIT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 Remark NVARCHAR(100)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCheckClassNo,
								 @CheckClassNo,
								 @CheckClassName,
								 @IsUsed,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @Remark


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_CheckClassInfo WHERE CheckClassNo = @CheckClassNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CheckClassNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_CheckClassInfo',@CheckClassNo OUTPUT
                    END

                    INSERT INTO STB_CheckClassInfo
						(
						    CheckClassNo,
						    CheckClassName,
						    IsUsed,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							Remark
						)
						VALUES
						(
						    @CheckClassNo,
						    @CheckClassName,
						    @IsUsed,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@Remark
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_CheckClassInfo
						SET
						    CheckClassName =   ISNULL(@CheckClassName,CheckClassName),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							Remark = ISNULL(@Remark,Remark)
						WHERE
						    CheckClassNo = @OldCheckClassNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_CheckClassInfo
						WHERE
						    CheckClassNo = @OldCheckClassNo
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

