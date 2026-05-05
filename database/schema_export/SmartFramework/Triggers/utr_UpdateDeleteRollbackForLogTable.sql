-- Trigger: utr_UpdateDeleteRollbackForLogTable

CREATE TRIGGER utr_UpdateDeleteRollbackForLogTable
ON ScreenLayoutInfoLog
AFTER UPDATE, DELETE
AS
BEGIN
    -- 메시지 출력
    RAISERROR ('This table is for INSERTs only. UPDATEs and DELETEs are not allowed.', 16, 1)
    -- 작업 롤백 (실행 취소)
    ROLLBACK TRANSACTION;
END;

GO

