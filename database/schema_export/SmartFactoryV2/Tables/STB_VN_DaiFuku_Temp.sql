CREATE TABLE [dbo].[STB_VN_DaiFuku_Temp] (
    [WorkDate_Receipt] DATE NULL DEFAULT ,
    [Item_CD_Receipt] NVARCHAR(50) NULL DEFAULT ,
    [Item_Nm_Receipt] NVARCHAR(50) NULL DEFAULT ,
    [PackingID_Receipt] NVARCHAR(50) NULL DEFAULT ,
    [EnterQty_Receipt] INT NULL DEFAULT ,
    [EnterStatus_Receipt] BIT NULL DEFAULT ,
    [WorkDate_Delivery] DATE NULL DEFAULT ,
    [Item_Cd_Delivery] NVARCHAR(50) NULL DEFAULT ,
    [Item_Nm_Delivery] NVARCHAR(50) NULL DEFAULT ,
    [PackingID_Delivery] NVARCHAR(50) NULL DEFAULT ,
    [ShipQty_Delivery] INT NULL DEFAULT ,
    [ShipStatus_Delivery] BIT NULL DEFAULT 
);
GO

