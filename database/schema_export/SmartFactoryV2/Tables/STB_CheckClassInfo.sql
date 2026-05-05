CREATE TABLE [dbo].[STB_CheckClassInfo] (
    [CheckClassNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CheckClassName] VARCHAR(100) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ((1)),
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Remark] NVARCHAR(100) NULL DEFAULT 
);
GO

