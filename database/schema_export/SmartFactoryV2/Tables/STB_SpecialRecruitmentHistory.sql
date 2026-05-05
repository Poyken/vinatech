CREATE TABLE [dbo].[STB_SpecialRecruitmentHistory] (
    [Barcode] VARCHAR(20) NOT NULL DEFAULT ,
    [SpecialRecruitmentRemark] NVARCHAR(MAX) NULL DEFAULT ,
    [IsDelete] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

