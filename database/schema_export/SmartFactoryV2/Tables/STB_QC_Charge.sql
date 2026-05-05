CREATE TABLE [dbo].[STB_QC_Charge] (
    [Pattern_Name] VARCHAR(50) NOT NULL DEFAULT ,
    [Capacity] NUMERIC(10,2) NULL DEFAULT ,
    [Volume] NUMERIC(10,2) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT (getdate())
);
GO

