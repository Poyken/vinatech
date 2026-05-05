CREATE TABLE [dbo].[STB_VVT_SortingErrorData_Plate] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [Date] DATE NULL DEFAULT ,
    [Shift] NVARCHAR(50) NULL DEFAULT ,
    [Person] NVARCHAR(100) NULL DEFAULT ,
    [Vendor] NVARCHAR(100) NULL DEFAULT ,
    [Factory] NVARCHAR(100) NULL DEFAULT ,
    [MaterialCode] NVARCHAR(100) NULL DEFAULT ,
    [LotNo] NVARCHAR(100) NULL DEFAULT ,
    [QtyCheck] INT NULL DEFAULT ,
    [QtyOK] INT NULL DEFAULT ,
    [Burr] INT NULL DEFAULT ((0)),
    [Dent] INT NULL DEFAULT ((0)),
    [Deform] INT NULL DEFAULT ((0)),
    [Scratch] INT NULL DEFAULT ((0)),
    [NGPlating] INT NULL DEFAULT ((0)),
    [RoughFace] INT NULL DEFAULT ((0)),
    [Dirty] INT NULL DEFAULT ((0)),
    [DentBottom] INT NULL DEFAULT ((0)),
    [Discolor] INT NULL DEFAULT ((0)),
    [OtherError] INT NULL DEFAULT ((0)),
    [Total] INT NULL DEFAULT ((0)),
    [CreateUserID] NVARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate()),
    [ChangeUserID] NVARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT 
);
GO

