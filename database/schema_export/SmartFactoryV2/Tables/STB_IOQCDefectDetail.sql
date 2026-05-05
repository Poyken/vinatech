CREATE TABLE [dbo].[STB_IOQCDefectDetail] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialQcNo] VARCHAR(20) NULL DEFAULT ,
    [InspectionDocType] VARCHAR(10) NULL DEFAULT ,
    [MaterialQcDetailNo] INT NULL DEFAULT ,
    [QcInspectionItemCode] VARCHAR(20) NULL DEFAULT ,
    [DefectCode] VARCHAR(20) NULL DEFAULT ,
    [DefectQty] INT NULL DEFAULT ,
    [DefectDesc] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

