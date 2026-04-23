-- =============================================
-- Author:		DinhManh
-- Create date: 2025-11-17
-- Description:	modify quantity when print label on B523 
-- =============================================
CREATE PROCEDURE usp_PackingQtyPrintB523_iud		-- STB_PackingQtyPrintB523_VVT
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
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @PackingQty VARCHAR(10)
	DECLARE @IsUsed BIT
	DECLARE @Notes NVARCHAR(MAX)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(30)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(30)

	DECLARE @iDoc INT



	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							ID,
							MaterialCode,
							PackingQty,
							IsUsed,
							Notes,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										ID INT,
										MaterialCode VARCHAR(50),
										PackingQty VARCHAR(10),
										IsUsed BIT,
										Notes NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(30),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(30)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							ID,
							MaterialCode,
							PackingQty,
							IsUsed,
							Notes,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										ID INT,
										MaterialCode VARCHAR(50),
										PackingQty VARCHAR(10),
										IsUsed BIT,
										Notes NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(30),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(30)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							ID,
							MaterialCode,
							PackingQty,
							IsUsed,
							Notes,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										ID INT,
										MaterialCode VARCHAR(50),
										PackingQty VARCHAR(10),
										IsUsed BIT,
										Notes NVARCHAR(MAX),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(30),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(30)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@ID,
								@MaterialCode,
								@PackingQty,
								@IsUsed,
								@Notes,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					--IF EXISTS (SELECT 1 FROM STB_PackingQtyPrintB523_VVT WHERE MaterialCode = @MaterialCode)
					--BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @MaterialCode)
					--END

					--IF @IsAutoKey = 1 BEGIN
     --                   EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_PackingQtyPrintB523_VVT',@MaterialCode OUTPUT
     --               END

					INSERT INTO STB_PackingQtyPrintB523_VVT
						(
							MaterialCode,
							PackingQty,
							IsUsed,
							Notes,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@MaterialCode,
							@PackingQty,
							@IsUsed,
							@Notes,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_PackingQtyPrintB523_VVT
						SET
							MaterialCode = ISNULL(@MaterialCode, MaterialCode),
							PackingQty = ISNULL(@PackingQty, PackingQty),
							IsUsed = ISNULL(@IsUsed, IsUsed),
							Notes = ISNULL(@Notes, Notes),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							ID = @ID

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_PackingQtyPrintB523_VVT
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
END
