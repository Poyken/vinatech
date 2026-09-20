-- ==============================================================================
-- RESTORE SCRIPT: RESTORE_B725_BACKUP_RECORDS
-- Target Database: SmartFactoryV2
-- ==============================================================================
USE SmartFactoryV2;
GO

BEGIN TRANSACTION;

INSERT INTO STB_VN_ITEM_CHECK (
    DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, REMARK, CODENAME, INPUT, QTY, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
)
SELECT 
    DEPARTMENT, CODELINE, NAMELINE, CATEGORIESCHECK, TYPES, REMARK, CODENAME, INPUT, QTY, CreateDateTime, CreateUserID, ChangeDateTime, ChangeUserID
FROM BAK_STB_VN_ITEM_CHECK_20260902_B725 WITH(NOLOCK);

COMMIT TRANSACTION;
GO
