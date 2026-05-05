CREATE TABLE [dbo].[MongoToMesPerformance] (
    [DayPlanNo] VARCHAR(20) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(50) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(200) NULL DEFAULT ,
    [TotalProdQty] INT NULL DEFAULT ((0)),
    [TotalDefectQty] INT NULL DEFAULT ((0)),
    [CreateUserId] VARCHAR(20) NULL DEFAULT ,
    [IsDone] BIT NULL DEFAULT ((0)),
    [IsTransferred] BIT NULL DEFAULT ((0)),
    [ModifyDateTime] DATETIME NULL DEFAULT (getdate()),
    [InsertDateTime] DATETIME NULL DEFAULT (getdate()),
    [IsSkipped] INT NOT NULL DEFAULT ((0)),
    CONSTRAINT [PK_MongoToMesPerformance] PRIMARY KEY CLUSTERED ([DayPlanNo], [Barcode], [RouteCode])
);
GO

