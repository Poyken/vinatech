CREATE TABLE [dbo].[STB_SnapDocumentsVersion] (
    [DocumentId] VARCHAR(20) NOT NULL DEFAULT ,
    [Version] INT NOT NULL DEFAULT ,
    [VersionDescription] NVARCHAR(MAX) NULL DEFAULT ,
    [Layout] VARBINARY(MAX) NULL DEFAULT ,
    [PreviewPDF] VARBINARY(MAX) NULL DEFAULT ,
    [ApplyDate] DATE NULL DEFAULT ,
    [IsApproval] BIT NULL DEFAULT ,
    [ApprovalUserID] VARCHAR(20) NULL DEFAULT ,
    [ApprovalDateTime] DATETIME NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_SnapDocumentsVersion] PRIMARY KEY CLUSTERED ([DocumentId], [Version])
);
GO

