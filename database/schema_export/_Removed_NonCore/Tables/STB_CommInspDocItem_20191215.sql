CREATE TABLE [dbo].[STB_CommInspDocItem_20191215] (
    [CommInspDocItemNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CommInspDocNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CommInspItemCode] VARCHAR(20) NULL DEFAULT ,
    [CommInspUnit] VARCHAR(20) NULL DEFAULT ,
    [CommInspItemDesc] NVARCHAR(200) NULL DEFAULT ,
    [CommInspInputType] VARCHAR(1) NULL DEFAULT ,
    [CommInspItemSpec] VARCHAR(50) NULL DEFAULT ,
    [CommInspUpper] VARCHAR(50) NULL DEFAULT ,
    [CommInspLower] VARCHAR(50) NULL DEFAULT ,
    [ItemTargetQty] INT NULL DEFAULT ,
    [ItemQty] INT NULL DEFAULT ,
    [ImageFileID] BIGINT NULL DEFAULT ,
    [CommInspRemark] NVARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

