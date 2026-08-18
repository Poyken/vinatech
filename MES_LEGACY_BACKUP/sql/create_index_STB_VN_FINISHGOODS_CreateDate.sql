-- ==============================================================================
-- INDEX CREATION SCRIPT FOR FAST FG01 QUERYING
-- OBJECT: STB_VN_FINISHGOODS
-- COLUMN: CreateDate
-- PURPOSE: Fix full table scan on FG01 screen (usp_VN_ShowAllFinishGoodMES)
-- ==============================================================================
USE [SmartFactoryV2];
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_STB_VN_FINISHGOODS_CreateDate' AND object_id = OBJECT_ID('dbo.STB_VN_FINISHGOODS'))
BEGIN
    PRINT 'Creating index IX_STB_VN_FINISHGOODS_CreateDate...';
    CREATE NONCLUSTERED INDEX IX_STB_VN_FINISHGOODS_CreateDate
    ON [dbo].[STB_VN_FINISHGOODS] ([CreateDate])
    INCLUDE ([Flag], [LotNo], [PartNo], [MaterialName]);
    PRINT 'Index created successfully.';
END
ELSE
BEGIN
    PRINT 'Index IX_STB_VN_FINISHGOODS_CreateDate already exists.';
END
GO
