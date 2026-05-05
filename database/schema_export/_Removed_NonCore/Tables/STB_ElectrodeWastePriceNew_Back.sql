CREATE TABLE [dbo].[STB_ElectrodeWastePriceNew_Back] (
    [RouteCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ElectrodeClassCode] VARCHAR(20) NOT NULL DEFAULT ,
    [ElectrodeThickness] INT NOT NULL DEFAULT ,
    [CurrentCollectorClassCode] VARCHAR(20) NOT NULL DEFAULT ,
    [DefectCode] VARCHAR(20) NOT NULL DEFAULT ,
    [DefectUnitPrice] NUMERIC(20,10) NOT NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NOT NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NOT NULL DEFAULT 
);
GO

