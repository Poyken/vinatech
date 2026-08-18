-- ==============================================================================
-- TEMPLATE: Cancel F330 Confirmed Goods Receipt (Xóa theo thứ tự ngược)
-- ==============================================================================

DECLARE @DocNo NVARCHAR(50) = 'DOC_SAMPLE';

BEGIN TRANSACTION;
BEGIN TRY
    DELETE FROM STB_MaterialLotInfo WHERE LotID IN (SELECT LotID FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = @DocNo);
    DELETE FROM STB_MaterialDocLotInfo WHERE MaterialDocNo = @DocNo;
    DELETE FROM STB_MaterialDocDetail WHERE MaterialDocNo = @DocNo;
    DELETE FROM STB_MaterialDocInfo WHERE MaterialDocNo = @DocNo;

    -- ROLLBACK TRANSACTION; -- Mặc định an toàn
    COMMIT TRANSACTION;
    PRINT 'SUCCESS: Cancel F330 thanh cong!';
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
    PRINT 'ERROR: ' + ERROR_MESSAGE();
END CATCH;
