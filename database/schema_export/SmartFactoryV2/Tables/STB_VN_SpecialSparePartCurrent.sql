CREATE TABLE [dbo].[STB_VN_SpecialSparePartCurrent] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [SparePartLotID] VARCHAR(50) NULL DEFAULT ,
    [SparePartCode] VARCHAR(30) NULL DEFAULT ,
    [LineCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [Status] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [UpdateDateTime] DATETIME NULL DEFAULT ,
    [UpdateUserID] VARCHAR(20) NULL DEFAULT 
);
GO

