-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2026-03-17
-- Description:	Thêm sửa xoá dữ liệu
-- =============================================
CREATE PROCEDURE [dbo].[usp_UnitPriceForModel_uid] 
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
	DECLARE @Id INT
	DECLARE @MaterialCode VARCHAR(255)
	DECLARE @Model VARCHAR(255)
	DECLARE @Size VARCHAR(255)
	DECLARE @Part varchar(255)
	DECLARE @WorkCenterCode varchar(255)
	DECLARE @UnitPrice VARCHAR(50)
	DECLARE @IsUsed BIT
	DECLARE @CreatedBy varchar(50)
	DECLARE @CreatedDate DATETIME
	DECLARE @ModifiedBy VARCHAR(20)
	DECLARE @ModifiedDate DATETIME



	DECLARE @iDoc INT


	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							Id, MaterialCode, Model,Size, Part, WorkCenterCode,
                       UnitPrice, IsUsed, CreatedBy, CreatedDate, ModifiedBy,
                       ModifiedDate

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										Id INT,
                                        MaterialCode varchar(255),
                                        Model varchar(255),
                                        Size varchar(255),
                                        Part varchar(255),
                                        WorkCenterCode VARCHAR(255) ,
                                        UnitPrice VARCHAR(50),
                                        IsUsed BIT,
                                        CreatedBy varchar(50),
                                        CreatedDate DATETIME,
                                        ModifiedBy VARCHAR(50),
                                        ModifiedDate DATETIME
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							Id, MaterialCode, Model,Size, Part, WorkCenterCode,
                       UnitPrice, IsUsed, CreatedBy, CreatedDate, ModifiedBy,
                       ModifiedDate
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										Id INT,
                                        MaterialCode varchar(255),
                                        Model varchar(255),
                                        Size varchar(255),
                                        Part varchar(255),
                                        WorkCenterCode VARCHAR(255) ,
                                        UnitPrice VARCHAR(50),
                                        IsUsed BIT,
                                        CreatedBy varchar(50),
                                        CreatedDate DATETIME,
                                        ModifiedBy VARCHAR(50),
                                        ModifiedDate DATETIME
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
								Id, MaterialCode, Model,Size, Part, WorkCenterCode,
                       UnitPrice, IsUsed, CreatedBy, CreatedDate, ModifiedBy,
                       ModifiedDate
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										Id INT,
                                        MaterialCode varchar(255),
                                        Model varchar(255),
                                        Size varchar(255),
                                        Part varchar(255),
                                        WorkCenterCode VARCHAR(50) ,
                                        UnitPrice DECIMAL(18, 4),
                                        IsUsed BIT,
                                        CreatedBy varchar(50),
                                        CreatedDate DATETIME,
                                        ModifiedBy VARCHAR(50),
                                        ModifiedDate DATETIME
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								  @IUD_FLAG, @Id, @MaterialCode, @Model, @Size,
                @Part, @WorkCenterCode, @UnitPrice, @IsUsed, @CreatedBy,
                @CreatedDate, @ModifiedBy, @ModifiedDate
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM STB_UnitPriceForCode WHERE Id = @ID)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ID)
					END

					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_UnitPriceForCode',@ID OUTPUT
                    END

					INSERT INTO STB_UnitPriceForCode
						(
                                        MaterialCode,
                                        Model,
                                        Size ,
                                        Part,
                                        WorkCenterCode ,
                                        UnitPrice,
                                        IsUsed,
                                        CreatedBy,
                                        CreatedDate

						)
						VALUES
						(
							 @MaterialCode,
	                         @Model,
	                         @Size,
	                         @Part,
	                         @WorkCenterCode, 
	                         @UnitPrice, 
                             1,
	                         @pProcessUserID ,
	                         getdate()

						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE STB_UnitPriceForCode
						SET
                            MaterialCode = ISNULL(@MaterialCode, MaterialCode),
                            Model = ISNULL(@Model, Model),
                            Size = ISNULL(@Size, Size),
                            Part = ISNULL(@Part, Part),
                            WorkCenterCode = ISNULL(@WorkCenterCode, WorkCenterCode),
                            UnitPrice = ISNULL(@UnitPrice, UnitPrice),
                            IsUsed = ISNULL(@IsUsed, IsUsed),
                            ModifiedBy = @pProcessUserID,
                            ModifiedDate = getdate()
						WHERE
							Id = @ID

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM STB_UnitPriceForCode
						WHERE
							Id = @ID

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
