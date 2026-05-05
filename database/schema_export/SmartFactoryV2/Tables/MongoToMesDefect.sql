CREATE TABLE [dbo].[MongoToMesDefect] (
    [DayPlanNo] VARCHAR(20) NOT NULL DEFAULT ,
    [Barcode] VARCHAR(50) NOT NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [DefectCode] VARCHAR(20) NOT NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [DefectQty] INT NULL DEFAULT ((0)),
    [CreateUserId] VARCHAR(20) NULL DEFAULT ,
    [IsDone] BIT NULL DEFAULT ((0)),
    [IsTransferred] BIT NULL DEFAULT ((0)),
    [ModifyDateTime] DATETIME NULL DEFAULT (getdate()),
    [InsertDateTime] DATETIME NULL DEFAULT (getdate()),
    CONSTRAINT [PK_MongoToMesDefect] PRIMARY KEY CLUSTERED ([DayPlanNo], [Barcode], [RouteCode], [DefectCode])
);
GO

