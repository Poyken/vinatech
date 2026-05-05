CREATE TABLE [dbo].[STB_PackingOutPutFinishGoods_HN] (
    [PackingOutPutFinishGoodsID] VARCHAR(50) NOT NULL DEFAULT ,
    [CurrentQty] INT NULL DEFAULT ,
    [Marking] NVARCHAR(MAX) NULL DEFAULT ,
    [CombineMaterialcodeAndQty] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATE NULL DEFAULT ,
    [ChangeUserID] VARCHAR(50) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [StatusExport] BIT NULL DEFAULT 
);
GO

