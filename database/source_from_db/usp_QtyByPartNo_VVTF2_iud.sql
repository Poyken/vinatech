-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[usp_QtyByPartNo_VVTF2_iud]
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
	DECLARE @PartNo VARCHAR(50)
	DECLARE @Qty VARCHAR(10)
	DECLARE @IsUsed BIT
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
							PartNo,
							Qty,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										ID INT,
										PartNo NVARCHAR(50),
										Qty INT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(30),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(30)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							ID,
							PartNo,
							Qty,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										ID INT,
										PartNo NVARCHAR(50),
										Qty INT,
										IsUsed BIT,
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(30),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(30)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							ID,
							PartNo,
							Qty,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										ID INT,
										PartNo NVARCHAR(50),
										Qty INT,
										IsUsed BIT,
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
								@PartNo,
								@Qty,
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

					--IF EXISTS (SELECT 1 FROM STB_QtyPrintB523_VVT WHERE PartNo = @PartNo)
					--BEGIN
					--	RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @PartNo)
					--END

					--IF @IsAutoKey = 1 BEGIN
     --                   EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_QtyPrintB523_VVT',@PartNo OUTPUT
     --               END

					INSERT INTO STB_SavePackingQty_VVT_F2
						(
							PartNo,
							Qty,
							IsUsed,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
						    ChangeUserID
						)
						VALUES
						(
							@PartNo,
							@Qty,
							@IsUsed,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_SavePackingQty_VVT_F2
						SET
							PartNo = ISNULL(@PartNo, PartNo),
							Qty = ISNULL(@Qty, Qty),
							IsUsed = ISNULL(@IsUsed, IsUsed),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							ID = @ID

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_SavePackingQty_VVT_F2
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
