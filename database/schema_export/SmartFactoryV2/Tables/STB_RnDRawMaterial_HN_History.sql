CREATE TABLE [dbo].[STB_RnDRawMaterial_HN_History] (
    [LogId] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialCode] NVARCHAR(50) NULL DEFAULT ,
    [OldValue] FLOAT NULL DEFAULT ((0)),
    [ImportValue] FLOAT NULL DEFAULT ,
    [NewValue] FLOAT NULL DEFAULT ,
    [ActionType] NVARCHAR(20) NULL DEFAULT ,
    [CreatedBy] NVARCHAR(100) NULL DEFAULT ,
    [CreatedDate] DATETIME NULL DEFAULT (getdate()),
    [Remark] NVARCHAR(MAX) NULL DEFAULT 
);
GO

