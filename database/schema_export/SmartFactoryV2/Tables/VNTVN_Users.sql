CREATE TABLE [dbo].[VNTVN_Users] (
    [Id] UNIQUEIDENTIFIER NOT NULL DEFAULT ,
    [CompanyCode] NVARCHAR(200) NOT NULL DEFAULT ,
    [LineCode] NVARCHAR(200) NOT NULL DEFAULT ,
    [Status] BIT NOT NULL DEFAULT ,
    [CreateDate] DATETIME2 NULL DEFAULT ,
    [UpdateDate] DATETIME2 NULL DEFAULT ,
    [UserName] NVARCHAR(MAX) NULL DEFAULT ,
    [NormalizedUserName] NVARCHAR(MAX) NULL DEFAULT ,
    [Email] NVARCHAR(MAX) NULL DEFAULT ,
    [NormalizedEmail] NVARCHAR(MAX) NULL DEFAULT ,
    [EmailConfirmed] BIT NOT NULL DEFAULT ,
    [PasswordHash] NVARCHAR(MAX) NULL DEFAULT ,
    [SecurityStamp] NVARCHAR(MAX) NULL DEFAULT ,
    [ConcurrencyStamp] NVARCHAR(MAX) NULL DEFAULT ,
    [PhoneNumber] NVARCHAR(MAX) NULL DEFAULT ,
    [PhoneNumberConfirmed] BIT NOT NULL DEFAULT ,
    [TwoFactorEnabled] BIT NOT NULL DEFAULT ,
    [LockoutEnd] DATETIMEOFFSET NULL DEFAULT ,
    [LockoutEnabled] BIT NOT NULL DEFAULT ,
    [AccessFailedCount] INT NOT NULL DEFAULT 
);
GO

