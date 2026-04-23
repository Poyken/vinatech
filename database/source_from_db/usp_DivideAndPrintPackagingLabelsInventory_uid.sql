
-- =============================================
-- Author:       Nguyễn Hải Triều
-- Create date:  2025-10-06
-- Description:  Chia tem tồn thành nhiều phần theo số lượng nhập
-- =============================================
CREATE PROCEDURE [dbo].[usp_DivideAndPrintPackagingLabelsInventory_uid]
    @pProcessUserID       VARCHAR(20),
    @pProcessLanguage     VARCHAR(20),
    @pPackingID           NVARCHAR(50) = NULL,
    @pDividePackagingQty  NUMERIC(20,5) = NULL
AS
BEGIN
    SET NOCOUNT ON;

        DECLARE 
        @DividePackagingIDNew VARCHAR(50),
        @Qty NUMERIC(20,5),
        @MaterialCode VARCHAR(50),
        @GRDate VARCHAR(20),
        @LotNo VARCHAR(50),
        @PackingID VARCHAR(50),            -- PackingID gốc lấy từ bản ghi
        @ParentPackingID VARCHAR(50),
        @Index INT = 1,
        @RemainingQty NUMERIC(20,5);

    -- Lấy thông tin tem gốc
    SELECT
        @Qty = Qty,
        @MaterialCode = MaterialCode,
        @GRDate = GRDate,
        @LotNo = LotNo,
        @PackingID = PackingID,
        @ParentPackingID = ParentPackingID
    FROM STB_DividePackaging
    WHERE DividePackagingID = @pPackingID;

    -- Validate
    IF @Qty IS NULL
    BEGIN
        RAISERROR(N'Tem gốc không tồn tại.', 16, 1);
        RETURN;
    END

    IF @pDividePackagingQty IS NULL OR @pDividePackagingQty <= 0
    BEGIN
        RAISERROR(N'Số lượng chia không hợp lệ.', 16, 1);
        RETURN;
    END

    IF @pDividePackagingQty >= @Qty
    BEGIN
        RAISERROR(N'Số lượng chia phải nhỏ hơn tổng số lượng hiện có.', 16, 1);
        RETURN;
    END

    SET @RemainingQty = @Qty;

    -- Chuẩn bị BasePackingID: loại bỏ phần hậu tố cuối dạng _xx nếu có
    DECLARE @BasePackingID VARCHAR(100);
    IF CHARINDEX('_', @PackingID) > 0
    BEGIN
        DECLARE @lastUnderscorePos INT;
        SET @lastUnderscorePos = LEN(@PackingID) - CHARINDEX('_', REVERSE(@PackingID)) + 1;
        SET @BasePackingID = LEFT(@PackingID, @lastUnderscorePos - 1); -- bỏ phần sau dấu _
    END
    ELSE
        SET @BasePackingID = @PackingID;

   

    -- Lặp chia theo @pDividePackagingQty
    WHILE @RemainingQty > 0
    BEGIN
        DECLARE @CurrentQty NUMERIC(20,5);

        IF @RemainingQty >= @pDividePackagingQty
            SET @CurrentQty = @pDividePackagingQty;
        ELSE
            SET @CurrentQty = @RemainingQty;

        -- Tạo serial id cho bản ghi STB_DividePackaging
        EXEC SmartFramework.dbo.usp_DoCreateSerial 'STB_DividePackaging', @DividePackagingIDNew OUTPUT;

        -- Tạo PackingID con dạng: <BasePackingID>_001, _002, ...
        DECLARE @NewPackingID VARCHAR(100) = @BasePackingID + '_' + RIGHT('000' + CAST(@Index AS VARCHAR(3)), 3);

        INSERT INTO STB_DividePackaging
        (
            DividePackagingID, Qty, MaterialCode, GRDate, LotNo, PackingID,
            CreateDateTime, CreateUserID, ParentPackingID, TypeBox, PackingParentID
        )
        VALUES
        (
            @DividePackagingIDNew, @CurrentQty, @MaterialCode, @GRDate, @LotNo,
            @NewPackingID, GETDATE(), @pProcessUserID, @pPackingID, 1, @PackingID
        );

        SET @RemainingQty = @RemainingQty - @CurrentQty;
        SET @Index = @Index + 1;
    END

    -- Đánh dấu tem gốc đã được chia
    UPDATE STB_DividePackaging 
    SET IsSmailBox = '1'
    WHERE DividePackagingID = @pPackingID;

   
END
