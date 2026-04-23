

-- =============================================
-- Author: Park Jong Hoon(jhpark@awoo.co.kr)
-- Create date: 2016-02-02
-- Browsable : true
-- Group : 금형관리
-- Description:	금형이동 구분 설정 IUD
-- Modified:
-- =============================================
CREATE PROCEDURE [dbo].[usp_MoldMoveType_iud]
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
  DECLARE @OldMoldMoveTypeCode VARCHAR(20)
  DECLARE @MoldMoveTypeCode VARCHAR(20)
  DECLARE @MoldMoveTypeName NVARCHAR(100)
  DECLARE @IsGR BIT
  DECLARE @IsCheckWhenGR BIT
  DECLARE @IsGI BIT
  DECLARE @IsMove BIT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_MoldMoveType',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_MoldMoveType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldMoveTypeCode IS NULL THEN XMLData.MoldMoveTypeCode
							    ELSE XMLData.OldMoldMoveTypeCode
							END AS OldMoldMoveTypeCode,
							XMLData.MoldMoveTypeCode,
							XMLData.MoldMoveTypeName,
							XMLData.IsGR,
							XMLData.IsCheckWhenGR,
							XMLData.IsGI,
							XMLData.IsMove,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldMoldMoveTypeCode VARCHAR(20),
										MoldMoveTypeCode VARCHAR(20),
										MoldMoveTypeName NVARCHAR(100),
										IsGR BIT,
										IsCheckWhenGR BIT,
										IsGI BIT,
										IsMove BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldMoveTypeCode = SourceTable.MoldMoveTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldMoveTypeCode = SourceTable.MoldMoveTypeCode,
					MoldMoveTypeName = SourceTable.MoldMoveTypeName,
					IsGR = SourceTable.IsGR,
					IsCheckWhenGR = SourceTable.IsCheckWhenGR,
					IsGI = SourceTable.IsGI,
					IsMove = SourceTable.IsMove,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldMoveTypeCode,
						MoldMoveTypeName,
						IsGR,
						IsCheckWhenGR,
						IsGI,
						IsMove,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldMoveTypeCode,
							SourceTable.MoldMoveTypeName,
							SourceTable.IsGR,
							SourceTable.IsCheckWhenGR,
							SourceTable.IsGI,
							SourceTable.IsMove,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Update Table
            MERGE STB_MoldMoveType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldMoveTypeCode IS NULL THEN XMLData.MoldMoveTypeCode
							    ELSE XMLData.OldMoldMoveTypeCode
							END AS OldMoldMoveTypeCode,
							XMLData.MoldMoveTypeCode,
							XMLData.MoldMoveTypeName,
							XMLData.IsGR,
							XMLData.IsCheckWhenGR,
							XMLData.IsGI,
							XMLData.IsMove,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldMoldMoveTypeCode VARCHAR(20),
										MoldMoveTypeCode VARCHAR(20),
										MoldMoveTypeName NVARCHAR(100),
										IsGR BIT,
										IsCheckWhenGR BIT,
										IsGI BIT,
										IsMove BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldMoveTypeCode = SourceTable.OldMoldMoveTypeCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					MoldMoveTypeCode = SourceTable.MoldMoveTypeCode,
					MoldMoveTypeName = SourceTable.MoldMoveTypeName,
					IsGR = SourceTable.IsGR,
					IsCheckWhenGR = SourceTable.IsCheckWhenGR,
					IsGI = SourceTable.IsGI,
					IsMove = SourceTable.IsMove,
					ChangeDateTime = SourceTable.ChangeDateTime,
					ChangeUserID = SourceTable.ChangeUserID
			WHEN NOT MATCHED THEN
				INSERT
					(
						MoldMoveTypeCode,
						MoldMoveTypeName,
						IsGR,
						IsCheckWhenGR,
						IsGI,
						IsMove,
						CreateDateTime,
						CreateUserID
					)
				VALUES
					(
							SourceTable.MoldMoveTypeCode,
							SourceTable.MoldMoveTypeName,
							SourceTable.IsGR,
							SourceTable.IsCheckWhenGR,
							SourceTable.IsGI,
							SourceTable.IsMove,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID
					);


			-- Process Delete Table
            MERGE STB_MoldMoveType AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldMoldMoveTypeCode IS NULL THEN XMLData.MoldMoveTypeCode
							    ELSE XMLData.OldMoldMoveTypeCode
							END AS OldMoldMoveTypeCode,
							XMLData.MoldMoveTypeCode,
							XMLData.MoldMoveTypeName,
							XMLData.IsGR,
							XMLData.IsCheckWhenGR,
							XMLData.IsGI,
							XMLData.IsMove,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldMoldMoveTypeCode VARCHAR(20),
										MoldMoveTypeCode VARCHAR(20),
										MoldMoveTypeName NVARCHAR(100),
										IsGR BIT,
										IsCheckWhenGR BIT,
										IsGI BIT,
										IsMove BIT,
										CreateDateTime  DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime  DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.MoldMoveTypeCode = SourceTable.MoldMoveTypeCode
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
									XMLData.OldMoldMoveTypeCode,
									XMLData.MoldMoveTypeCode,
									XMLData.MoldMoveTypeName,
									XMLData.IsGR,
									XMLData.IsCheckWhenGR,
									XMLData.IsGI,
									XMLData.IsMove,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldMoldMoveTypeCode VARCHAR(20),
											 MoldMoveTypeCode VARCHAR(20),
											 MoldMoveTypeName NVARCHAR(100),
											 IsGR BIT,
											 IsCheckWhenGR BIT,
											 IsGI BIT,
											 IsMove BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldMoveTypeCode IS NULL THEN XMLData.MoldMoveTypeCode
										ELSE XMLData.OldMoldMoveTypeCode
									END AS OldMoldMoveTypeCode,
									XMLData.MoldMoveTypeCode,
									XMLData.MoldMoveTypeName,
									XMLData.IsGR,
									XMLData.IsCheckWhenGR,
									XMLData.IsGI,
									XMLData.IsMove,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldMoldMoveTypeCode VARCHAR(20),
											 MoldMoveTypeCode VARCHAR(20),
											 MoldMoveTypeName NVARCHAR(100),
											 IsGR BIT,
											 IsCheckWhenGR BIT,
											 IsGI BIT,
											 IsMove BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldMoldMoveTypeCode IS NULL THEN XMLData.MoldMoveTypeCode
										ELSE XMLData.OldMoldMoveTypeCode
									END AS OldMoldMoveTypeCode,
									XMLData.MoldMoveTypeCode,
									XMLData.MoldMoveTypeName,
									XMLData.IsGR,
									XMLData.IsCheckWhenGR,
									XMLData.IsGI,
									XMLData.IsMove,
									XMLData.CreateDateTime,
									XMLData.CreateUserID,
									XMLData.ChangeDateTime,
									XMLData.ChangeUserID
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldMoldMoveTypeCode VARCHAR(20),
											 MoldMoveTypeCode VARCHAR(20),
											 MoldMoveTypeName NVARCHAR(100),
											 IsGR BIT,
											 IsCheckWhenGR BIT,
											 IsGI BIT,
											 IsMove BIT,
											 CreateDateTime  DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime  DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20)
											) XMLData


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldMoldMoveTypeCode,
								 @MoldMoveTypeCode,
								 @MoldMoveTypeName,
								 @IsGR,
								 @IsCheckWhenGR,
								 @IsGI,
								 @IsMove,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_MoldMoveType WHERE MoldMoveTypeCode = @MoldMoveTypeCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MoldMoveTypeCode)
					END

                    IF @IsAutoKey = 1 BEGIN
						EXEC SmartFramework.dbo.usp_DoCreateSerial	'STB_MoldMoveType',
																	@MoldMoveTypeCode OUTPUT
                    END

                    INSERT INTO STB_MoldMoveType
						(
						    MoldMoveTypeCode,
						    MoldMoveTypeName,
						    IsGR,
						    IsCheckWhenGR,
						    IsGI,
						    IsMove,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
						    @MoldMoveTypeCode,
						    @MoldMoveTypeName,
						    @IsGR,
						    @IsCheckWhenGR,
						    @IsGI,
						    @IsMove,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_MoldMoveType
						SET
						    MoldMoveTypeCode =   CASE
						                WHEN @MoldMoveTypeCode IS NOT NULL THEN @MoldMoveTypeCode
						                ELSE MoldMoveTypeCode
						            END,
						    MoldMoveTypeName =   CASE
						                WHEN @MoldMoveTypeName IS NOT NULL THEN @MoldMoveTypeName
						                ELSE MoldMoveTypeName
						            END,
						    IsGR =   CASE
						                WHEN @IsGR IS NOT NULL THEN @IsGR
						                ELSE IsGR
						            END,
						    IsCheckWhenGR =   CASE
						                WHEN @IsCheckWhenGR IS NOT NULL THEN @IsCheckWhenGR
						                ELSE IsCheckWhenGR
						            END,
						    IsGI =   CASE
						                WHEN @IsGI IS NOT NULL THEN @IsGI
						                ELSE IsGI
						            END,
						    IsMove =   CASE
						                WHEN @IsMove IS NOT NULL THEN @IsMove
						                ELSE IsMove
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
						    MoldMoveTypeCode = @OldMoldMoveTypeCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_MoldMoveType
						WHERE
						    MoldMoveTypeCode = @MoldMoveTypeCode
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



