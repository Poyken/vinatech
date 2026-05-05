CREATE TABLE [dbo].[STB_WidthSlitting] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [Width] NUMERIC(20,10) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CustomName] NVARCHAR(100) NULL DEFAULT ,
    [MaterialUnit] VARCHAR(10) NULL DEFAULT 
);
GO

