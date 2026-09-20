-- ==============================================================================
-- TEMPLATE: CHUAN HOA SINH MA PACKINGID 11 KY TU CHO BOX DONG GOI POP
-- Thay the: {{LOT_NO}}, {{BOX_QTY}}, {{EMP_NO}}
-- Muc dich: Tao ma PackingID chuan 11 ky tu (PK + YYMM + DD + 5 so Serial)
--          de in tem thung Box Label khong bi co ngat ma vach tren Kiosk POP
-- Tham chieu: POP_KB_02 § 10, POP_KB_03 § POP-ERR-16, POP_KB_06 § 2.1, KB_04_01 § 6.0.1c
-- ==============================================================================

USE SmartFactoryV2;
GO

DECLARE @LotNo VARCHAR(50) = '{{LOT_NO}}';         -- Ma Lot cha (vd: '20260919000123')
DECLARE @BoxQty INT = {{BOX_QTY}};                 -- So luong san pham trong thung
DECLARE @EmpNo VARCHAR(50) = '{{EMP_NO}}';         -- Ma nhan vien dong goi
DECLARE @IsDryRun BIT = 1;                         -- 1: Xem thu | 0: Ghi nhan that

BEGIN TRANSACTION;
BEGIN TRY
    -- 1. [CHECK] Kiem tra Lot ton tai va so luong kha dung
    IF NOT EXISTS (SELECT 1 FROM STB_SetInfo WITH(NOLOCK) WHERE Barcode = @LotNo)
    BEGIN
        RAISERROR(N'Khong tim thay Lot %s trong he thong STB_SetInfo!', 16, 1, @LotNo);
    END;

    -- 2. [GENERATE] Thuat toan sinh PackingID 11 ky tu chuan NAIS MES
    -- Dinh dang: PK + Ma Nam/Thang (2 ky tu) + Ngay (2 ky tu) + Serial 5 so
    -- Ma thang Vinatech quy uoc: 2026 nam 'Q', Thang 9 'R' -> 'QR'
    DECLARE @DatePrefix VARCHAR(6) = 'PK' + 'QR' + RIGHT('0' + CAST(DAY(GETDATE()) AS VARCHAR(2)), 2);
    
    DECLARE @MaxSerial INT = 0;
    SELECT @MaxSerial = ISNULL(MAX(CAST(RIGHT(PackingID, 5) AS INT)), 0)
    FROM STB_MaterialLotInfo WITH(NOLOCK)
    WHERE PackingID LIKE @DatePrefix + '%';

    DECLARE @NewSerial INT = @MaxSerial + 1;
    DECLARE @GeneratedPackingID VARCHAR(20) = @DatePrefix + RIGHT('00000' + CAST(@NewSerial AS VARCHAR(5)), 5);

    PRINT N'>> Ma PackingID duoc sinh: ' + @GeneratedPackingID + N' (Tong do dai: ' + CAST(LEN(@GeneratedPackingID) AS NVARCHAR(5)) + N' ky tu)';

    -- 3. [PREVIEW / EXECUTE]
    IF @IsDryRun = 0
    BEGIN
        -- Cap nhat vao STB_MaterialLotInfo
        UPDATE STB_MaterialLotInfo
        SET PackingID      = @GeneratedPackingID,
            ChangeDateTime = GETDATE(),
            ChangeUserID   = @EmpNo
        WHERE LotNo = @LotNo
          AND (PackingID IS NULL OR PackingID = '');

        -- Ghi nhan moc thoi gian dong goi
        IF NOT EXISTS (SELECT 1 FROM STB_SavePackingTime_VVT WHERE PackingID = @GeneratedPackingID)
        BEGIN
            INSERT INTO STB_SavePackingTime_VVT (PackingID, Barcode, PackingTime, RegDate)
            VALUES (@GeneratedPackingID, @LotNo, GETDATE(), GETDATE());
        END

        -- Khoi tao lich su in tem thung
        IF NOT EXISTS (SELECT 1 FROM STB_PackingLabelPrintHist WHERE PackingID = @GeneratedPackingID)
        BEGIN
            INSERT INTO STB_PackingLabelPrintHist (PackingID, PrintCount, IsPrintAllow, CreateDateTime, CreateUserID)
            VALUES (@GeneratedPackingID, 0, 1, GETDATE(), @EmpNo);
        END
        ELSE
        BEGIN
            UPDATE STB_PackingLabelPrintHist 
            SET IsPrintAllow = 1, PrintCount = 0, ChangeDateTime = GETDATE()
            WHERE PackingID = @GeneratedPackingID;
        END

        PRINT N'>> Da cap nhat PackingID thanh cong cho Lot ' + @LotNo;
        COMMIT TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT N'>> [DRY-RUN] Chuyen @IsDryRun = 0 de ap dung ma PackingID vao DB.';
        ROLLBACK TRANSACTION;
    END
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    DECLARE @Err NVARCHAR(4000) = ERROR_MESSAGE();
    PRINT N'>> LOI: ' + @Err;
    THROW;
END CATCH;
