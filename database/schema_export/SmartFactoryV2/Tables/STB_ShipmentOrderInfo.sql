CREATE TABLE [dbo].[STB_ShipmentOrderInfo] (
    [ShipmentOrderNo] VARCHAR(20) NOT NULL DEFAULT ,
    [PackingID] VARCHAR(20) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT ,
    [PickingQty] BIGINT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_ShipmentOrderInfo] PRIMARY KEY CLUSTERED ([ShipmentOrderNo], [PackingID])
);
GO

