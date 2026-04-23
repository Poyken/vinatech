-- =============================================
-- Author:		DinhManh
-- Create date: 2025-04-04
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE usp_QCExportInfoRecord_iud
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
    DECLARE @Model VARCHAR(50)
    DECLARE @Size VARCHAR(10)
    DECLARE @LotNo VARCHAR(30)
    DECLARE @Qty INT
    DECLARE @DateShip DATE
    DECLARE @Customer NVARCHAR(200)
    DECLARE @Korea NVARCHAR(200)
    DECLARE @Note NVARCHAR(1000)
    DECLARE @Grade VARCHAR(5)
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
							[Model],
							[Size],
							LotNo,
							Qty,
							DateShip,
							Customer,
							Korea,
							Note,
							Grade,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										ID INT,
										[Model] VARCHAR(50),
										[Size] VARCHAR(10),
										LotNo VARCHAR(30),
										Qty INT,
										DateShip DATE,
										Customer NVARCHAR(200),
										Korea NVARCHAR(200),
										Note NVARCHAR(1000),
										Grade VARCHAR(5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							ID,
							[Model],
							[Size],
							LotNo,
							Qty,
							DateShip,
							Customer,
							Korea,
							Note,
							Grade,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										ID INT,
										[Model] VARCHAR(50),
										[Size] VARCHAR(10),
										LotNo VARCHAR(30),
										Qty INT,
										DateShip DATE,
										Customer NVARCHAR(200),
										Korea NVARCHAR(200),
										Note NVARCHAR(1000),
										Grade VARCHAR(5),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							ID,
							[Model],
							[Size],
							LotNo,
							Qty,
							DateShip,
							Customer,
							Korea,
							Note,
							Grade,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										ID INT,
										[Model] VARCHAR(50),
										[Size] VARCHAR(10),
										LotNo VARCHAR(30),
										Qty INT,
										DateShip DATE,
										Customer NVARCHAR(200),
										Korea NVARCHAR(200),
										Note NVARCHAR(1000),
										Grade VARCHAR(5),
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
								@Model,
								@Size,
								@LotNo,
								@Qty,
								@DateShip,
								@Customer,
								@Korea,
								@Note,
								@Grade,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				IF @IUD_FLAG = 'INSERT' BEGIN
					

					

					INSERT INTO STB_QCExportInfoRecord
						(
							[Model],
							[Size],
							LotNo,
							Qty,
							DateShip,
							Customer,
							Korea,
							Note,
							Grade,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@Model,
							@Size,
							@LotNo,
							@Qty,
							@DateShip,
							@Customer,
							@Korea,
							@Note,
							@Grade,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN


					UPDATE STB_QCExportInfoRecord
						SET
							Model = ISNULL(@Model, Model),
							Size = ISNULL(@Size, Size),
							LotNo = ISNULL(@LotNo, LotNo),
							Qty = ISNULL(@Qty, Qty),
							DateShip = ISNULL(@DateShip, DateShip),
							Customer = ISNULL(@Customer, Customer),
							Korea = ISNULL(@Korea, Korea),
							Note = ISNULL(@Note, Note),
							Grade = ISNULL(@Grade, Grade),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							ID = @ID

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_QCExportInfoRecord
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
