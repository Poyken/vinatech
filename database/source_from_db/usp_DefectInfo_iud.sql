
-- =============================================
-- Author:	    Anonymous()
-- Create date: 2018-09-13
-- Browsable : true
-- Group : 품질관리 > [C132] 불량증상정보 업데이트
-- Description:	
-- Modified:
-- 2020-11-12 업데이트시 Duplicate Error 오류해결 -> Case문 추가

-- =============================================
CREATE PROCEDURE [dbo].[usp_DefectInfo_iud]
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
  DECLARE @OldDefectCode VARCHAR(20)
  DECLARE @DefectCode VARCHAR(20)
  DECLARE @BasicDefectName NVARCHAR(50)
  DECLARE @DefectDesc NVARCHAR(200)
  DECLARE @DefectGroupCode VARCHAR(20)
  DECLARE @UseGroup NVARCHAR(50)
  DECLARE @DisplayIndex INT
  DECLARE @IsRealDefect BIT
  DECLARE @IsUsed BIT
  DECLARE @DefectImage BIGINT
  DECLARE @CreateDateTime DATETIME
  DECLARE @CreateUserID VARCHAR(20)
  DECLARE @ChangeDateTime DATETIME
  DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @DirectlyUnder NVARCHAR(50)
	DECLARE @WorkCenterCode VARCHAR(20)
	DECLARE @iDoc INT
	DECLARE @DefectCause NVARCHAR(100)

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_DefectInfo',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_DefectInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							DefectCode,
							BasicDefectName,
							DefectDesc,
							DefectGroupCode,
							UseGroup,
							DisplayIndex,
							IsRealDefect,
							IsUsed,
							DefectImage,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							DirectlyUnder,
							WorkCenterCode,
							DefectCause
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldDefectCode VARCHAR(20),
										DefectCode VARCHAR(20),
										BasicDefectName NVARCHAR(50),
										DefectDesc NVARCHAR(200),
										DefectGroupCode VARCHAR(20),
										UseGroup NVARCHAR(50),
										DisplayIndex INT,
										IsRealDefect BIT,
										IsUsed BIT,
										DefectImage BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										DirectlyUnder NVARCHAR(50),
										WorkCenterCode VARCHAR(20),
										DefectCause NVARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectCode = SourceTable.DefectCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					BasicDefectName = ISNULL(SourceTable.BasicDefectName,TargetTable.BasicDefectName),
					DefectDesc = ISNULL(SourceTable.DefectDesc,TargetTable.DefectDesc),
					DefectGroupCode = ISNULL(SourceTable.DefectGroupCode,TargetTable.DefectGroupCode),
					UseGroup = ISNULL(SourceTable.UseGroup,TargetTable.UseGroup),
					DisplayIndex = ISNULL(SourceTable.DisplayIndex,TargetTable.DisplayIndex),
					IsRealDefect = ISNULL(SourceTable.IsRealDefect,TargetTable.IsRealDefect),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					DirectlyUnder = ISNULL(SourceTable.DirectlyUnder,TargetTable.DirectlyUnder),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
				    DefectCause=ISNULL(SourceTable.DefectCause,TargetTable.DefectCause)
			WHEN NOT MATCHED THEN

				INSERT
					(
						DefectCode,
						BasicDefectName,
						DefectDesc,
						DefectGroupCode,
						UseGroup,
						DisplayIndex,
						IsRealDefect,
						IsUsed,
						DefectImage,
						CreateDateTime,
						CreateUserID,
						DirectlyUnder,
						WorkCenterCode,
						DefectCause
					)
				VALUES
					(
							SourceTable.DefectCode,
							SourceTable.BasicDefectName,
							SourceTable.DefectDesc,
							SourceTable.DefectGroupCode,
							SourceTable.UseGroup,
							SourceTable.DisplayIndex,
							SourceTable.IsRealDefect,
							SourceTable.IsUsed,
							SourceTable.DefectImage,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.DirectlyUnder,
							SourceTable.WorkCenterCode,
							SourceTable.DefectCause
					);


			-- Process Update Table
            MERGE STB_DefectInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							DefectCode,
							BasicDefectName,
							DefectDesc,
							DefectGroupCode,
							UseGroup,
							DisplayIndex,
							IsRealDefect,
							IsUsed,
							DefectImage,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							DirectlyUnder,
							WorkCenterCode,
							DefectCause
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldDefectCode VARCHAR(20),
										DefectCode VARCHAR(20),
										BasicDefectName NVARCHAR(50),
										DefectDesc NVARCHAR(200),
										DefectGroupCode VARCHAR(20),
										UseGroup NVARCHAR(50),
										DisplayIndex INT,
										IsRealDefect BIT,
										IsUsed BIT,
										DefectImage BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										DirectlyUnder NVARCHAR(50),
										WorkCenterCode NVARCHAR(20),
										DefectCause NVARCHAR(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectCode = SourceTable.OldDefectCode
				)

			WHEN MATCHED THEN
				UPDATE SET
					DefectCode = ISNULL(SourceTable.DefectCode,TargetTable.DefectCode),
					BasicDefectName = ISNULL(SourceTable.BasicDefectName,TargetTable.BasicDefectName),
					DefectDesc = ISNULL(SourceTable.DefectDesc,TargetTable.DefectDesc),
					DefectGroupCode = ISNULL(SourceTable.DefectGroupCode,TargetTable.DefectGroupCode),
					UseGroup = ISNULL(SourceTable.UseGroup,TargetTable.UseGroup),
					DisplayIndex = ISNULL(SourceTable.DisplayIndex,TargetTable.DisplayIndex),
					IsRealDefect = ISNULL(SourceTable.IsRealDefect,TargetTable.IsRealDefect),
					IsUsed = ISNULL(SourceTable.IsUsed,TargetTable.IsUsed),
					DefectImage = ISNULL(SourceTable.DefectImage,TargetTable.DefectImage),
					ChangeDateTime = ISNULL(SourceTable.ChangeDateTime,TargetTable.ChangeDateTime),
					ChangeUserID = ISNULL(SourceTable.ChangeUserID,TargetTable.ChangeUserID),
					DirectlyUnder = ISNULL(SourceTable.DirectlyUnder,TargetTable.DirectlyUnder),
					WorkCenterCode = ISNULL(SourceTable.WorkCenterCode,TargetTable.WorkCenterCode),
					DefectCause=ISNULL(SourceTable.DefectCause,TargetTable.DefectCause)
			WHEN NOT MATCHED THEN
				INSERT
					(
						DefectCode,
						BasicDefectName,
						DefectDesc,
						DefectGroupCode,
						UseGroup,
						DisplayIndex,
						IsRealDefect,
						IsUsed,
						DefectImage,
						CreateDateTime,
						CreateUserID,
						DirectlyUnder,
						WorkCenterCode,
						DefectCause
					)
				VALUES
					(
							SourceTable.DefectCode,
							SourceTable.BasicDefectName,
							SourceTable.DefectDesc,
							SourceTable.DefectGroupCode,
							SourceTable.UseGroup,
							SourceTable.DisplayIndex,
							SourceTable.IsRealDefect,
							SourceTable.IsUsed,
							SourceTable.DefectImage,
							SourceTable.CreateDateTime,
							SourceTable.CreateUserID,
							SourceTable.DirectlyUnder,
							SourceTable.WorkCenterCode,
							SourceTable.DefectCause
					);


			-- Process Delete Table
            MERGE STB_DefectInfo AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN OldDefectCode IS NULL THEN DefectCode
							    ELSE OldDefectCode
							END AS OldDefectCode,
							DefectCode,
							BasicDefectName,
							DefectDesc,
							DefectGroupCode,
							UseGroup,
							DisplayIndex,
							IsRealDefect,
							IsUsed,
							DefectImage,
							GETDATE() AS CreateDateTime,
							@pProcessUserID AS CreateUserID,
							GETDATE() AS ChangeDateTime,
							@pProcessUserID AS ChangeUserID,
							DirectlyUnder,
							WorkCenterCode,
							DefectCause
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldDefectCode VARCHAR(20),
										DefectCode VARCHAR(20),
										BasicDefectName NVARCHAR(50),
										DefectDesc NVARCHAR(200),
										DefectGroupCode VARCHAR(20),
										UseGroup NVARCHAR(50),
										DisplayIndex INT,
										IsRealDefect BIT,
										IsUsed BIT,
										DefectImage BIGINT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20),
										DirectlyUnder NVARCHAR(50),
										WorkCenterCode VARCHAR(20),
										DefectCause nvarchar(100)
									) 
				) AS SourceTable
			ON
				(
					TargetTable.DefectCode = SourceTable.DefectCode
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

									--OldDefectCode,                                       -- 원본백업
						CASE 
							WHEN OldDefectCode IS NULL THEN DefectCode
							ELSE OldDefectCode
						END AS OldDefectCode,                                         -- 2020.11.13 변경사항

						DefectCode,
						BasicDefectName,
						DefectDesc,
						DefectGroupCode,
						UseGroup,
						DisplayIndex,
						IsRealDefect,
						IsUsed,
						DefectImage,
						CreateDateTime,
						CreateUserID,
						ChangeDateTime,
						ChangeUserID,
						DirectlyUnder,
						WorkCenterCode,
						DefectCause
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldDefectCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 BasicDefectName NVARCHAR(50),
											 DefectDesc NVARCHAR(200),
											 DefectGroupCode VARCHAR(20),
											 UseGroup NVARCHAR(50),
											 DisplayIndex INT,
											 IsRealDefect BIT,
											 IsUsed BIT,
											 DefectImage BIGINT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 DirectlyUnder NVARCHAR(50),
											  WorkCenterCode VARCHAR(20),
											  DefectCause NVARCHAR(100)
											)
							UNION ALL

							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectCode IS NULL THEN DefectCode
										ELSE OldDefectCode
									END AS OldDefectCode,
									DefectCode,
									BasicDefectName,
									DefectDesc,
									DefectGroupCode,
									UseGroup,
									DisplayIndex,
									IsRealDefect,
									IsUsed,
									DefectImage,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									DirectlyUnder,
									WorkCenterCode,
									DefectCause
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldDefectCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 BasicDefectName NVARCHAR(50),
											 DefectDesc NVARCHAR(200),
											 DefectGroupCode VARCHAR(20),
											 UseGroup NVARCHAR(50),
											 DisplayIndex INT,
											 IsRealDefect BIT,
											 IsUsed BIT,
											 DefectImage BIGINT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 DirectlyUnder NVARCHAR(50),
											  WorkCenterCode VARCHAR(20),
											  DefectCause nvarchar(100)
											)
							UNION ALL

							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN OldDefectCode IS NULL THEN DefectCode
										ELSE OldDefectCode
									END AS OldDefectCode,
									DefectCode,
									BasicDefectName,
									DefectDesc,
									DefectGroupCode,
									UseGroup,
									DisplayIndex,
									IsRealDefect,
									IsUsed,
									DefectImage,
									CreateDateTime,
									CreateUserID,
									ChangeDateTime,
									ChangeUserID,
									DirectlyUnder,
									WorkCenterCode,
								DefectCause
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldDefectCode VARCHAR(20),
											 DefectCode VARCHAR(20),
											 BasicDefectName NVARCHAR(50),
											 DefectDesc NVARCHAR(200),
											 DefectGroupCode VARCHAR(20),
											 UseGroup NVARCHAR(50),
											 DisplayIndex INT,
											 IsRealDefect BIT,
											 IsUsed BIT,
											 DefectImage BIGINT,
											 CreateDateTime DATETIMEOFFSET,
											 CreateUserID VARCHAR(20),
											 ChangeDateTime DATETIMEOFFSET,
											 ChangeUserID VARCHAR(20),
											 	DirectlyUnder NVARCHAR(50),
												 WorkCenterCode VARCHAR(20),
												 DefectCause nvarchar(100)
											) 


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldDefectCode,
								 @DefectCode,
								 @BasicDefectName,
								 @DefectDesc,
								 @DefectGroupCode,
								 @UseGroup,
								 @DisplayIndex,
								 @IsRealDefect,
								 @IsUsed,
								 @DefectImage,
								 @CreateDateTime,
								 @CreateUserID,
								 @ChangeDateTime,
								 @ChangeUserID,
								 @DirectlyUnder,
								 @WorkCenterCode,
								 @DefectCause


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END


                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_DefectInfo WHERE DefectCode = @DefectCode) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @DefectCode)
					END

					--select @WorkCenterCode=WorkCenterCode from STB_UserInfo where UserID=@ProcessUserID  update 2026-01-29

                    IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DefectInfo',@DefectCode OUTPUT
                    END

                    INSERT INTO STB_DefectInfo
						(
						    DefectCode,
						    BasicDefectName,
						    DefectDesc,
						    DefectGroupCode,
						    UseGroup,
						    DisplayIndex,
						    IsRealDefect,
						    IsUsed,
						    DefectImage,
						    CreateDateTime,
						    CreateUserID,
						    ChangeDateTime,
						    ChangeUserID,
							DirectlyUnder,
							WorkCenterCode,
							DefectCause
						)
						VALUES
						(
						    @DefectCode,
						    @BasicDefectName,
						    @DefectDesc,
						    @DefectGroupCode,
						    @UseGroup,
						    @DisplayIndex,
						    @IsRealDefect,
						    @IsUsed,
						    @DefectImage,
						    GETDATE(),
						    @pProcessUserID,
						    @ChangeDateTime,
						    @ChangeUserID,
							@DirectlyUnder,
							@WorkCenterCode,
							@DefectCause
						)

				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                    UPDATE STB_DefectInfo
						SET
						    DefectCode =   ISNULL(@DefectCode,DefectCode),
						    BasicDefectName =   ISNULL(@BasicDefectName,BasicDefectName),
						    DefectDesc =   ISNULL(@DefectDesc,DefectDesc),
						    DefectGroupCode =   ISNULL(@DefectGroupCode,DefectGroupCode),
						    UseGroup =   ISNULL(@UseGroup,UseGroup),
						    DisplayIndex =   ISNULL(@DisplayIndex,DisplayIndex),
						    IsRealDefect =   ISNULL(@IsRealDefect,IsRealDefect),
						    IsUsed =   ISNULL(@IsUsed,IsUsed),
						    DefectImage =   ISNULL(@DefectImage,DefectImage),
						    CreateDateTime =   ISNULL(@CreateDateTime,CreateDateTime),
						    CreateUserID =   ISNULL(@CreateUserID,CreateUserID),
						    ChangeDateTime = GETDATE(),
						    ChangeUserID = @pProcessUserID,
							DirectlyUnder=@DirectlyUnder,
							DefectCause=@DefectCause,
							WorkCenterCode = ISNULL(@WorkCenterCode,WorkCenterCode)  -- updated 2026-01-29
						WHERE
						    DefectCode = @OldDefectCode
                END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                    DELETE FROM STB_DefectInfo
						WHERE
						    DefectCode = @OldDefectCode
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
