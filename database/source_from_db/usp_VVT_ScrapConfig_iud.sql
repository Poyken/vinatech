-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-04
-- Description:	scrap config for B598 IUD
-- =============================================
CREATE PROCEDURE usp_VVT_ScrapConfig_iud
	-- Add the parameters for the stored procedure here
		@pProcessUserID VARCHAR(20),
		@pProcessLanguage VARCHAR(20),
		@pProcessViewName VARCHAR(50) = null,
		@pXml NVARCHAR(MAX) = null
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
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
	DECLARE @IDNG INT
	DECLARE @CodeNG NVARCHAR(10)
	DECLARE @NG NVARCHAR(100)
	DECLARE @Desc NVARCHAR(100)
	DECLARE @WorkCenterCode VARCHAR(10)
	DECLARE @IsUsed BIT  
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(20)

	DECLARE @iDoc INT


	-----------------------------------------------------------
	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							IDNG,
							CodeNG,
							NG,
							[Desc],
							WorkCenterCode,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										IDNG INT,
										CodeNG NVARCHAR(10),
										NG NVARCHAR(100),
										[Desc] NVARCHAR(100),
										WorkCenterCode VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							IDNG,
							CodeNG,
							NG,
							[Desc],
							WorkCenterCode,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										IDNG INT,
										CodeNG NVARCHAR(10),
										NG NVARCHAR(100),
										[Desc] NVARCHAR(100),
										WorkCenterCode VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							IDNG,
							CodeNG,
							NG,
							[Desc],
							WorkCenterCode,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										IDNG INT,
										CodeNG NVARCHAR(10),
										NG NVARCHAR(100),
										[Desc] NVARCHAR(100),
										WorkCenterCode VARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@IDNG ,
								@CodeNG ,
								@NG ,
								@Desc ,
								@WorkCenterCode ,
								@IsUsed , 
								@CreateDateTime ,
								@CreateUserID ,
								@ChangeDateTime ,
								@ChangeUserID 
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_VN_NG WHERE IDNG = @IDNG)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @IDNG)
					END

					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_NG',@IDNG OUTPUT
                    END

					INSERT INTO STB_VN_NG
						(
							CodeNG,
							NG,
							[Desc],
							WorkCenterCode,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@CodeNG ,
							@NG ,
							@Desc ,
							@WorkCenterCode ,
							@IsUsed , 
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime ,
							@ChangeUserID 
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_VN_NG
						SET
							CodeNG = ISNULL(@CodeNG, CodeNG),
							NG = ISNULL(@NG, NG),
							[Desc] = ISNULL (@Desc, [Desc]),
							WorkCenterCode = ISNULL(@WorkCenterCode, WorkCenterCode),
							IsUsed = ISNULL(@IsUsed, IsUsed),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							IDNG = @IDNG

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_VN_NG
						WHERE
							IDNG = @IDNG

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


		-------------------------------------------



END
