CREATE TABLE [dbo].[STB_SystemWarehouseMappingInfo] (
    [SystemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [FromWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ToWarehouseCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CompanyCode] VARCHAR(20) NULL DEFAULT 
);
GO

