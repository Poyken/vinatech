CREATE TABLE [dbo].[AspNetUsers] (
    [Id] NVARCHAR(450) NOT NULL DEFAULT ,
    [FullName] NVARCHAR(MAX) NULL DEFAULT ,
    [UserName] NVARCHAR(256) NULL DEFAULT ,
    [NormalizedUserName] NVARCHAR(256) NULL DEFAULT ,
    [Email] NVARCHAR(256) NULL DEFAULT ,
    [NormalizedEmail] NVARCHAR(256) NULL DEFAULT ,
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

