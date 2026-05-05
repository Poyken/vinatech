CREATE TABLE [dbo].[STB_CommInspSelectGroup] (
    [CommInspSelectGroupCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CommInspSelectGroupName] NVARCHAR(100) NULL DEFAULT ,
    [CommInspSelectGroupDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

