CREATE TABLE [dbo].[Stb_CheckSheetDailyDetail] (
    [ID] INT IDENTITY(1,1) NOT NULL DEFAULT ,
    [CheckSheetDaily] NVARCHAR(50) NULL DEFAULT ,
    [CategoryCheckListNo] NVARCHAR(50) NULL DEFAULT ,
    [Result1] BIT NULL DEFAULT ,
    [Result2] BIT NULL DEFAULT ,
    [Result3] BIT NULL DEFAULT ,
    [Result4] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] NVARCHAR(50) NULL DEFAULT ,
    [ChangeDateTime] DATETIME NULL DEFAULT ,
    [ChangeUserID] NVARCHAR(50) NULL DEFAULT ,
    [ChangeTimeResult1] DATETIME NULL DEFAULT ,
    [ChangeTimeResult2] DATETIME NULL DEFAULT ,
    [ChangeTimeResult3] DATETIME NULL DEFAULT ,
    [ChangeTimeResult4] DATETIME NULL DEFAULT 
);
GO

