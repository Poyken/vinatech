
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2021-05-04
-- Browsable : true
-- Group : 생산관리>생산계획
-- Description:	
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_FourMLotNoHistory_iud]
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
  DECLARE @OldLotNo VARCHAR(18)
  DECLARE @LotNo VARCHAR(18)
  DECLARE @Unusual VARCHAR(1000)
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC usp_GetSerialRule 
			@pTableName = 'STB_FourMLotNoHistory',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
        
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_FourMLotNoHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,
							LotNo,
							Unusual,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldLotNo VARCHAR(18),
										LotNo VARCHAR(18),
										Unusual VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LotNo = SourceTable.LotNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					Unusual = ISNULL(SourceTable.Unusual,TargetTable.Unusual),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						LotNo,
						Unusual,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LotNo,
							SourceTable.Unusual,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_FourMLotNoHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,
							LotNo,
							Unusual,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldLotNo VARCHAR(18),
										LotNo VARCHAR(18),
										Unusual VARCHAR(1000),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LotNo = SourceTable.OldLotNo
				)

			WHEN MATCHED THEN
				UPDATE SET
					Unusual = ISNULL(SourceTable.Unusual,TargetTable.Unusual),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID)
			WHEN NOT MATCHED THEN
				INSERT
					(
						LotNo,
						Unusual,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.LotNo,
							SourceTable.Unusual,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_FourMLotNoHistory AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldLotNo IS NULL THEN LotNo
							    ELSE OldLotNo
							END AS OldLotNo,
							LotNo
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldLotNo VARCHAR(18),
										LotNo VARCHAR(18)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.LotNo = SourceTable.LotNo
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
									OldLotNo,
									LotNo,
									Unusual,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldLotNo VARCHAR(18),
											 LotNo VARCHAR(18),
											 Unusual VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldLotNo IS NULL THEN LotNo
										ELSE OldLotNo
									END AS OldLotNo,
									LotNo,
									Unusual,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldLotNo VARCHAR(18),
											 LotNo VARCHAR(18),
											 Unusual VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											)
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldLotNo IS NULL THEN LotNo
										ELSE OldLotNo
									END AS OldLotNo,
									LotNo,
									Unusual,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldLotNo VARCHAR(18),
											 LotNo VARCHAR(18),
											 Unusual VARCHAR(1000),
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldLotNo,
								 @LotNo,
								 @Unusual,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_FourMLotNoHistory WHERE LotNo = @LotNo) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @LotNo)
					END

                    IF @IsAutoKey = 1 BEGIN
                        EXEC usp_DoCreateSerial 'STB_FourMLotNoHistory',@LotNo OUTPUT
                    END

                    INSERT INTO STB_FourMLotNoHistory
						(
						    LotNo,
						    Unusual,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @LotNo,
						    @Unusual,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_FourMLotNoHistory
						SET
						    LotNo =   ISNULL(@LotNo,LotNo),
						    Unusual =   ISNULL(@Unusual,Unusual),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID
						WHERE
						    LotNo = @OldLotNo
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_FourMLotNoHistory
						WHERE
						    LotNo = @OldLotNo
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
