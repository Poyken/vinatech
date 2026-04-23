-- =============================================
-- Author:		DinhManh
-- Create date: 2025-06-04
-- Description: Special SparePart Info IUD
-- =============================================
CREATE PROCEDURE usp_VN_SpecialSparePartInfo_iud
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
	DECLARE @SparePartCode VARCHAR(30)
	DECLARE @SparePartName NVARCHAR(100)
	DECLARE @SparePartSpec01 NVARCHAR(100)
	DECLARE @UsingQty INT
	DECLARE @Model VARCHAR(10)
	DECLARE @LotQty INT
	DECLARE @CycleReplace BIGINT
	DECLARE @IsUsed BIT 
	DECLARE @CompanyCode VARCHAR(10)
	DECLARE @WorkCenterCode VARCHAR(10)
	DECLARE @SPNote NVARCHAR(200)
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
							SparePartCode,
							SparePartName,
							SparePartSpec01,
							UsingQty,
							Model,
							LotQty,
							CycleReplace,
							IsUsed,
							CompanyCode,
							WorkCenterCode,
							SPNote,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										SparePartCode VARCHAR(30),
										SparePartName NVARCHAR(100),
										SparePartSpec01 NVARCHAR(100),
										UsingQty INT,
										Model VARCHAR(10),
										LotQty INT,
										CycleReplace BIGINT,
										IsUsed BIT,
										CompanyCode VARCHAR(10),
										WorkCenterCode VARCHAR(10),
										SPNote NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							SparePartCode,
							SparePartName,
							SparePartSpec01,
							UsingQty,
							Model,
							LotQty,
							CycleReplace,
							IsUsed,
							CompanyCode,
							WorkCenterCode,
							SPNote,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										SparePartCode VARCHAR(30),
										SparePartName NVARCHAR(100),
										SparePartSpec01 NVARCHAR(100),
										UsingQty INT,
										Model VARCHAR(10),
										LotQty INT,
										CycleReplace BIGINT,
										IsUsed BIT,
										CompanyCode VARCHAR(10),
										WorkCenterCode VARCHAR(10),
										SPNote NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							SparePartCode,
							SparePartName,
							SparePartSpec01,
							UsingQty,
							Model,
							LotQty,
							CycleReplace,
							IsUsed,
							CompanyCode,
							WorkCenterCode,
							SPNote,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										SparePartCode VARCHAR(30),
										SparePartName NVARCHAR(100),
										SparePartSpec01 NVARCHAR(100),
										UsingQty INT,
										Model VARCHAR(10),
										LotQty INT,
										CycleReplace BIGINT,
										IsUsed BIT,
										CompanyCode VARCHAR(10),
										WorkCenterCode VARCHAR(10),
										SPNote NVARCHAR(200),
										CreateDateTime DATETIMEOFFSET,
										CreateUserID VARCHAR(20),
										ChangeDateTime DATETIMEOFFSET,
										ChangeUserID VARCHAR(20)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								@IUD_FLAG,
								@SparePartCode,
								@SparePartName,
								@SparePartSpec01,
								@UsingQty,
								@Model,
								@LotQty,
								@CycleReplace,
								@IsUsed,
								@CompanyCode,
								@WorkCenterCode,
								@SPNote,
								@CreateDateTime,
								@CreateUserID,
								@ChangeDateTime,
								@ChangeUserID
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_VN_SpecialSparePartInfo WHERE SparePartCode = @SparePartCode)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @SparePartCode)
					END

					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_VN_SpecialSparePartInfo',@SparePartCode OUTPUT
                    END

					INSERT INTO STB_VN_SpecialSparePartInfo
						(
							SparePartCode,
							SparePartName,
							SparePartSpec01,
							UsingQty,
							Model,
							LotQty,
							CycleReplace,
							IsUsed,
							CompanyCode,
							WorkCenterCode,
							SPNote,
							CreateDateTime,
							CreateUserID,
							ChangeDateTime,
							ChangeUserID
						)
						VALUES
						(
							@SparePartCode,
							@SparePartName,
							@SparePartSpec01,
							@UsingQty,
							@Model,
							@LotQty,
							@CycleReplace,
							@IsUsed,
							@CompanyCode,
							@WorkCenterCode,
							@SPNote,
							GETDATE(),
							@pProcessUserID,
							@ChangeDateTime,
						    @ChangeUserID
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_VN_SpecialSparePartInfo
						SET
							SparePartCode = ISNULL(@SparePartCode, SparePartCode),
							SparePartName = ISNULL(@SparePartName, SparePartName),
							SparePartSpec01 = ISNULL(@SparePartSpec01, SparePartSpec01),
							UsingQty = ISNULL(@UsingQty, UsingQty),
							Model = ISNULL(@Model, Model),
							LotQty = ISNULL(@LotQty, LotQty),
							CycleReplace = ISNULL(@CycleReplace, CycleReplace),
							IsUsed = ISNULL(@IsUsed, IsUsed),
							CompanyCode = ISNULL(@CompanyCode, CompanyCode),
							WorkCenterCode = ISNULL(@WorkCenterCode, WorkCenterCode),
							SPNote = ISNULL(@SPNote, SPNote),
							CreateDateTime = ISNULL(@CreateDateTime, CreateDateTime),
							CreateUserID = ISNULL(@CreateUserID, CreateUserID),
							ChangeDateTime = GETDATE(),
							ChangeUserID = @pProcessUserID

						WHERE
							SparePartCode = @SparePartCode

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_VN_SpecialSparePartInfo
						WHERE
							SparePartCode = @SparePartCode

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
