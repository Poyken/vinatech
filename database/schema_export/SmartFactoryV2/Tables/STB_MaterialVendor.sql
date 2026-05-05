CREATE TABLE [dbo].[STB_MaterialVendor] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [Revision] VARCHAR(20) NOT NULL DEFAULT ,
    [SupplierSeq] INT NOT NULL DEFAULT ,
    [SupplierType] VARCHAR(50) NULL DEFAULT ,
    [MfrName] NVARCHAR(200) NULL DEFAULT ,
    [MfrPartNumber] VARCHAR(100) NULL DEFAULT ,
    [MfrPartLifecycle] VARCHAR(50) NULL DEFAULT ,
    [MfrPartDesc] NVARCHAR(500) NULL DEFAULT ,
    [SupplierName] NVARCHAR(200) NULL DEFAULT ,
    [SupplierPartNumber] VARCHAR(100) NULL DEFAULT ,
    [SupplierSite] NVARCHAR(200) NULL DEFAULT ,
    [PreferredStatus] VARCHAR(50) NULL DEFAULT ,
    [AslEnabled] VARCHAR(10) NULL DEFAULT ,
    [AslOrgList] NVARCHAR(200) NULL DEFAULT ,
    [SupplierComments] NVARCHAR(MAX) NULL DEFAULT ,
    [RefNotes] NVARCHAR(MAX) NULL DEFAULT ,
    [DocumentSaveCode] VARCHAR(50) NULL DEFAULT ,
    [IsActive] BIT NOT NULL DEFAULT ((1)),
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_MaterialVendor] PRIMARY KEY CLUSTERED ([MaterialCode], [Revision], [SupplierSeq])
);
GO

