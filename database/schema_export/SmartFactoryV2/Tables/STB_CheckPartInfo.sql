CREATE TABLE [dbo].[STB_CheckPartInfo] (
    [CheckPartNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CheckPartName] VARCHAR(100) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ((1)),
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [DisplayIndex] INT NULL DEFAULT ,
    [Remark] NVARCHAR(100) NULL DEFAULT 
);
GO

