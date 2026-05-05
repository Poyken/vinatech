-- Procedure: usp_UserTypeBasicPermission_iud






-- =============================================
-- Author:	    Kim Han Young(hykim@awoo.co.kr)
-- Create date: 2016-01-27
-- Browsable : true
-- Description:	사용자 유형별 화면권한 저장
-- =============================================
CREATE PROCEDURE [dbo].[usp_UserTypeBasicPermission_iud]
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
  DECLARE @OldUserType VARCHAR(20)
  DECLARE @OldName VARCHAR(50)
  DECLARE @UserType VARCHAR(20)
  DECLARE @Name VARCHAR(50)
  DECLARE @AllowView BIT
  DECLARE @AllowAdd BIT
  DECLARE @AllowModify BIT
  DECLARE @AllowDelete BIT


	DECLARE @iDoc INT

    EXEC SmartFramework.dbo.usp_GetSerialRule 
			@pTableName = 'STB_UserTypeBasicPermission',
			@pIsAutoKey = @IsAutoKey OUTPUT,
			@pIsLoopIUD = @IsLoopIUD OUTPUT,
			@pPrefixData = @PrefixString OUTPUT,
			@pSerialLen = @SerialLen OUTPUT
    
    IF @IsAutoKey = 0 AND @IsLoopIUD = 0 BEGIN
   
	    EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
	
	    BEGIN TRY
			-- Process Insert Table
            MERGE STB_UserTypeBasicPermission AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
							    ELSE XMLData.OldUserType
							END AS OldUserType,
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.UserType,
							XMLData.Name,
							XMLData.AllowView,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete
					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH  (
										OldUserType VARCHAR(20),
										OldName VARCHAR(50),
										UserType VARCHAR(20),
										Name VARCHAR(50),
										AllowView BIT,
										AllowAdd BIT,
										AllowModify BIT,
										AllowDelete BIT
									) XMLData
							INNER JOIN STB_ScreenInfo SI
								ON	SI.Name = XMLData.Name AND
									SI.IsFolder = 0
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserType = SourceTable.UserType,
					Name = SourceTable.Name,
					AllowView = SourceTable.AllowView,
					AllowAdd = SourceTable.AllowAdd,
					AllowModify = SourceTable.AllowModify,
					AllowDelete = SourceTable.AllowDelete
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserType,
						Name,
						AllowView,
						AllowAdd,
						AllowModify,
						AllowDelete
					)
				VALUES
					(
							SourceTable.UserType,
							SourceTable.Name,
							SourceTable.AllowView,
							SourceTable.AllowAdd,
							SourceTable.AllowModify,
							SourceTable.AllowDelete
					);


			-- Process Update Table
            MERGE STB_UserTypeBasicPermission AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
							    ELSE XMLData.OldUserType
							END AS OldUserType,
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.UserType,
							XMLData.Name,
							XMLData.AllowView,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH  (
										OldUserType VARCHAR(20),
										OldName VARCHAR(50),
										UserType VARCHAR(20),
										Name VARCHAR(50),
										AllowView BIT,
										AllowAdd BIT,
										AllowModify BIT,
										AllowDelete BIT
									) XMLData
							INNER JOIN STB_ScreenInfo SI
								ON	SI.Name = XMLData.Name AND
									SI.IsFolder = 0
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name
				)

			WHEN MATCHED THEN
				UPDATE SET
					UserType = SourceTable.UserType,
					Name = SourceTable.Name,
					AllowView = SourceTable.AllowView,
					AllowAdd = SourceTable.AllowAdd,
					AllowModify = SourceTable.AllowModify,
					AllowDelete = SourceTable.AllowDelete
			WHEN NOT MATCHED THEN
				INSERT
					(
						UserType,
						Name,
						AllowView,
						AllowAdd,
						AllowModify,
						AllowDelete
					)
				VALUES
					(
							SourceTable.UserType,
							SourceTable.Name,
							SourceTable.AllowView,
							SourceTable.AllowAdd,
							SourceTable.AllowModify,
							SourceTable.AllowDelete
					);


			-- Process Delete Table
            MERGE STB_UserTypeBasicPermission AS TargetTable
			USING
				(
					SELECT
							CASE
							    WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
							    ELSE XMLData.OldUserType
							END AS OldUserType,
							CASE
							    WHEN XMLData.OldName IS NULL THEN XMLData.Name
							    ELSE XMLData.OldName
							END AS OldName,
							XMLData.UserType,
							XMLData.Name,
							XMLData.AllowView,
							XMLData.AllowAdd,
							XMLData.AllowModify,
							XMLData.AllowDelete
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH  (
										OldUserType VARCHAR(20),
										OldName VARCHAR(50),
										UserType VARCHAR(20),
										Name VARCHAR(50),
										AllowView BIT,
										AllowAdd BIT,
										AllowModify BIT,
										AllowDelete BIT
									) XMLData
				) AS SourceTable
			ON
				(
					TargetTable.UserType = SourceTable.UserType AND
					TargetTable.Name = SourceTable.Name
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
									XMLData.OldUserType,
									XMLData.OldName,
									XMLData.UserType,
									XMLData.Name,
									XMLData.AllowView,
									XMLData.AllowAdd,
									XMLData.AllowModify,
									XMLData.AllowDelete
							FROM
									OPENXML(@idoc , @InsertTableName , 2)
							        WITH  (
											 OldUserType VARCHAR(20),
											 OldName VARCHAR(50),
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 AllowView BIT,
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT
											) XMLData
									INNER JOIN STB_ScreenInfo SI
										ON	SI.Name = XMLData.Name AND
											SI.IsFolder = 0
							UNION ALL
							SELECT
									'UPDATE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
										ELSE XMLData.OldUserType
									END AS OldUserType,
									CASE 
										WHEN XMLData.OldUserType IS NULL THEN XMLData.Name
										ELSE XMLData.OldUserType
									END AS OldName,
									XMLData.UserType,
									XMLData.Name,
									XMLData.AllowView,
									XMLData.AllowAdd,
									XMLData.AllowModify,
									XMLData.AllowDelete
							FROM
									OPENXML(@idoc , @UpdateTableName , 2)
							        WITH  (
											 OldUserType VARCHAR(20),
											 OldName VARCHAR(50),
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 AllowView BIT,
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT
											) XMLData
									INNER JOIN STB_ScreenInfo SI
										ON	SI.Name = XMLData.Name AND
											SI.IsFolder = 0
							UNION ALL
							SELECT
									'DELETE' AS IUD_FLAG,
									CASE 
										WHEN XMLData.OldUserType IS NULL THEN XMLData.UserType
										ELSE XMLData.OldUserType
									END AS OldUserType,
									CASE 
										WHEN XMLData.OldUserType IS NULL THEN XMLData.Name
										ELSE XMLData.OldUserType
									END AS OldName,
									XMLData.UserType,
									XMLData.Name,
									XMLData.AllowView,
									XMLData.AllowAdd,
									XMLData.AllowModify,
									XMLData.AllowDelete
							FROM
									OPENXML(@idoc , @DeleteTableName , 2)
							        WITH  (
											 OldUserType VARCHAR(20),
											 OldName VARCHAR(50),
											 UserType VARCHAR(20),
											 Name VARCHAR(50),
											 AllowView BIT,
											 AllowAdd BIT,
											 AllowModify BIT,
											 AllowDelete BIT
											) XMLData
									INNER JOIN STB_ScreenInfo SI
										ON	SI.Name = XMLData.Name AND
											SI.IsFolder = 0


            OPEN SourceData

            WHILE 1 = 1 BEGIN
                FETCH NEXT FROM SourceData INTO
								 @IUD_FLAG,
								 @OldUserType,
								 @OldName,
								 @UserType,
								 @Name,
								 @AllowView,
								 @AllowAdd,
								 @AllowModify,
								 @AllowDelete


                IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
                IF @IUD_FLAG = 'INSERT' BEGIN

                    IF EXISTS (SELECT 1 FROM STB_UserTypeBasicPermission WHERE UserType = @UserType) BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @UserType)
					END

                    IF @IsAutoKey = 1 BEGIN
						SELECT
								@MaxKeyField = MAX(UserType)
						FROM
								STB_UserTypeBasicPermission 
						WHERE
								UserType LIKE @PrefixString
													
						IF @MaxKeyField IS NULL BEGIN
						    SET @UserType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + '1', @SerialLen)
						END ELSE BEGIN
						    SET @UserType = @PrefixString + RIGHT(REPLICATE('0',@SerialLen) + CONVERT(VARCHAR, CONVERT(BIGINT, RIGHT(@MaxKeyField, LEN(@MaxKeyField) - LEN(@PrefixString))) + 1), @SerialLen)
						END

                        INSERT INTO STB_UserTypeBasicPermission
						(
						    UserType,
						    Name,
						    AllowView,
						    AllowAdd,
						    AllowModify,
						    AllowDelete
						)
						VALUES
						(
						    @UserType,
						    @Name,
						    @AllowView,
						    @AllowAdd,
						    @AllowModify,
						    @AllowDelete
						)

					END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
                        UPDATE STB_UserTypeBasicPermission
						SET
						    UserType =   CASE
						                WHEN @UserType IS NOT NULL THEN @UserType
						                ELSE UserType
						            END,
						    Name =   CASE
						                WHEN @Name IS NOT NULL THEN @Name
						                ELSE Name
						            END,
						    AllowView =   CASE
						                WHEN @AllowView IS NOT NULL THEN @AllowView
						                ELSE AllowView
						            END,
						    AllowAdd =   CASE
						                WHEN @AllowAdd IS NOT NULL THEN @AllowAdd
						                ELSE AllowAdd
						            END,
						    AllowModify =   CASE
						                WHEN @AllowModify IS NOT NULL THEN @AllowModify
						                ELSE AllowModify
						            END,
						    AllowDelete =   CASE
						                WHEN @AllowDelete IS NOT NULL THEN @AllowDelete
						                ELSE AllowDelete
						            END
						WHERE
						    UserType = @OldUserType AND
						    Name = @OldName
                    END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
                        DELETE FROM STB_UserTypeBasicPermission
						WHERE
						    UserType = @UserType AND
						    Name = @Name
                    END
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

