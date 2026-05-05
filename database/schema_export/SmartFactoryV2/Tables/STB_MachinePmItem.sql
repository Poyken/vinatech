CREATE TABLE [dbo].[STB_MachinePmItem] (
    [MachinePmItemCode] VARCHAR(20) NOT NULL DEFAULT ,
    [CompanyCode] VARCHAR(20) NULL DEFAULT ,
    [WorkCenterCode] VARCHAR(20) NULL DEFAULT ,
    [MachineCode] VARCHAR(20) NULL DEFAULT ,
    [PmItemName] NVARCHAR(100) NULL DEFAULT ,
    [PmItemGroup] NVARCHAR(100) NULL DEFAULT ,
    [InspectionMethod] NVARCHAR(50) NULL DEFAULT ,
    [PmItemSpec] NVARCHAR(200) NULL DEFAULT ,
    [PmTermType] VARCHAR(10) NULL DEFAULT ,
    [FinalPmDate] DATE NULL DEFAULT ,
    [NextPmPlanDate] DATE NULL DEFAULT ,
    [IsUsed] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] VARCHAR(20) NULL DEFAULT ,
    [Remark] VARCHAR(1000) NULL DEFAULT 
);
GO

