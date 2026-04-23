CREATE PROCEDURE [dbo].[usp_Vietnam_CancelProcessMaterialPacking_VVT]
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
    DECLARE @TotalInitialQty NUMERIC(18, 2) = 0;  -- Biến lưu tổng số lượng
    DECLARE @TotalCurrentQty NUMERIC(18, 2) = 0;  -- Biến lưu tổng số lượng
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
			-- DinhManh update 2025-03-13
			IF(@MaterialWarehouseCode <> 'ROH_HN_WH')
				BEGIN
					RAISERROR(N'Các lot này đã xuất ra sản xuất', 16, 1);
					ROLLBACK TRANSACTION;  -- Rollback giao dịch nếu các lot đã xuất ra sản xuất
					BREAK;
				END
			--
            ELSE 
				BEGIN
		
					DECLARE @MergeParentId VARCHAR(50) = NULL;

					SELECT @MergeParentId = MergeParentId FROM STB_MaterialLotInfo WHERE LotID = @LotID;
								--- Xóa lot được tạo
					delete from STB_MaterialLotInfo where lotID =  @MergeParentId
						-- update lại trạng thái của các lot đã gộp
					 CREATE TABLE #TempTable (
							LotID VARCHAR(50),

						);
					INSERT INTO #TempTable (LotID)
						SELECT LotID
						FROM STB_MaterialLotInfo 
						WHERE MergeParentId = @MergeParentId;
					   --RAISERROR(@LotID, 16, 1);
				
					update STB_MaterialLotInfo 
								set  MergeParentId = null,
								 --InitialQty=InitialQtyBefMerge,
								CurrentQty=CurrentQtyBefMerge    
								WHERE LotID in ( select LotID from #TempTable  ) 
             
					  DROP TABLE #TempTable;
					  -- lưu lại lịch sử ai là người hủy gộp box
					   INSERT INTO STB_HisttoryCancelBoxRawMaterial
									(
										Lotid,
										CreateUserID,
										CreateDatetime
									)
									VALUES
									(
										@LotID,
										@ProcessUserID,
										GETDATE()
									)
					-- Tiếp tục với bản ghi tiếp theo
					FETCH NEXT FROM SourceData INTO @LotID, @PackingIdParent, @MaterialWarehouseCode;

				END

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
