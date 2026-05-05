CREATE TABLE [dbo].[STB_KlemoveLabelInfo] (
    [KlemoveLabelNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CustomerPartNo] VARCHAR(20) NULL DEFAULT ('H00.047-53'),
    [SupplierPartNo] VARCHAR(20) NULL DEFAULT ('VEC3R0107QG-C'),
    [ManufacturingLocation] VARCHAR(20) NULL DEFAULT ('VIETNAM'),
    [ManufacturingDate] CHAR(8) NULL DEFAULT (CONVERT([char](8),getdate(),(112))),
    [ExpiryDate] CHAR(8) NULL DEFAULT (CONVERT([char](8),dateadd(year,(2),getdate()),(112))),
    [PackageID] VARCHAR(20) NOT NULL DEFAULT ,
    [Quantity] BIGINT NULL DEFAULT ((5400)),
    [BatchNo] VARCHAR(20) NULL DEFAULT ,
    [MATLabel] VARCHAR(273) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

