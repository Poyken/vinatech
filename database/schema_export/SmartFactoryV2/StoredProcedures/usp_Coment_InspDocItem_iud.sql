-- Procedure: usp_Coment_InspDocItem_iud

-- =============================================
-- Author:	    kilee
-- Create date: 2020-01-04
-- Browsable : true
-- Group : 품질관리
-- Description: 공정검사(바코드) 업데이트
-- Modified: 
-- =============================================
CREATE PROCEDURE [dbo].[usp_Coment_InspDocItem_iud]
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
  DECLARE @OldCommInspDocNo VARCHAR(20)
  DECLARE @CommInspDocNo VARCHAR(20)
  DECLARE @CommInspRemark VARCHAR(100)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_Coment_InspDocItem',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_Coment_InspDocItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspDocNo IS NULL THEN CommInspDocNo
							    ELSE OldCommInspDocNo
							END AS OldCommInspDocNo,
							CommInspDocNo,
							CommInspRemark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldCommInspDocNo VARCHAR(20),
										CommInspDocNo VARCHAR(20),
										CommInspRemark VARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspDocNo = SourceTable.CommInspDocNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CommInspDocNo = ISNULL(SourceTable.CommInspDocNo,TargetTable.CommInspDocNo),
					CommInspRemark = ISNULL(SourceTable.CommInspRemark,TargetTable.CommInspRemark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CommInspDocNo,
						CommInspRemark,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CommInspDocNo,
							SourceTable.CommInspRemark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_Coment_InspDocItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspDocNo IS NULL THEN CommInspDocNo
							    ELSE OldCommInspDocNo
							END AS OldCommInspDocNo,
							CommInspDocNo,
							CommInspRemark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldCommInspDocNo VARCHAR(20),
										CommInspDocNo VARCHAR(20),
										CommInspRemark VARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspDocNo = SourceTable.OldCommInspDocNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					CommInspDocNo = ISNULL(SourceTable.CommInspDocNo,TargetTable.CommInspDocNo),
					CommInspRemark = ISNULL(SourceTable.CommInspRemark,TargetTable.CommInspRemark),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						CommInspDocNo,
						CommInspRemark,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.CommInspDocNo,
							SourceTable.CommInspRemark,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_Coment_InspDocItem AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldCommInspDocNo IS NULL THEN CommInspDocNo
							    ELSE OldCommInspDocNo
							END AS OldCommInspDocNo,
							CommInspDocNo,
							CommInspRemark,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldCommInspDocNo VARCHAR(20),
										CommInspDocNo VARCHAR(20),
										CommInspRemark VARCHAR(100),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.CommInspDocNo = SourceTable.CommInspDocNo
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
									OldCommInspDocNo,
									CommInspDocNo,
									CommInspRemark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldCommInspDocNo VARCHAR(20),
											 CommInspDocNo VARCHAR(20),
											 CommInspRemark VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspDocNo IS NULL THEN CommInspDocNo
										ELSE OldCommInspDocNo
									END AS OldCommInspDocNo,
									CommInspDocNo,
									CommInspRemark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldCommInspDocNo VARCHAR(20),
											 CommInspDocNo VARCHAR(20),
											 CommInspRemark VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldCommInspDocNo IS NULL THEN CommInspDocNo
										ELSE OldCommInspDocNo
									END AS OldCommInspDocNo,
									CommInspDocNo,
									CommInspRemark,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldCommInspDocNo VARCHAR(20),
											 CommInspDocNo VARCHAR(20),
											 CommInspRemark VARCHAR(100),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldCommInspDocNo,
								 @CommInspDocNo,
								 @CommInspRemark,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_Coment_InspDocItem WHERE CommInspDocNo = @CommInspDocNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @CommInspDocNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_Coment_InspDocItem',@CommInspDocNo OUTPUT
                    END

                    INSERT INTO STB_Coment_InspDocItem
						(
						    CommInspDocNo,
						    CommInspRemark,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @CommInspDocNo,
						    @CommInspRemark,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_Coment_InspDocItem
						SET
						    CommInspDocNo =   ISNULL(@CommInspDocNo,CommInspDocNo),
						    CommInspRemark =   ISNULL(@CommInspRemark,CommInspRemark),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    CommInspDocNo = @OldCommInspDocNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_Coment_InspDocItem
						WHERE
						    CommInspDocNo = @OldCommInspDocNo
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

