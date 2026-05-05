CREATE TABLE [dbo].[STB_ElectrolyteMoistureMeasureHist] (
    [MoistureMeasureHistNo] VARCHAR(20) NOT NULL DEFAULT ,
    [ProductSizeCode] VARCHAR(10) NULL DEFAULT ,
    [Temperature] NUMERIC(10,2) NULL DEFAULT ,
    [DewPoint] NUMERIC(10,2) NULL DEFAULT ,
    [ElectrolyteMoistureValue] NUMERIC(10,2) NULL DEFAULT ,
    [IsPass] BIT NULL DEFAULT ,
    [IsMaterial] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [MaterialCode] VARCHAR(20) NULL DEFAULT 
);
GO

