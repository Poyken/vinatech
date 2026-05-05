CREATE TABLE [dbo].[STB_ProdSerialMappingInfo] (
    [ProdSerialNo] VARCHAR(20) NOT NULL DEFAULT ,
    [LotNo] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT 
);
GO

