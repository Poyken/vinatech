CREATE TABLE [dbo].[STB_VN_SpecialSparePartInfo] (
    [SparePartCode] VARCHAR(30) NOT NULL DEFAULT ,
    [SparePartName] NVARCHAR(100) NULL DEFAULT ,
    [SparePartSpec01] NVARCHAR(100) NULL DEFAULT ,
    [UsingQty] INT NULL DEFAULT ,
    [Model] VARCHAR(10) NULL DEFAULT ,
    [MachineName] VARCHAR(30) NULL DEFAULT ,
    [LotQty] INT NULL DEFAULT ,
    [CycleReplace] BIGINT NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CompanyCode] VARCHAR(10) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(10) NULL DEFAULT ,
    [SPNote] NVARCHAR(200) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(30) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(30) NULL DEFAULT 
);
GO

