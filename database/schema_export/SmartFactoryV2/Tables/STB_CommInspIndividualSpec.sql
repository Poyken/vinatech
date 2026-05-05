CREATE TABLE [dbo].[STB_CommInspIndividualSpec] (
    [IndividualSpecNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CommInspItemCode] VARCHAR(50) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [MoldNumber] VARCHAR(50) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [CategoryName] NVARCHAR(50) NULL DEFAULT ,
    [CommInspItemSpec] VARCHAR(50) NULL DEFAULT ,
    [CommInspItemDesc] NVARCHAR(200) NULL DEFAULT ,
    [CommInspUpper] VARCHAR(50) NULL DEFAULT ,
    [CommInspLower] VARCHAR(50) NULL DEFAULT ,
    [ItemImageFileID] BIGINT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [FacilityRouteCode] VARCHAR(20) NULL DEFAULT ,
    [ProductGroupCode] VARCHAR(20) NULL DEFAULT ,
    [CommInspUpperManually] VARCHAR(50) NULL DEFAULT ,
    [CommInspLowerManually] VARCHAR(50) NULL DEFAULT ,
    [ItemTargetQtyIndividual] INT NULL DEFAULT 
);
GO

