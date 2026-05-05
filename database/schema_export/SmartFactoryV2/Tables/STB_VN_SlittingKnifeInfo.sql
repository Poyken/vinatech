CREATE TABLE [dbo].[STB_VN_SlittingKnifeInfo] (
    [SlittingKnifeCode] VARCHAR(30) NOT NULL DEFAULT ,
    [SlittingKnifeName] NVARCHAR(100) NULL DEFAULT ,
    [StandardQty] BIGINT NULL DEFAULT ,
    [Model] VARCHAR(50) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [SPNote] NVARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(30) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(30) NULL DEFAULT 
);
GO

