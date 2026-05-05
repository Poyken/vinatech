CREATE TABLE [dbo].[STB_IQCSampleQtyStandard] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [LowerQcQty] INT NULL DEFAULT ,
    [UpperQcQty] INT NULL DEFAULT ,
    [InspectionLevelS1] VARCHAR(5) NULL DEFAULT ,
    [SampleQty] INT NULL DEFAULT 
);
GO

