CREATE TABLE [dbo].[STB_PackingStandard] (
    [MaterialTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [Size] VARCHAR(10) NOT NULL DEFAULT ,
    [Voltage] NUMERIC(20,5) NULL DEFAULT ,
    [Farad] NUMERIC(20,5) NULL DEFAULT ,
    [VinylBagQty] INT NULL DEFAULT ,
    [InnerBoxQty] INT NULL DEFAULT ,
    [OutBoxQty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_PackingStandard] PRIMARY KEY CLUSTERED ([MaterialTypeCode], [Size])
);
GO

