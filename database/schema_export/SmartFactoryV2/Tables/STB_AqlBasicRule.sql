CREATE TABLE [dbo].[STB_AqlBasicRule] (
    [AQL] VARCHAR(10) NOT NULL DEFAULT ,
    [SampleChar] VARCHAR(1) NOT NULL DEFAULT ,
    [MaxAllowDefectQty] INT NULL DEFAULT ,
    [IsBasicRule] BIT NULL DEFAULT ,
    [CreateDateTime] VARCHAR(19) NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] VARCHAR(19) NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    CONSTRAINT [PK_STB_AqlBasicRule] PRIMARY KEY CLUSTERED ([AQL], [SampleChar])
);
GO

