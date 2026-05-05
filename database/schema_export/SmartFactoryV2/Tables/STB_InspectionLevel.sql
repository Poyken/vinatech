CREATE TABLE [dbo].[STB_InspectionLevel] (
    [InspectionLevelSeq] VARCHAR(20) NOT NULL DEFAULT ,
    [InspectionLevel] VARCHAR(20) NULL DEFAULT ,
    [MinGrQty] BIGINT NULL DEFAULT ,
    [MaxGrQty] BIGINT NULL DEFAULT ,
    [SampleChar] VARCHAR(1) NULL DEFAULT ,
    [SampleQty] BIGINT NULL DEFAULT ,
    [CreateDateTime] VARCHAR(19) NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] VARCHAR(19) NULL DEFAULT ,
    [ChangeUserID] VARCHAR(50) NULL DEFAULT 
);
GO

