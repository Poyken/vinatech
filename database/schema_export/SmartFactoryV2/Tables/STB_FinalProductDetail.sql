CREATE TABLE [dbo].[STB_FinalProductDetail] (
    [DocNo] VARCHAR(50) NULL DEFAULT ,
    [FinalProductDocNo] VARCHAR(50) NULL DEFAULT ,
    [ProductCode] VARCHAR(20) NULL DEFAULT ,
    [Quantity] INT NULL DEFAULT ,
    [Quantity1] INT NULL DEFAULT ,
    [Quantity2] INT NULL DEFAULT ,
    [InvoiceNo] VARCHAR(50) NULL DEFAULT ,
    [Unit] VARCHAR(10) NULL DEFAULT ,
    [Description] VARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Attribute1] VARCHAR(50) NULL DEFAULT ,
    [Attribute2] VARCHAR(50) NULL DEFAULT ,
    [Attribute3] VARCHAR(50) NULL DEFAULT ,
    [Attribute4] VARCHAR(50) NULL DEFAULT ,
    [Attribute5] VARCHAR(50) NULL DEFAULT ,
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT 
);
GO

