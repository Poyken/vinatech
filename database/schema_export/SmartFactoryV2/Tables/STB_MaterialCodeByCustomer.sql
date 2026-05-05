CREATE TABLE [dbo].[STB_MaterialCodeByCustomer] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [CustomerCode] VARCHAR(20) NULL DEFAULT ,
    [MaterialCodeCustomer] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [ShortMaterialCode] VARCHAR(50) NULL DEFAULT 
);
GO

