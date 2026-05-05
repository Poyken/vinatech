CREATE TABLE [dbo].[STB_BomHeader] (
    [MaterialCode] VARCHAR(50) NOT NULL DEFAULT ,
    [BomVersion] VARCHAR(20) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [IsBasic] BIT NULL DEFAULT ,
    [BomHeaderDesc] NVARCHAR(200) NULL DEFAULT ,
    [BasicRoutingCode] VARCHAR(20) NULL DEFAULT ,
    [BomUnit] VARCHAR(10) NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_BomHeader] PRIMARY KEY CLUSTERED ([MaterialCode], [BomVersion])
);
GO

