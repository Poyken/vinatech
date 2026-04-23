
CREATE PROCEDURE [dbo].[usp_VN_SparePart_UpdateStock_AfterReplacement]
    @pOldSparePartCode VARCHAR(50),
    @pOldWarehouseName NVARCHAR(50),
    @pOldQty DECIMAL(18,2), -- Chuyển sang Decimal
    @pNewSparePartCode VARCHAR(50),
    @pNewWarehouseName NVARCHAR(50),
    @pNewQty DECIMAL(18,2), -- Chuyển sang Decimal
    @pWorkCenterCode VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    -- Mapping tên kho (Loại bỏ khoảng trắng để so sánh chính xác)
    DECLARE @vOldWH VARCHAR(20) = CASE 
        WHEN REPLACE(@pOldWarehouseName, ' ', '') = N'Kho1' THEN 'Kho1' 
        WHEN REPLACE(@pOldWarehouseName, ' ', '') = N'Kho2' THEN 'Kho2' ELSE NULL END;

    DECLARE @vNewWH VARCHAR(20) = CASE 
        WHEN REPLACE(@pNewWarehouseName, ' ', '') = N'Kho1' THEN 'Kho1' 
        WHEN REPLACE(@pNewWarehouseName, ' ', '') = N'Kho2' THEN 'Kho2' ELSE NULL END;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- 1. HOÀN TRẢ SỐ LƯỢNG CŨ
        IF @pOldQty > 0 AND @vOldWH IS NOT NULL
        BEGIN
            UPDATE STB_VNSparePartStockInfo_TEST
            SET CurrentStockQty = CurrentStockQty + @pOldQty
            WHERE SparePartCode = @pOldSparePartCode 
              AND WorkCenterCode = @pWorkCenterCode 
              AND spwarehousecode = @vOldWH;
        END

        -- 2. TRỪ SỐ LƯỢNG MỚI
        IF @pNewQty > 0 AND @vNewWH IS NOT NULL
        BEGIN
            -- Thực hiện trừ và kiểm tra tồn kho trong cùng 1 lệnh UPDATE
            UPDATE STB_VNSparePartStockInfo_TEST
            SET CurrentStockQty = CurrentStockQty - @pNewQty
            WHERE SparePartCode = @pNewSparePartCode 
              AND WorkCenterCode = @pWorkCenterCode 
              AND spwarehousecode = @vNewWH
              AND CurrentStockQty >= @pNewQty;

            -- Nếu không có dòng nào được cập nhật, bắn lỗi về C#
            IF @@ROWCOUNT = 0
            BEGIN
                DECLARE @Msg NVARCHAR(255) = N'Lỗi: Không đủ tồn kho hoặc sai mã vật tư ' + @pNewSparePartCode + N' tại ' + @vNewWH;
                RAISERROR(@Msg, 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@Err, 16, 1);
    END CATCH
END
