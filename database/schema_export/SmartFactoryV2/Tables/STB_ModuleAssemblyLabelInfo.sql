CREATE TABLE [dbo].[STB_ModuleAssemblyLabelInfo] (
    [ModuleAssemblyLotNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ModuleParentLotNo] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [DefectCode] VARCHAR(20) NULL DEFAULT ,
    [IsPacking] BIT NOT NULL DEFAULT (CONVERT([bit],(0),0)),
    [PackingDateTime] DATETIME NULL DEFAULT ,
    [IsShipment] BIT NULL DEFAULT ,
    [ShipmentDateTime] DATETIME NULL DEFAULT 
);
GO

