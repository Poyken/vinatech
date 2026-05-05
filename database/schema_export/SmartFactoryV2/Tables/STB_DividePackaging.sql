CREATE TABLE [dbo].[STB_DividePackaging] (
    [DividePackagingID] VARCHAR(50) NOT NULL DEFAULT ,
    [PackingID] VARCHAR(50) NULL DEFAULT ,
    [Qty] NUMERIC(20,5) NULL DEFAULT ,
    [MaterialCode] VARCHAR(50) NULL DEFAULT ,
    [GRDate] VARCHAR(50) NULL DEFAULT ,
    [LotNo] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(50) NULL DEFAULT ,
    [ParentPackingID] VARCHAR(50) NULL DEFAULT ,
    [TypeBox] INT NULL DEFAULT ,
    [IsSmailBox] VARCHAR(1) NULL DEFAULT ,
    [IsNilonlBox] VARCHAR(1) NULL DEFAULT ,
    [isSliptPacking] BIT NULL DEFAULT ,
    [MergeParentId] VARCHAR(50) NULL DEFAULT ,
    [PackingParentID] VARCHAR(50) NULL DEFAULT ,
    [MergeNilonToSmallBox] VARCHAR(50) NULL DEFAULT (NULL),
    [WorkCenterCode] NVARCHAR(50) NOT NULL DEFAULT ('VVT_F3'),
    [MarkingCode] VARCHAR(100) NULL DEFAULT 
);
GO

