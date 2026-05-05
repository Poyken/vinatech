CREATE TABLE [dbo].[STB_WorkerAssingStatus] (
    [WorkerAssignNo] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [RouteCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [WorkerCode] VARCHAR(20) NULL DEFAULT ,
    [AssignDateTime] DATETIME NULL DEFAULT 
);
GO

