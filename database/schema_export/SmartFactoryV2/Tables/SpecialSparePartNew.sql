CREATE TABLE [dbo].[SpecialSparePartNew] (
    [PartID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MachineID] VARCHAR(10) NULL DEFAULT ,
    [SparePartName] NVARCHAR(100) NULL DEFAULT ,
    [QtyUsing] INT NULL DEFAULT ,
    [QtyPerLot] INT NULL DEFAULT ,
    [CycleReplace] INT NULL DEFAULT ,
    [NumberLot] INT NULL DEFAULT 
);
GO

