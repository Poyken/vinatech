-- =============================================
-- Author:		Mr.Manh
-- Create date: 2026-02-07
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_GetIOQCDefectInfo_iud
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
	DECLARE @DefectCode VARCHAR(20)
	DECLARE @BasicDefectName NVARCHAR(100)
	DECLARE @DefectDesc NVARCHAR(MAX)
	DECLARE @InspectionDocType NVARCHAR(10)
	DECLARE @IsUsed BIT        
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)

	DECLARE @iDoc INT



	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							--ID,
							DefectCode,
							BasicDefectName,
							DefectDesc,
							InspectionDocType,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										--ID INT,
										DefectCode VARCHAR(20),
										BasicDefectName NVARCHAR(100),
										DefectDesc NVARCHAR(MAX),
										InspectionDocType NVARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)

									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							DefectCode,
							BasicDefectName,
							DefectDesc,
							InspectionDocType,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										--ID INT,
										DefectCode VARCHAR(20),
										BasicDefectName NVARCHAR(100),
										DefectDesc NVARCHAR(MAX),
										InspectionDocType NVARCHAR(10),
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							DefectCode,
							BasicDefectName,
							DefectDesc,
							InspectionDocType,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										DefectCode VARCHAR(20),
										BasicDefectName NVARCHAR(100),
										DefectDesc NVARCHAR(MAX),
										InspectionDocType NVARCHAR(10),
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
								@DefectCode,
								@BasicDefectName,
								@DefectDesc,
								@InspectionDocType,
								@IsUsed,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					--IF EXISTS (SELECT 1 FROM STB_PackingQtyWarehouse WHERE ID = @ID)
					--BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ID)
					--END

					--IF @IsAutoKey = 1 BEGIN
     --                   EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PackingQtyWarehouse',@ID OUTPUT
     --               END

					INSERT INTO STB_IOQCDefectInfo
						(
							DefectCode,
							BasicDefectName,
							DefectDesc,
							InspectionDocType,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@DefectCode,
							@BasicDefectName,
							@DefectDesc,
							@InspectionDocType,
							@IsUsed,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_IOQCDefectInfo
						SET
							--DefectCode = ISNULL(@DefectCode, DefectCode),
							BasicDefectName = ISNULL(@BasicDefectName, BasicDefectName),
							DefectDesc = ISNULL(@DefectDesc, DefectDesc),
							InspectionDocType = ISNULL(@InspectionDocType, InspectionDocType),
							IsUsed = ISNULL(@IsUsed, IsUsed),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							DefectCode = @DefectCode

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_IOQCDefectInfo
						WHERE
							DefectCode = @DefectCode

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
