-- =============================================
-- Author:		DinhManh
-- Create date: 2025-02-17
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_ErrorMaterialsPrices_iud]
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
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @PRICES VARCHAR(50)
	DECLARE @TypeWasteID int        
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID NVARCHAR(50)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID NVARCHAR(50)

	DECLARE @iDoc INT


	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							MaterialCode,
							PRICES,
							TypeWasteID,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										MaterialCode VARCHAR(50),
										PRICES VARCHAR(50),
										TypeWasteID int, 
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							MaterialCode,
							PRICES,
							TypeWasteID,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										MaterialCode VARCHAR(50),
										PRICES VARCHAR(50),
										TypeWasteID int, 
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							MaterialCode,
							PRICES,
							TypeWasteID,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										MaterialCode NVARCHAR(50),
										PRICES VARCHAR(50),
										TypeWasteID int, 
										CreateDateTime DATETIMEOFFSET,
										CreateUserID NVARCHAR(50),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID NVARCHAR(50)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@MaterialCode,
								@PRICES,
								@TypeWasteID,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_MaterialCodeAndPriceWWaste WHERE MaterialCode = @MaterialCode)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					END

					--IF @IsAutoKey = 1 BEGIN
     --                   EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_WidthSlitting',@MaterialCode OUTPUT
     --               END

					INSERT INTO STB_MaterialCodeAndPriceWWaste
						(
							MaterialCode,
							PRICES,
							TypeWasteID,
							CreateDateTime,
							CreateUserID
						)
						VALUES
						(
							@MaterialCode,
							@PRICES,
							@TypeWasteID,
							GETDATE(),
							@pProcessUserID
						)

							INSERT INTO STB_HistoryChangePriceMaterialWaste
						(
							MaterialCode,
							PRICES,
							CreateDateTime,
							CreateUserID
						)
						VALUES
						(
							@MaterialCode,
							@PRICES,
							GETDATE(),
							@pProcessUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_MaterialCodeAndPriceWWaste
						SET
							--MaterialCode = ISNULL(@MaterialCode, MaterialCode),
							PRICES = ISNULL(@PRICES, PRICES),
							TypeWasteID = ISNULL(@TypeWasteID, TypeWasteID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							MaterialCode = @MaterialCode

					INSERT INTO STB_HistoryChangePriceMaterialWaste
						(
							MaterialCode,
							PRICES,
							CreateDateTime,
							CreateUserID
						)
						VALUES
						(
							@MaterialCode,
							@PRICES,
							GETDATE(),
							@pProcessUserID
						)
							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_MaterialCodeAndPriceWWaste
						WHERE
							MaterialCode = @MaterialCode

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
