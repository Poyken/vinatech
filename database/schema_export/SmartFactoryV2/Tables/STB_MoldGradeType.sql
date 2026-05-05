CREATE TABLE [dbo].[STB_MoldGradeType] (
    [MoldGradeTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [MoldGradeTypeName] NVARCHAR(50) NULL DEFAULT ,
    [Level1Qty] INT NULL DEFAULT ,
    [Level2Qty] INT NULL DEFAULT ,
    [Level3Qty] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

