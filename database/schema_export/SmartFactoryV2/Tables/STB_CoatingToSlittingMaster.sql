CREATE TABLE [dbo].[STB_CoatingToSlittingMaster] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CoatingMaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [SlittingWidth] NUMERIC(5,1) NOT NULL DEFAULT ,
    [SlittingMaterialCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

