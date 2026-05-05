CREATE TABLE [dbo].[STB_CommInspSelectItem] (
    [CommInspSelectItemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CommInspSelectGroupCode] VARCHAR(20) NULL DEFAULT ,
    [CommInspSelectItemValue] VARCHAR(50) NULL DEFAULT ,
    [CommInspSelectITemDesc] NVARCHAR(100) NULL DEFAULT ,
    [CommInspSelectResult] VARCHAR(4) NULL DEFAULT ,
    [DisplayIndex] INT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

