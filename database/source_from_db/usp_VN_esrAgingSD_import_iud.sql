-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-23
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_VN_esrAgingSD_import_iud]
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
	DECLARE @ID INT
	DECLARE @LotNo VARCHAR(50)
	DECLARE @FileName VARCHAR(50)
	DECLARE @CH VARCHAR(20)
	DECLARE @OCV FLOAT
	DECLARE @OCV등급 FLOAT
	DECLARE @충전V FLOAT
	DECLARE @충전I FLOAT
	DECLARE @방전V FLOAT
	DECLARE @방전I FLOAT
	DECLARE @방전용량 FLOAT
	DECLARE @방전용량등급 FLOAT
	DECLARE @DCR FLOAT
	DECLARE @DCR등급  FLOAT
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
							ID,
							LotNo,
							[FileName],
							CH,
							OCV,
							OCV등급,
							충전V,
							충전I,
							방전V,
							방전I,
							방전용량,
							방전용량등급,
							DCR,
							DCR등급,
							CreateDateTime ,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										ID INT,
										LotNo VARCHAR(50),
										[FileName] VARCHAR(50),
										CH VARCHAR(20),
										OCV FLOAT,
										OCV등급 FLOAT,
										충전V FLOAT,
										충전I FLOAT,
										방전V FLOAT,
										방전I FLOAT,
										방전용량 FLOAT,
										방전용량등급 FLOAT,
										DCR FLOAT,
										DCR등급  FLOAT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							ID,
							LotNo,
							[FileName],
							CH,
							OCV,
							OCV등급,
							충전V,
							충전I,
							방전V,
							방전I,
							방전용량,
							방전용량등급,
							DCR,
							DCR등급,
							CreateDateTime ,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										ID INT,
										LotNo VARCHAR(50),
										[FileName] VARCHAR(50),
										CH VARCHAR(20),
										OCV FLOAT,
										OCV등급 FLOAT,
										충전V FLOAT,
										충전I FLOAT,
										방전V FLOAT,
										방전I FLOAT,
										방전용량 FLOAT,
										방전용량등급 FLOAT,
										DCR FLOAT,
										DCR등급  FLOAT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							ID,
							LotNo,
							[FileName],
							CH,
							OCV,
							OCV등급,
							충전V,
							충전I,
							방전V,
							방전I,
							방전용량,
							방전용량등급,
							DCR,
							DCR등급,
							CreateDateTime ,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										ID INT,
										LotNo VARCHAR(50),
										[FileName] VARCHAR(50),
										CH VARCHAR(20),
										OCV FLOAT,
										OCV등급 FLOAT,
										충전V FLOAT,
										충전I FLOAT,
										방전V FLOAT,
										방전I FLOAT,
										방전용량 FLOAT,
										방전용량등급 FLOAT,
										DCR FLOAT,
										DCR등급  FLOAT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@ID,
								@LotNo,
								@FileName,
								@CH,
								@OCV,
								@OCV등급,
								@충전V,
								@충전I,
								@방전V,
								@방전I,
								@방전용량,
								@방전용량등급,
								@DCR,
								@DCR등급,
								@CreateDateTime ,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_Vvt_SdProds_new WHERE ID = @ID)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ID)
					END

					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_Vvt_SdProds_new',@ID OUTPUT
                    END

					INSERT INTO STB_Vvt_SdProds_new
						(
							LotNo,
							[FileName],
							CH,
							OCV,
							OCV등급,
							충전V,
							충전I,
							방전V,
							방전I,
							방전용량,
							방전용량등급,
							DCR,
							DCR등급,
							CreateDateTime ,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@LotNo,
							@FileName,
							@CH,
							@OCV,
							@OCV등급,
							@충전V,
							@충전I,
							@방전V,
							@방전I,
							@방전용량,
							@방전용량등급,
							@DCR,
							@DCR등급,
							GETDATE() ,
							@pProcessUserID,
							@ChangeDateTime,
							@ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_Vvt_SdProds_new
						SET
							LotNo = ISNULL(@LotNo, LotNo),
							[FileName] = ISNULL(@FileName, [FileName]),
							CH = ISNULL(@CH, CH),
							OCV = ISNULL(@OCV, OCV),
							OCV등급 = ISNULL(@OCV등급, OCV등급),
							충전V = ISNULL(@충전V, 충전V),
							충전I = ISNULL(@충전I, 충전I),
							방전V = ISNULL(@방전V, 방전V),
							방전I = ISNULL(@방전I, 방전I),
							방전용량 = ISNULL(@방전용량, 방전용량),
							방전용량등급 = ISNULL(@방전용량등급, 방전용량등급),
							DCR = ISNULL(@DCR, DCR),
							DCR등급 = ISNULL(@DCR등급, DCR등급),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							ID = @ID

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_Vvt_SdProds_new
						WHERE
							ID = @ID

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
    --END


END
