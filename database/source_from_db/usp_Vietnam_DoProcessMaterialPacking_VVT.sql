CREATE PROCEDURE [dbo].[usp_Vietnam_DoProcessMaterialPacking_VVT]
    @pProcessUserID VARCHAR(20),
    @pProcessLanguage VARCHAR(20),
    @pProcessViewName VARCHAR(50),
    @pXml NVARCHAR(MAX) = NULL,
    @pMergeQty INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ProcessUserID VARCHAR(20) = @pProcessUserID;
    DECLARE @ProcessLanguage VARCHAR(20) = @pProcessLanguage;
    DECLARE @ProcessViewName VARCHAR(50) = @pProcessViewName;
    DECLARE @TableName VARCHAR(100) = '/DataSet/' + @ProcessViewName;
    DECLARE @ERROR_MSG NVARCHAR(MAX);
    DECLARE @iDoc INT;
    DECLARE @LotID VARCHAR(50);
    DECLARE @PackingIdParent VARCHAR(50);
    DECLARE @NewLotID VARCHAR(50);
    DECLARE @TotalInitialQty NUMERIC(20, 5) = 0;  -- Biến lưu tổng số lượng
    DECLARE @TotalCurrentQty NUMERIC(20, 5) = 0;  -- Biến lưu tổng số lượng
    DECLARE @CurrentQty NUMERIC(20, 5) = 0;  -- Biến lưu số lượng hiện tại
    DECLARE @MaterialLotNo VARCHAR(50);
    DECLARE @MaterialWarehouseCode VARCHAR(50);

    -- Mở giao dịch
    BEGIN TRANSACTION;

    BEGIN TRY
        -- Tạo mã chung SM
        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialDocLotInfo', @NewLotID OUTPUT;
        SET @NewLotID = 'SM' + SUBSTRING(@NewLotID, 3, LEN(@NewLotID) - 2);

        -- Xử lý XML
        EXEC sp_xml_preparedocument @iDoc OUTPUT, @pXml;

        -- Khởi tạo cursor để duyệt qua dữ liệu từ XML
        DECLARE SourceData CURSOR FOR
            SELECT 
                LotID, 
                PackingIdParent,
                MaterialWarehouseCode
            FROM OPENXML(@iDoc, @TableName, 2)
            WITH (
                LotID VARCHAR(50), 
                PackingIdParent VARCHAR(50),
                MaterialWarehouseCode VARCHAR(50)
            );

        OPEN SourceData;

        -- Duyệt qua các bản ghi từ XML
        FETCH NEXT FROM SourceData INTO 
            @LotID, 
            @PackingIdParent,
            @MaterialWarehouseCode;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            DECLARE @MergeParentId VARCHAR(50) = NULL;

            SELECT @MergeParentId = MergeParentId FROM STB_MaterialLotInfo WHERE LotID = @LotID;

            -- Kiểm tra dữ liệu null hoặc rỗng
            IF (@PackingIdParent IS NULL OR @PackingIdParent = '' OR @MaterialWarehouseCode <> 'ROH_HN_WH' OR @MergeParentId IS NOT NULL)
            BEGIN
                IF(@PackingIdParent IS NULL OR @PackingIdParent = '')
                BEGIN
                    RAISERROR(N'PackingIdParent là NULL hoặc rỗng', 16, 1);
                    ROLLBACK TRANSACTION;  -- Rollback giao dịch nếu có lỗi
                    BREAK;
                END
                ELSE IF(@MaterialWarehouseCode <> 'ROH_HN_WH')
                BEGIN
                    RAISERROR(N'Các lot gộp phải cùng một kho', 16, 1);
                    ROLLBACK TRANSACTION;  -- Rollback giao dịch nếu có lỗi
                    BREAK;
                END
                ELSE 
                BEGIN
                    RAISERROR(N'Lot này đã gộp rồi', 16, 1);
                    ROLLBACK TRANSACTION;  -- Rollback giao dịch nếu có lỗi
                    BREAK;
                END
            END
            ELSE
            BEGIN
                -- Tính tổng CurrentQty cho cùng LotID
                SELECT 
                    @TotalInitialQty = SUM(InitialQty),
                    @TotalCurrentQty = SUM(CurrentQty)
                FROM STB_MaterialLotInfo 
                WHERE LotID = @LotID;
				--declare @test varchar(20)=@TotalCurrentQty
				--raiserror(@test,16,1)
				--return
                -- Kiểm tra xem bản ghi đã tồn tại trong STB_MaterialLotInfo_TEST chưa
                IF NOT EXISTS (
                    SELECT 1
                    FROM STB_MaterialLotInfo 
                    WHERE LotID = @NewLotID
                )
                BEGIN
                    -- Nếu chưa tồn tại, thực hiện INSERT
                    EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_MaterialLotInfo', @MaterialLotNo OUTPUT;
                    INSERT INTO STB_MaterialLotInfo 
                    (
                        MaterialLotNo,
                        LotID,
                        CompanyCode,
                        WorkCenterCode,
                        MaterialWarehouseCode,
                        MaterialLocationCode,
                        MaterialCode,
                        MaterialStockAttribute,
                        StockAttrib1,
                        StockAttrib2,
                        StockAttrib3,
                        PackingID,
                        GRDate,
                        MaterialDeliveryNo,
                        MaterialDeliveryDetailNo,
                        InitialQty,
                        CurrentQty,
                        PickingQty,
                        VendorLotNo,
                        LifeBasicDate,
                        ProductionDate,
                        EndOfLifeDate,
                        LotNo,
                        IsSplitLot,
                        BefMaterialLotNo,
                        LotAttr01,
                        LotAttr02,
                        LotAttr03,
                        LotAttr04,
                        LotAttr05,
                        LotAttr06,
                        LotAttr07,
                        LotAttr08,
                        LotAttr09,
                        LotAttr10,
                        CreateDateTime,
                        CreateUserID,
                        DateConfirmEx,
                        HoldError,
                        Holddate,
                        HoldPeriod,
                        PackingIdParent
                    )
                    SELECT
                        @MaterialLotNo,  -- Sử dụng mã chung SM
                        @NewLotID,
                        CompanyCode,
                        WorkCenterCode,
                        MaterialWarehouseCode,
                        MaterialLocationCode,
                        MaterialCode,
                        MaterialStockAttribute,
                        StockAttrib1,
                        StockAttrib2,
                        StockAttrib3,
                        PackingID,
                        GRDate,
                        MaterialDeliveryNo,
                        MaterialDeliveryDetailNo,
                        --@TotalInitialQty,
                        0,
                        @TotalCurrentQty,  -- Cập nhật CurrentQty bằng tổng
                        PickingQty,
                        VendorLotNo,
                        LifeBasicDate,
                        ProductionDate,
                        EndOfLifeDate,
                        LotNo,
                        IsSplitLot,
                        BefMaterialLotNo,
                        LotAttr01,
                        LotAttr02,
                        LotAttr03,
                        LotAttr04,
                        LotAttr05,
                        LotAttr06,
                        LotAttr07,
                        LotAttr08,
                        LotAttr09,
                        LotAttr10,
                        GETDATE() AS CreateDateTime,  -- Đặt giá trị CreateDateTime là thời gian hiện tại
                        @ProcessUserID AS CreateUserID,  -- Gán UserID vào CreateUserID
                        DateConfirmEx,
                        HoldError,
                        Holddate,
                        HoldPeriod,
                        --PackingIdParent
						null
                    FROM
                        STB_MaterialLotInfo  
                    WHERE
                        LotID = @LotID;

                    -- Cập nhật MergeParentId
                    UPDATE STB_MaterialLotInfo 
                    SET MergeParentId = @NewLotID,
					CurrentQtyBefMerge =CurrentQty,
					CurrentQty=0
                    WHERE LotID = @LotID;
                END
                ELSE
                BEGIN

				-- kiểm tra các mã có cùng mã nguyên vật liệu hay không
				DECLARE @MaterialCode1 VARCHAR(20);
				DECLARE @MaterialCode2 VARCHAR(20);

				-- Lấy giá trị MaterialCode từ bảng STB_MaterialLotInfo cho LotID hiện tại
				SELECT @MaterialCode1 = MaterialCode 
				FROM STB_MaterialLotInfo 
				WHERE LotID = @LotID;

				-- Lấy giá trị MaterialCode từ bảng STB_MaterialLotInfo cho NewLotID
				SELECT @MaterialCode2 = MaterialCode 
				FROM STB_MaterialLotInfo 
				WHERE LotID = @NewLotID;

				-- So sánh MaterialCode1 và MaterialCode2 mà không phân biệt hoa thường
				IF @MaterialCode1 = @MaterialCode2 COLLATE SQL_Latin1_General_CP1_CI_AS
				BEGIN
					                    -- Nếu dữ liệu đã tồn tại, thực hiện UPDATE
                    SELECT @CurrentQty = CurrentQty 
                    FROM STB_MaterialLotInfo 
                    WHERE LotID = @LotID;

                    -- Cập nhật lại CurrentQty trong STB_MaterialLotInfo
                    UPDATE STB_MaterialLotInfo 
                    SET
                        --InitialQty = InitialQty + @TotalInitialQty,
                        InitialQty = 0,
                        CurrentQty = CurrentQty + @TotalCurrentQty  -- Cập nhật CurrentQty mới
                    WHERE
                        LotID = @NewLotID;

                    -- Cập nhật MergeParentId
                    UPDATE STB_MaterialLotInfo 
                    SET MergeParentId = @NewLotID ,
						 --InitialQtyBefMerge=InitialQty,
						CurrentQtyBefMerge =CurrentQty,
						 --InitialQty=0,
						CurrentQty=0
                    WHERE LotID = @LotID;
				END
				ELSE
				BEGIN
							RAISERROR(N'Các lot gộp phải chung một loại nguyên vật liệu', 16, 1);
							ROLLBACK TRANSACTION;  -- Rollback giao dịch nếu có lỗi
							BREAK;
					END


                END
            END

            -- Tiếp tục với bản ghi tiếp theo
            FETCH NEXT FROM SourceData INTO @LotID, @PackingIdParent, @MaterialWarehouseCode;
        END

        -- Đóng và giải phóng cursor
        CLOSE SourceData;
        DEALLOCATE SourceData;

        -- Commit giao dịch nếu không có lỗi
        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        -- Xử lý lỗi nếu có
        SET @ERROR_MSG = ERROR_MESSAGE();
        RAISERROR(@ERROR_MSG, 16, 1);

        -- Rollback giao dịch nếu có lỗi
        ROLLBACK TRANSACTION;
    END CATCH;

    -- Xóa tài nguyên XML
    EXEC sp_xml_removedocument @iDoc;
END
