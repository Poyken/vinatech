CREATE TABLE [dbo].[STB_SparePartIOTypeCode] (
    [SparePartIOTypeCode] VARCHAR(20) NOT NULL DEFAULT ,
    [IOType] VARCHAR(1) NULL DEFAULT ,
    [SparePartIOTypeName] NVARCHAR(100) NULL DEFAULT ,
    [SparePartIOTypeDesc] NVARCHAR(100) NULL DEFAULT ,
    [IsDefaultRepairGI] BIT NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

