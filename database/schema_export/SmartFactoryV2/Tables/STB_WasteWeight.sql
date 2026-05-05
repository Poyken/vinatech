CREATE TABLE [dbo].[STB_WasteWeight] (
    [Idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [IpAddress] VARCHAR(20) NULL DEFAULT ,
    [WasteWeight] NUMERIC(10,2) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

