CREATE TABLE [dbo].[STB_SparePartLocationInfo] (
    [SPWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SPLocationCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SPLocationGroup] NVARCHAR(50) NULL DEFAULT ,
    [SPLocationName] NVARCHAR(100) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_SparePartLocationInfo] PRIMARY KEY CLUSTERED ([SPWarehouseCode], [SPLocationCode])
);
GO

