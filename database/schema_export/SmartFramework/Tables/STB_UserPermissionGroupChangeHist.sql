CREATE TABLE [dbo].[STB_UserPermissionGroupChangeHist] (
    [Idx] BIGINT IDENTITY(1,1) NOT NULL DEFAULT ,
    [UserID] VARCHAR(20) NOT NULL DEFAULT ,
    [UserType] VARCHAR(20) NOT NULL DEFAULT ,
    [HasPermission] BIT NULL DEFAULT ,
    [ActionType] VARCHAR(2) NULL DEFAULT ,
    [SBCDocumentNo] VARCHAR(50) NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT ,
    [CreateUserID] VARCHAR(20) NULL DEFAULT 
);
GO

