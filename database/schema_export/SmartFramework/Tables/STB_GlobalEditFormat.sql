CREATE TABLE [dbo].[STB_GlobalEditFormat] (
    [FieldName] NVARCHAR(50) NOT NULL DEFAULT ,
    [DisplayFormatType] VARCHAR(20) NULL DEFAULT ,
    [DisplayFormatString] NVARCHAR(50) NULL DEFAULT ,
    [EditFormatType] VARCHAR(20) NULL DEFAULT ,
    [EditFormatString] NVARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT 
);
GO

