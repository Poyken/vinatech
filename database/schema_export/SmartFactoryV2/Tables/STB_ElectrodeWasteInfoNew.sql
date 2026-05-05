CREATE TABLE [dbo].[STB_ElectrodeWasteInfoNew] (
    [ElectrodeWasteNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [JobDate] DATE NULL DEFAULT ,
    [CalendarCode] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [ElectrodeClassCode] VARCHAR(20) NULL DEFAULT ,
    [CurrentCollectorClassCode] VARCHAR(20) NULL DEFAULT ,
    [ElectrodeThickness] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [DefectCode] VARCHAR(20) NULL DEFAULT ,
    [DefectWeight] NUMERIC(20,3) NULL DEFAULT ,
    [Remark] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NOT NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NOT NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Barcode] VARCHAR(20) NULL DEFAULT 
);
GO

