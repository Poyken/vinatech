CREATE TABLE [dbo].[STB_SerialRule] (
    [TableName] VARCHAR(50) NOT NULL DEFAULT ,
    [TableDescription] NVARCHAR(100) NULL DEFAULT ,
    [IsAutoKey] BIT NULL DEFAULT ,
    [IsLoopIUD] BIT NULL DEFAULT ,
    [PrefixData] VARCHAR(12) NULL DEFAULT ,
    [SerialLen] INT NULL DEFAULT ,
    [LastPrefixData] VARCHAR(20) NULL DEFAULT ,
    [LastSerialNo] INT NULL DEFAULT 
);
GO

