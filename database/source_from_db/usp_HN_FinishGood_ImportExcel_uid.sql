-- =============================================
-- Author:		Nguyễn Hải Triều
-- Create date: 2025-07-29
-- Description:	Thực hiện đẩy file Excel Lên MES
-- =============================================
CREATE PROCEDURE [dbo].[usp_HN_FinishGood_ImportExcel_uid]
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
	DECLARE @Id INT
	DECLARE @LotNo VARCHAR(50)
	DECLARE @MaterialCode VARCHAR(50)
	DECLARE @Voltage DECIMAL(10,2)
	DECLARE @Farad DECIMAL(10,2)
	DECLARE @MBISizeW DECIMAL(10,2)
	DECLARE @MBISizeH DECIMAL(10,2)
	DECLARE @Marking NVARCHAR(10)
	DECLARE @Quantity int
	DECLARE @Unit NVARCHAR(10)
	DECLARE @ProductName NVARCHAR(100)
	DECLARE @PackingID NVARCHAR(50)
	DECLARE @CreateDateTime DATETIME
	DECLARE @CreateUserID VARCHAR(20)
	DECLARE @ChangeDateTime DATETIME
	DECLARE @ChangeUserID VARCHAR(20)
	DECLARE @WarehouseName NVARCHAR(100)
    DECLARE @WarehouseType NVARCHAR(100)

	DECLARE @iDoc INT


	EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml
        BEGIN TRY
		    DECLARE SourceData CURSOR FOR
				SELECT
					'INSERT' AS IUD_FLAG,
							Id, LotNo, MaterialCode, Voltage, Farad, MBISizeW, MBISizeH,
                       Marking, Quantity, Unit, ProductName, PackingID,
                       CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,
					   WarehouseName,WarehouseType

					FROM
							OPENXML(@idoc , @InsertTableName , 2)
							WITH	(
										Id INT,
                    LotNo NVARCHAR(50),
                    MaterialCode NVARCHAR(50),
                    Voltage DECIMAL(10,2),
                    Farad DECIMAL(10,2),
                    MBISizeW DECIMAL(10,2),
                    MBISizeH DECIMAL(10,2),
                    Marking NVARCHAR(10),
                    Quantity INT,
                    Unit NVARCHAR(10),
                    ProductName NVARCHAR(100),
                    PackingID NVARCHAR(50),
                    CreateDateTime DATETIME,
                    CreateUserID VARCHAR(20),
                    ChangeDateTime DATETIME,
                    ChangeUserID VARCHAR(20),
					WarehouseName NVARCHAR(100),
                    WarehouseType NVARCHAR(100)
									)
					UNION ALL
					SELECT
							'UPDATE' AS IUD_FLAG,
							Id, LotNo, MaterialCode, Voltage, Farad, MBISizeW, MBISizeH,
                       Marking, Quantity, Unit, ProductName, PackingID,
                       CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,WarehouseName,WarehouseType
					FROM
							OPENXML(@idoc , @UpdateTableName , 2)
							WITH	(
										Id INT,
                    LotNo NVARCHAR(50),
                    MaterialCode NVARCHAR(50),
                    Voltage DECIMAL(10,2),
                    Farad DECIMAL(10,2),
                    MBISizeW DECIMAL(10,2),
                    MBISizeH DECIMAL(10,2),
                    Marking NVARCHAR(10),
                    Quantity INT,
                    Unit NVARCHAR(10),
                    ProductName NVARCHAR(100),
                    PackingID NVARCHAR(50),
                    CreateDateTime DATETIME,
                    CreateUserID VARCHAR(20),
                    ChangeDateTime DATETIME,
                    ChangeUserID VARCHAR(20),
					WarehouseName NVARCHAR(100),
                    WarehouseType NVARCHAR(100)
									)
					UNION ALL
					SELECT
							'DELETE' AS IUD_FLAG,
							Id, LotNo, MaterialCode, Voltage, Farad, MBISizeW, MBISizeH,
                       Marking, Quantity, Unit, ProductName, PackingID,
                       CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,WarehouseName,WarehouseType
					FROM
							OPENXML(@idoc , @DeleteTableName , 2)
							WITH	(
										Id INT,
                    LotNo NVARCHAR(50),
                    MaterialCode NVARCHAR(50),
                    Voltage DECIMAL(10,2),
                    Farad DECIMAL(10,2),
                    MBISizeW DECIMAL(10,2),
                    MBISizeH DECIMAL(10,2),
                    Marking NVARCHAR(10),
                    Quantity INT,
                    Unit NVARCHAR(10),
                    ProductName NVARCHAR(100),
                    PackingID NVARCHAR(50),
                    CreateDateTime DATETIME,
                    CreateUserID VARCHAR(20),
                    ChangeDateTime DATETIME,
                    ChangeUserID VARCHAR(20),
					WarehouseName NVARCHAR(100),
                    WarehouseType NVARCHAR(100)
									)

			OPEN SourceData

			WHILE 1 = 1 BEGIN
				FETCH NEXT FROM SourceData INTO
								  @IUD_FLAG, @Id, @LotNo, @MaterialCode, @Voltage, @Farad,
                @MBISizeW, @MBISizeH, @Marking, @Quantity, @Unit,
                @ProductName, @PackingID, @CreateDateTime, @CreateUserID,
                @ChangeDateTime, @ChangeUserID,@WarehouseName,@WarehouseType
			
				
				IF @@FETCH_STATUS <> 0 BEGIN
					BREAK
				END
				
				IF @IUD_FLAG = 'INSERT' BEGIN
					
					--RAISERROR( @IUD_FLAG ,16, 1)

					IF EXISTS (SELECT 1 FROM FinishGoodMESInstock_HN WHERE Id = @ID)
					BEGIN
						RAISERROR('Duplicate Data : KeyField = %s', 16, 1, @ID)
					END

					IF @IsAutoKey = 1 BEGIN
                        EXEC SmartFramework.dbo.usp_DoCreateSerial 'FinishGoodMESInstock_HN',@ID OUTPUT
                    END

					INSERT INTO FinishGoodMESInstock_HN
						(
						 LotNo, MaterialCode, Voltage, Farad, MBISizeW, MBISizeH,
                       Marking, Quantity, Unit, ProductName, PackingID,
                       CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID,WarehouseName,WarehouseType
						)
						VALUES
						(
							  @LotNo, @MaterialCode, @Voltage, @Farad, @MBISizeW, @MBISizeH,
                    @Marking, @Quantity, @Unit, @ProductName, @PackingID,
                    GETDATE(), @pProcessUserID, NULL, NULL,@WarehouseName,@WarehouseType
						)


				END ELSE IF @IUD_FLAG = 'UPDATE' BEGIN
					UPDATE FinishGoodMESInstock_HN
						SET
							LotNo = ISNULL(@LotNo, LotNo),
                    MaterialCode = ISNULL(@MaterialCode, MaterialCode),
                    Voltage = ISNULL(@Voltage, Voltage),
                    Farad = ISNULL(@Farad, Farad),
                    MBISizeW = ISNULL(@MBISizeW, MBISizeW),
                    MBISizeH = ISNULL(@MBISizeH, MBISizeH),
                    Marking = ISNULL(@Marking, Marking),
                    Quantity = ISNULL(@Quantity, Quantity),
                    Unit = ISNULL(@Unit, Unit),
                    ProductName = ISNULL(@ProductName, ProductName),
                    PackingID = ISNULL(@PackingID, PackingID),
                    ChangeDateTime = GETDATE(),
                    ChangeUserID = @pProcessUserID,
					WarehouseName=@WarehouseName,
					WarehouseType=@WarehouseType

						WHERE
							Id = @ID

							
				END ELSE IF @IUD_FLAG = 'DELETE' BEGIN
					DELETE FROM FinishGoodMESInstock_HN
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
    --END
END
