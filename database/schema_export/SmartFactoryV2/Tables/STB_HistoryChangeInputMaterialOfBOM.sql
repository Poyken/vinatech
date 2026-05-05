CREATE TABLE [dbo].[STB_HistoryChangeInputMaterialOfBOM] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [OldMaterialCode] VARCHAR(50) NULL DEFAULT ,
    [NewMaterialCode] VARCHAR(50) NULL DEFAULT ,
    [IsUse] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(50) NULL DEFAULT ,
    [LotID] VARCHAR(50) NULL DEFAULT ,
    [Reason] NVARCHAR(200) NULL DEFAULT ,
    [UseQty] NUMERIC(20,10) NULL DEFAULT ,
    [ProductionConfirm] BIT NULL DEFAULT ,
    [CreateDateProductionConfirm] DATETIME NULL DEFAULT ,
    [CreateProductionUserConfirm] VARCHAR(50) NULL DEFAULT ,
    [QCConfirm] BIT NULL DEFAULT ,
    [CreateDateQCConfirm] DATETIME NULL DEFAULT ,
    [CreateQCUserConfirm] VARCHAR(50) NULL DEFAULT ,
    [ManageConfirm] BIT NULL DEFAULT ,
    [CreateDateManageConfirm] DATETIME NULL DEFAULT ,
    [CreateManageUserConfirm] VARCHAR(50) NULL DEFAULT 
);
GO

