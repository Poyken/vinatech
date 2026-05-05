CREATE TABLE [dbo].[Stb_VVT_OpenExpiredMaterial] (
    [LotID] VARCHAR(50) NULL DEFAULT ,
    [CreateUserID] VARCHAR(50) NULL DEFAULT ,
    [OpenExpired] BIT NULL DEFAULT ,
    [CreateDateTime] DATETIME NULL DEFAULT (getdate())
);
GO

