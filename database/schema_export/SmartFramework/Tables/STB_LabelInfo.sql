CREATE TABLE [dbo].[STB_LabelInfo] (
    [LabelType] NVARCHAR(30) NOT NULL DEFAULT ,
    [FormatName] NVARCHAR(30) NOT NULL DEFAULT ,
    [FormatVersion] INT NOT NULL DEFAULT ,
    [PaperType] NVARCHAR(30) NULL DEFAULT ,
    [CommandType] VARCHAR(20) NOT NULL DEFAULT ,
    [Dpi] VARCHAR(20) NOT NULL DEFAULT ,
    [Format] NVARCHAR(MAX) NULL DEFAULT ,
    [PartitionQty] INT NULL DEFAULT ,
    [ProdSnType] NVARCHAR(50) NULL DEFAULT ,
    [BarcodeModel] VARCHAR(20) NULL DEFAULT ,
    [LabelImageFileID] BIGINT NULL DEFAULT ,
    [ApplyDate] DATE NULL DEFAULT ,
    [IsApproval] BIT NULL DEFAULT ,
    [ApprovalUserID] VARCHAR(20) NULL DEFAULT ,
    [ApprovalDateTime] DATETIME NULL DEFAULT ,
    [LabelRemark] NVARCHAR(MAX) NULL DEFAULT ,
    [DataSourceViewName] VARCHAR(100) NULL DEFAULT ,
    [PrinterName] NVARCHAR(100) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_LabelInfo] PRIMARY KEY CLUSTERED ([LabelType], [FormatName], [FormatVersion])
);
GO

