CREATE TABLE [dbo].[STB_QCDefectDetailsRecord] (
    [Barcode] VARCHAR(30) NOT NULL DEFAULT ,
    [ControlNo] VARCHAR(30) NULL DEFAULT ,
    [InspectionDate] DATE NULL DEFAULT ,
    [InspectionQty] INT NULL DEFAULT ,
    [DefectQty] INT NULL DEFAULT ,
    [DefectDivisionCode] VARCHAR(20) NULL DEFAULT ,
    [DefectCode] VARCHAR(20) NULL DEFAULT ,
    [InspWorkerCode] VARCHAR(10) NULL DEFAULT ,
    [DefectImage] VARBINARY(MAX) NULL DEFAULT ,
    [DefectImageUrl] VARCHAR(500) NULL DEFAULT ,
    [ProdProcessResultFile] BIGINT NULL DEFAULT ,
    [Note] NVARCHAR(MAX) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Cause] NVARCHAR(MAX) NULL DEFAULT ,
    [Countermeasure] NVARCHAR(MAX) NULL DEFAULT ,
    [FollowUp] NVARCHAR(MAX) NULL DEFAULT 
);
GO

