CREATE TABLE [dbo].[STB_OQCDetailSampleQty_VVT] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [MaterialCode] VARCHAR(30) NULL DEFAULT ,
    [RequestSampleQty] INT NULL DEFAULT ,
    [QcInspectionGroupCode] VARCHAR(20) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

