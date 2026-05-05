CREATE TABLE [dbo].[STB_CreateTemFakeForHaNam] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [PackingID] VARCHAR(50) NULL DEFAULT ,
    [PackingOutPutFinishGoodsID] VARCHAR(50) NULL DEFAULT ,
    [LotNo] VARCHAR(50) NULL DEFAULT ,
    [MarkingLetter] VARCHAR(50) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [LotQty] INT NULL DEFAULT ,
    [CreateDateTime] DATE NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT 
);
GO

