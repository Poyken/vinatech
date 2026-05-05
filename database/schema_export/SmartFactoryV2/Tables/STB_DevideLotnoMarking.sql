CREATE TABLE [dbo].[STB_DevideLotnoMarking] (
    [DividePackagingID] VARCHAR(50) NOT NULL DEFAULT ,
    [LotNo] VARCHAR(50) NULL DEFAULT ,
    [Qty] INT NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [ParentLotNo] VARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(50) NULL DEFAULT 
);
GO

