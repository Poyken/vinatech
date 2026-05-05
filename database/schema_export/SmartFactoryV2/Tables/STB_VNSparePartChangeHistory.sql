CREATE TABLE [dbo].[STB_VNSparePartChangeHistory] (
    [SparePartChangeHistoryNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [SparePartCode] VARCHAR(20) NULL DEFAULT ,
    [ChangeQty] NUMERIC(20,5) NULL DEFAULT ,
    [BasicUnitPrice] NUMERIC(20,5) NULL DEFAULT ,
    [SpareChangeDate] DATE NULL DEFAULT ,
    [SpareChangeDateTime] DATETIME NULL DEFAULT ,
    [IsMachineRepair] VARCHAR(1) NULL DEFAULT ,
    [SparePartIOHistoryNo] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

